import argparse
import glob
import os

import pandas as pd


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--filename', help='New file name for failed jobs')
    parser.add_argument('-d', '--dirname', help='Name of the data delivery (eg "slip_2022", "slip_2024_02", etc.)', default="")
    args = parser.parse_args()

    # I don't feel like setting up the argparser but I'm not sure I need to.
    ss_dir = "/mnt/isilon/bgdlab_processing/code/recon-all-clinical/"
    error_msg = "Some of your processes may have been killed by the cgroup out-of-memory handler"
    # new_config_fn = ss_dir+"config_files/jenna_testing_failed.tsv"
    new_config_fn = os.path.join(ss_dir, args.filename)
    new_config_lines = []
    counter = 1

    # Get the list of .out files in the directory
    out_fns = glob.glob(ss_dir+"slurm_logs/*.out")

    # For every .out file in the directory,
    for out_fn in out_fns:
        # Read the file
        with open(out_fn, 'r') as f:
            lines = f.readlines()

        # Does the file have the "Some of your processes may have been killed by the cgroup out-of-memory handler" message?
        if any([i for i in lines if error_msg in i]):
            # If yes, read the first line and split on the " "
            my_args = lines[0]
            print(my_args)
            in_fn = my_args.split(" ")[0].lstrip()
            out_dir = my_args.split(" ")[1].rstrip()
            subj = "sub-"+in_fn.split("sub-")[1].split("/")[0]

            # Start assembling the list of args
            args_list = [counter, in_fn, subj, out_dir]
            new_config_lines.append(args_list)
            counter = counter+1
    
    # Concat rows of params into a dataframe
    new_config_header = ["ArrayTaskID", "InputFileName", "SubjId", "OutputDir"]
    new_config_df = pd.DataFrame(data=new_config_lines, columns=new_config_header)
    # Drop duplicates
    new_config_df = new_config_df.drop_duplicates()
    # If the user defined a directory name
    print(new_config_df.shape)
    print(new_config_df.head(10)['InputFileName'].values)
    if args.dirname != "":
        new_config_df = new_config_df[new_config_df['InputFileName'].str.contains(args.dirname)]
    print(new_config_df.shape)
    # Clean up the ArrayTaskIDs
    new_config_df['ArrayTaskID'] = list(range(1,len(new_config_df)+1))
    # Save the new config file
    new_config_df.to_csv(new_config_fn, index=False, sep="\t")
    # Print
    print("An updated file of failed jobs was written to", new_config_fn)


if __name__ == "__main__":
    main()
