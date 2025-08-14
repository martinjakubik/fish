#!/bin/bash
# sets up usage
USAGE="usage: $0 -i --inputFile inputFile -o --destinationDir destinationDir -d --debug"

# set up defaults
DEBUG=0
inputFile=~/inputFile
destinationDir=~/destinationDir

# this moves files that are listed in a text file, one file per line, to a new directory
# it keeps the first-level parent directory of each file as child of the new directory, creating these as necessary
# it expects a format similar to this in the text file:
#
# /Volumes/DiskName/Photos/My Photos/Photos from 2017/IMG_2602.MOV
# /Volumes/DiskName/Photos/My Photos/Photos from 2015/IMG_8486.MOV
# /Volumes/DiskName/Photos/My Photos/Photos from 2015/IMG_8470.JPG
# /Volumes/DiskName/Photos/My Photos/Photos from 2017/IMG_2584.JPG
# /Volumes/DiskName/Photos/My Photos/Photos from 2015/IMG_8467.JPG
# /Volumes/DiskName/Photos/My Photos/Photos from 2015/la fête chez mamie.MOV
# /Volumes/DiskName/Photos/My Photos/Photos from 2017/Party at Earl _s.JPG
#
# In this example, if the destinationDir is '~/Downloads' it will move the first file from:
#
# /Volumes/DiskName/Photos/My Photos/Photos from 2017/IMG_2602.MOV
#
# to:
#
# ~/Downloads/Photos from 2017/IMG_2602.MOV


# parses and reads command line arguments
while [ $# -gt 0 ]
do
  case "$1" in
    (-i) inputFile="$2"; shift;;
    (--inputFile) inputFile="$2"; shift;;
    (-o) destinationDir="$2"; shift;;
    (--destinationDir) destinationDir="$2"; shift;;
    (-d) DEBUG=1;;
    (--debug) DEBUG=1;;
    (-*) echo >&2 ${USAGE}
    exit 1;;
  esac
  shift
done

echo you entered values
echo   "From inputFile : $inputFile"
echo   "To            : $destinationDir"
echo

if [[ -e "$inputFile" ]] ; then
    while IFS= read -r file_to_move; do
      file_to_move_basename=$(basename "$file_to_move")
      echo "$file_to_move_basename"
      file_to_move_in_current_dir_relative_path="Takeout 20 Short"/"$file_to_move_basename"
      if [[ -e "$file_to_move_in_current_dir_relative_path" ]] ; then
        echo moving $(basename "$file_to_move_in_current_dir_relative_path")
        file_to_move_old_path=$(dirname "$file_to_move")
        file_to_move_parent_directory=$(basename "$file_to_move_old_path")
        file_to_move_new_directory="$destinationDir""$file_to_move_parent_directory"
        if [[ ! -d "$file_to_move_new_directory" ]] ; then
          echo mkdir "$file_to_move_new_directory"
        fi
        echo mv "$file_to_move_in_current_dir_relative_path" "$file_to_move_new_directory"
      else
        echo "$file_to_move_in_current_dir_relative_path" does not exist
      fi
      echo
    done < "$inputFile"
fi
