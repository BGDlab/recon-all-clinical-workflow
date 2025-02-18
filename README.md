1. Create the initial config file: `bash configCreatorReconAllClin.sh [path to BIDS directory] ./config_files/[config.txt filename]`
2. Open the config.txt file and navigate to the end of the file. What is the max ArrayJobId in the file (should be the last one)?
3. Open `arrayJobsReconAllClinical.sh`. Modify the line `#SBATCH --array=1-814` by replacing the number after the dash with the max ArrayJobId value. This tells `sbatch` that you want to run a set of N jobs labelled 1-N. It makes reading the log files a little easier.
4. Run `sbatch arrayJobsReconAllClinical.sh ./config_files/[config_file_name]`
5. Wait. It will take time to run all the jobs.
6. Looking at log files, run `grep -l "All done!" ./slurm_logs/*.out | xargs rm` to remove log files for jobs that ran successfully.
7. Use `grep -l "slip_(delivery_label)" ./slurm_logs/*.out` to find the job id for the set of jobs you're looking for. It will be the second to last number at the end of the .out files.
8. Then use the base filename at the end of the following command to see what errors are occurred: `grep -l -L " out-of-memory handler.\|Error: input should have 3 dimensions, had 2\|numpy.linalg.LinAlgError: Singular matrix" slurm_logs/clin-recon-all_[your username]_[job id]_*.out`. 
    - These should be the only errors that might be seen. The out of memory error can be resolved by increasing the amount of memory allocated to a job (see next step). 
    - The other errors should only impact a few if any jobs.
1. Check that jobs ran using `python identifyFailedJobs.py -f [new config.txt filename] -d [name of the data delivery (eg "slip_2022", "slip_2024_02", etc.)]`. It will examine the log files in the subdirectory `slurm_logs` to identify scans that failed due to out of memory errors.
2. Rerun jobs that failed the initial pass `sbatch arrayJobsRerunReconAllClinical.sh ./config_files/[config_file_name]`
3. When all images have been processed, run `python extractFreeSurferMeasures.py -d /path/to/dataset/derivatives/recon-all-clinical`. Make sure there's no trailing `/`! The aggregated table of imaging phenotypes will then be in `/path/to/dataset/derivatives/recon-all-clinical_structural_stats.csv`
