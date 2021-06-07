#!/bin/bash

# A script to pull info from remote server
# Usage:
# For dry run:  ./pull_rsync.sh
# For run:      ./pull_rsync.sh do-run

if [ -z $1 ]; then
        DRY_RUN="--dry-run"
elif [ $1 == "do-run" ]; then
        DRY_RUN=""
else
        DRY_RUN="--dry-run"
fi

time rsync -avz -m $DRY_RUN --rsh=ssh \
user_name@192.000.00.000:/home/path_to/dir1 \
/home/path_to/rsync_tutorial \
--exclude={"*.html","*.sam","*.fastq","*.out","*.out.bam","*aln.bam"}
