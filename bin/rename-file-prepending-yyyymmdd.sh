#!/bin/bash

# https://www.linuxquestions.org/questions/linux-newbie-8/adding-a-files-creation-date-to-it%27s-file-name-832877/
# with some adaptation
# Rename all the files with timestamps.
for filename in * ; do
    YYYYMMDD=$( stat "$filename" | grep -E '^(Modify:)' | awk '{print  $2 }' | sed 's/[^0-9a-zA-Z_\.]//g' ) #| awk -F. '{printf "%s:%s:", $1,$filename}' | awk -F: '{printf "%s_%s.%s", $1, $3, $2}'`
    #NEW_NAME=`stat "$filename" | grep -E '^(  File:|Modify:)' | awk '{print $2$3}' | sed 's/[^0-9a-zA-Z_\.]//g' | awk -F. '{printf "%s:%s:", $1,$2}' | awk -F: '{printf "%s_%s.%s", $1, $3, $2}'`
    NEW_NAME="$YYYYMMDD-$filename"
    echo mv "$filename" "$NEW_NAME"
done
