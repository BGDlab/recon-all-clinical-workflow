1. Create the initial config file: `bash synthsegJobSubmitter.sh [path to BIDS directory] [config.txt filename]`
2. Open the config.txt file and navigate to the end of the file. What is the max ArrayJobId in the file (should be the last one)?
3. Open `arrayJobsReconAllClinical.sh`. Modify the line `#SBATCH --array=1-814` by replacing the number after the dash with the max ArrayJobId value. This tells `sbatch` that you want to run a set of N jobs labelled 1-N. It makes reading the log files a little easier.
4. Run `sbatch arrayJobsReconAllClinical.sh [config_file_name]`
5. Wait. It will take time to run all the jobs.
6. Check that jobs ran
7. Rerun jobs that failed due to out of memory

