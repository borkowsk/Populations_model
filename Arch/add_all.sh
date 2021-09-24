#git remote to all subdirectories
#https://stackoverflow.com/questions/3497123/run-git-pull-over-all-subdirectories/40601481
#https://unix.stackexchange.com/questions/50692/executing-user-defined-function-in-a-find-exec-call

git_job(){
DIRNAME=`basename $1`
#echo $DIRNAME
pushd $DIRNAME > /dev/null
MESSG=`date -r $DIRNAME.pde`
MESSG="\"$MESSG $DIRNAME.pde\"" 
/usr/bin/git add --dry-run *.*
/usr/bin/git commit --dry-run *.* -m "$MESSG" 
#echo $MESSG
popd > /dev/null
echo 
}

LST=`ls -D | sort`

for d in $LST; do
 if [ -d $d ]; then
        echo $d
        git_job "./$d"
 fi
done


