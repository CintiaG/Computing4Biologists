# RSYNC with remote server

Author: Cintia Gómez-Muñoz

Created: April 14, 2021

Updated: June 7, 2021

---

## Introduction

Sometimes, you can be working in a remote server to make use of the computing capabilities, but the script design and posterior analysis could be better performed in your local computer. There are several ways to upload or download the information, such as **SCP** and **FTP**. However, the process can be tedious and you run the risk of accidentally replacing an existing file that has bee modified in either the remote or local server. Therefore, it would be a better idea to use a software that can verify the existence of a file and that helps create identical copies of the directories in both servers. Such software solution is offered by **RSYNC** (from remote synchronization). By default **RSYNC** checks the size and modification time of the file and copies only the ones that have been modified. The first time you perform the process can be lengthy, but the occasions afterwards would take considerably less time.

## Pull example

To perform this example, an **SSH** connection between the remote and local server must have been previously performed. Furthermore, **RSYNC** has to be installed in both server (which is usually true). The action to download the files is called **pull**, wheres the opposite one is called **push**. We are going to start with a **pull** example.

To test a pull, log-in to your remote server and do the following in your desired directory.

```bash
mkdir rsync_tutorial
cd rsync_tutorial
mkdir dir1
touch dir1/file{1..10}.txt
```

The last command will automatically create ten empty text files. Next, log-out from the remote server (or open a new terminal) and in your local computer simply run the following command:

```bash
rsync -av --dry-run --rsh=ssh user_name@192.000.00.000:/home/path_to/dir1 /home/path_to/rsync_tutorial
```

* Modify paths accordingly.

Let us dissect the previous command:
  * **rsync:** invokes the program.
  * **-av:** flag **a**, from 'archive', which equals to `-rlptgoD`, and flag **v**, from verbose. See the **RSYNC** manual for more information (`man rsync`).
  * **--dry-run:** do nothing, just test the connection and check which files would transfer.
  * **--rsh=ssh:** indicate the connection protocol, in this case **SSH**.
  * **user_name@192.000.00.000:** user and IP address for the **SSH** connection.
  * **/home/path_to/dir1:** origin directory.
  * **/home/path_to/rsync_tutorial:** destination directory.

After submitting this command, the terminal will ask you for your user password. Afterwards, if everything is correct, no error messages will be displayed. Otherwise, check the messages and modify accordingly.

Pay attention to the presence or absence of a slash `/` at the end of the origin directory path, because:
  * **Presence** implies that you want to backup _only_ the files contained in that directory.
  * **Absence** implies that you want to backup all the files contained _plus_ that directory in the destination directory (i.e. whether a **dir1** directory will be created in the **rsync_tutorial** directory, or not).

If everything seems to be working alright, you can delete the `--dry-run` part and run the command as follows:

```bash
rsync -av --rsh=ssh user_name@192.000.00.000:/home/path_to/dir1 /home/path_to/rsync_tutorial
```

Now, log-in to the server and manually edit one of the file, for example:

```bash
nano dir1/file1.txt
# edit manually
```

Repeat in your local server the previous synchronization commands and observe what happens. As expected, only **file1.txt** was newly backed up.

## Push example

Now, let us say that we want to upload files to the server. To do that, it is very simple, you only need to invert the order of the origin and destination directories as follows:

```bash
rsync -av --dry-run --rsh=ssh /home/path_to/rsync_tutorial/ user_name@192.000.00.000:/home/path_to/
```

If you want to create exact copies of the directories (mirrors), for example, to delete files that no longer exists in the origin directory, you can use the `--delete` option. However, when doing the former, you have to be **_extremely careful_**. Remember to always test the run with `--dry-run` and to double check the origin and destination directories. because, for example, you could accidentally end up loosing a great deal of data if you set the wrong order and the origin directory is empty.

## Faster and safer transfer

Another option to perform the transfer faster is to compress the files during the process. This can be done with the `-z` flag. For example:

```bash
rsync -avz --dry-run --rsh=ssh user_name@192.000.00.000:/home/path_to/dir1 /home/path_to/rsync_tutorial
```

