#!/bin/sh

VER=0.9
REPO=${1:-MISSING_REPO_NAME}
# With the basename you lose the directory (etc/) :(
#REPO=$(basename $REPO .git)   # eliminates .git in the end, if such
REPODIR="$REPO"

usage() {
        echo "Usage: $(basename $0) REPONAME.git"
        echo "   (.git in the end is mandatory)"
}
if echo $REPODIR |egrep -v "\.git$" ; then
        usage
fi

echo "Creating repo called '$REPODIR'"
mkdir "$REPODIR" && 
	cd "$REPODIR" && 
	git init --bare && 
	vim $REPODIR/description && 
	echo Tudo beim

#echo "Now please edit the file: vim $REPODIR/description"