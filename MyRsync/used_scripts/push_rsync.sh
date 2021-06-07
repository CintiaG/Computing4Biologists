#!/bin/bash

# A script to push info to remote server
# usage:
# For dry run:	./push_rsync.sh
# For run:	./push_rsync.sh do-run

if [ -z $1 ]; then
	DRY_RUN="--dry-run"
elif [ $1 == "do-run" ]; then
	DRY_RUN=""
else
	DRY_RUN="--dry-run"
fi

time rsync -avz -m $DRY_RUN --rsh=ssh \
/home/path_to/rsync_tutorial \
user_name@192.000.00.000:/home/path_to/dir1 \
--exclude={"*.html","*.pdf","*.md","*.R","*rsync.sh","screenlog.0","*.png"}