For example, I had a file called **annotation.gff** of size `27182219`. We I evaluated the tranfer using the `time` command, I obtained the following results.

Without compressing:

```none
sent 27,190,537 bytes  received 105 bytes  415,124.31 bytes/sec
total size is 567,171,241  speedup is 20.86

real	1m4.590s
user	0m0.644s
sys	0m0.403s
```

Compressing:

```none
sent 6,780,341 bytes  received 105 bytes  190,998.48 bytes/sec
total size is 567,171,242  speedup is 83.65

real	0m34.527s
user	0m6.668s
sys	0m0.133s
```

If you are transferring too many files, you can also use `screen` to save the process and go back to it when desired. For example:

```bash
screen -SL mysync rsync -avz --dry-run --rsh=ssh user_name@192.000.00.000:/home/path_to/dir1 /home/path_to/rsync_tutorial
```

## Synchronize only desired files

Let us say that we have performed a lengthy analysis that have generated too many intermediate file. We want to synchronize some information, but not the mentioned intermediate files. For example, let us say that I am only interested in synchronizing **FASTA** files, we can do:

```bash
rsync -av --dry-run --rsh=ssh user_name@192.000.00.000:/lustre/scratch/hpc-cintia-gomez/sp_annot/CBS1503_nano /home/cintia/Documents/IPICYT/Tesis/bioinfo/maltose/01_assemblies/CBS1503 --include="*/" --include="*.fasta" --exclude="*"
```

* `--include="*/"` tells the command to follow in sub-directories.
* `--include="*.fasta"` is the patter to look for.
* `--exclude="*"` excludes everything (except for the above).

You can find more information [here](https://velenux.wordpress.com/2017/01/09/how-to-exclude-everything-except-a-specific-pattern-with-rsync/)

Now, let us say that the former process went and copied all the directories, even if those did not contain files matching the pattern. If we do not want those directories, we can use the `-m` flag, which exclude directories that results empty after the search.

```bash
rsync -av -m --dry-run --rsh=ssh user_name@192.000.00.000:/lustre/scratch/hpc-cintia-gomez/sp_annot/CBS1503_nano /home/cintia/Documents/IPICYT/Tesis/bioinfo/maltose/01_assemblies/CBS1503 --include="*/" --include="*.funct.renamed.*" --exclude="*"
```

Finally, sometimes we want to include several patterns at the same time, for example:

```bash
rsync -av -m --dry-run --rsh=ssh user_name@192.000.00.000:/lustre/scratch/hpc-cintia-gomez/sp_annot/CBS1503_nano /home/cintia/Documents/IPICYT/Tesis/bioinfo/maltose/01_assemblies/CBS1503 --include="*/" --include="*.funct.renamed.*" --include="*.ctl" --exclude="*"
```

But at one point, the command can become very long. Another option is to insert all the pattern using curly braces. For example:

```bash
rsync -av --dry-run --rsh=ssh /home/cintia/Documents/IPICYT/Tesis/bioinfo/rna-seq-analysis/04_ref_assembly user_name@192.000.00.000:/lustre/scratch/hpc-cintia-gomez/rna-seq-analysis --exclude={"*.html","*.pdf"}
```

To copy only the directories structure without copying any files, you can do:

```bash
screen -SL mysync rsync -avz -f"+ */" -f"- *" --dry-run --rsh=ssh user_name@192.000.00.000:/lustre/scratch/hpc-cintia-gomez/sp_genes /home/cintia/Documents/IPICYT/Tesis/bioinfo/rsync_test/
```

## RSYNC bash script

Once you have figured out the command that works for you, you can save it in your working directory to execute it a any time. I designed a script that helps me check the list of files to transfer on dry-run. The script also allows me to run the actual transfer when I am sure by adding a `do-run` flag to the execution. Both push and pull versions of the script are in the **used_scripts** directory.

```bash
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
```

More information on **RSYNC** [here](https://linuxize.com/post/how-to-exclude-files-and-directories-with-rsync/)
