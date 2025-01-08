# Usage: submit a series of SynthSeg+ jobs 
# bash synthsegJobSubmitter.sh [BIDS directory] [config.txt filename]

DATADIR=$1
CONFIGFN=$2

BASE=/mnt/isilon/bgdlab_processing/code/recon-all-clinical
#CONFIGFN=$BASE/config.txt
COUNTER=1
touch $CONFIGFN
echo -e "ArrayTaskID\t InputFileName\t SubjId\t OutputDir"  >> $CONFIGFN


# for subject in directory
for subj in $DATADIR/sub-* ; do
    SUBJID=$(basename $subj)

    # for session in directory
    for session in $subj/ses-* ; do

        # Check that an MPR exists in the session 
        for fn in $session/anat/* ; do 

            if [[ $fn == *".nii.gz" ]] ; then      # Only work on the images
           
                 # Set up the output directory
                 OUTBASE="${DATADIR/BIDS/derivatives}"
                 OUTFN=$(basename $fn)
                 OUTFN="${OUTFN%%.nii.gz}"

                 # Prep the output for the SS pipeline with the --robust flag
                 OUTDIR="$OUTBASE/recon-all-clinical/$OUTFN"
                 echo $OUTDIR
       
                 # If the ouput directory doesn't exist, then make it
                 if [ ! -d $OUTDIR ] ; then
                     mkdir -p $OUTDIR
                 fi

                 echo -e "$COUNTER\t $fn\t $SUBJID\t $OUTDIR" >> $CONFIGFN
                 COUNTER=$((COUNTER+1))
            fi
        done # end for fn in session/anat/*.nii.gz
    done # end for session in subject
done # end for subject

