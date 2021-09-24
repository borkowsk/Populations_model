#git remote to all subdirectories
#https://stackoverflow.com/questions/3497123/run-git-pull-over-all-subdirectories/40601481
#https://unix.stackexchange.com/questions/50692/executing-user-defined-function-in-a-find-exec-call

git_job(){
DIRNAME=`basename $0`
#echo $DIRNAME
pushd $DIRNAME > /dev/null
MESSG=`date -r $DIRNAME.pde`
MESSG="\"$MESSG $DIRNAME.pde\"" 
/usr/bin/git add --dry-run *.*
/usr/bin/git commit --dry-run *.* -m "$MESSG" 
popd > /dev/null
echo 
}

export -f git_job

find . -type d -maxdepth 1 -print -exec /bin/bash -c 'git_job "$0"' {}  \;
