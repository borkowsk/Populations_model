#!/bin/bash
#Add & commit SEQUENCIONALLY all subdirectories to git 
#Version 1.0
#https://stackoverflow.com/questions/3497123/run-git-pull-over-all-subdirectories/40601481
#https://unix.stackexchange.com/questions/50692/executing-user-defined-function-in-a-find-exec-call

git_job(){
DIRNAME=`basename $1`
#echo $DIRNAME
pushd $DIRNAME > /dev/null
MESSG=`date -r $DIRNAME.pde`
MESSG="\"$MESSG $DIRNAME.pde\"" 
/usr/bin/git add *.*
/usr/bin/git commit *.* -m "$MESSG" 
#echo $MESSG
popd > /dev/null
echo 
}

LST=`ls -D | sort`

for d in $LST; do
 if [ -d $d ]; then
        ~/.worklog/wlog.sh "GIT\tAdding whole directory\t$d"
        git_job "./$d"
 fi
done


