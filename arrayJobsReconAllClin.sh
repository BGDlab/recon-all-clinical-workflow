#!/bin/bash
#
#SBATCH --job-name=clin-recon-all
#SBATCH --time=60:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --array=1-2170
#SBATCH --output=./slurm_logs/%x_%u_%A_%a.out

CONFIGFN=$1

INFN=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $CONFIGFN )
SUBJID=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $CONFIGFN )
OUTDIR=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $4}' $CONFIGFN )

#------------------

echo $INFN $OUTDIR

module load FreeSurfer/7.4.1

# If OUTDIR doesn't exist, make it
if [ ! -d $OUTDIR ] ; then 
    # This is the first pass at trying to run the pipeline on the scan
    mkdir -p $OUTDIR
    # Make a copy of the infn that has the correct data type
    python convert_nifti_datatype.py -i $INFN -o $OUTDIR/input.nii.gz
    # Run recon-all-clinical
    time recon-all-clinical.sh $OUTDIR/input.nii.gz $SUBJID 4 $OUTDIR
    echo "Job finished running!"

else 
    echo "The pipeline has already been run on this scan and it did not experience the unsigined short error."
    echo "If you wish to overwrite the results of that run, please remove the output directory and run again."
fi




