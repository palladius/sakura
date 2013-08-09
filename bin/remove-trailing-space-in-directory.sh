#!/bin/bash

DIR=.

# if bash:
find . -not \( -name .svn -prune -o -name .git -prune \) -type f -print0 | xargs -0 sed -i '' -e "s/[[:space:]]*$//"

# if Mac:
# find . -not \( -name .svn -prune -o -name .git -prune \) -type f -print0 | xargs -0 sed -i '' -E "s/[[:space:]]*$//"

#' from: http://stackoverflow.com/questions/149057/how-to-remove-trailing-whitespace-of-all-files-recursively

