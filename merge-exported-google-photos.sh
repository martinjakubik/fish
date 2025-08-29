#!/bin/bash
# moves photo files exported from google takeout
#
# from a file directory like:
# Takeout/Google Photos/Photos from 1950/IMG_3324.JPG
# Takeout 2/Google Photos/Photos from 1950/IMG_5120.PNG
# Takeout 2/Google Photos/Photos from 1950/IMG_3324.JPG.supplemental-metadata.json
# Takeout 2/Google Photos/Photos from 1960/Scan10015.JPG
# Takeout 3/Google Photos/Photos from 1960/Scan10015.JPG.supplemental-metadata.json
# Takeout 3/Google Photos/Photos from 1939/Scan10017.JPG.supplemental-metadata.json
# Takeout 3/Google Photos/Photos from 1939/Scan10017.JPG
# Takeout 4/Google Photos/Photos from 2017/17d2964e-e46e-4f0c-8c7a-5e1c2487419f.mp4
# Takeout 4/Google Photos/Photos from 2017/17d2964e-e46e-4f0c-8c7a-5e1c2487419f.mp4.suppl.json
# Takeout 5/Google Photos/Photos from 2017/20170414_141957_HDR.jpg
# Takeout 5/Google Photos/Photos from 2017/20170414_141957_HDR.jpg.supplemental-metadata.json
# Takeout 5/Google Photos/photos for profile/dscf0056.jpg.supplemental-metadata.json
# Takeout 5/Google Photos/photos for profile/IMG_4239.JPG.supplemental-metadata.json
# Takeout 5/Google Photos/photos for profile/IMG_4239.JPG
#
# to one like:
# Photos from 1950/IMG_3324.JPG
# Photos from 1950/IMG_5120.PNG
# Photos from 1950/IMG_3324.JPG.supplemental-metadata.json
# Photos from 1960/Scan10015.JPG
# Photos from 1960/Scan10015.JPG.supplemental-metadata.json
# Photos from 1939/Scan10017.JPG.supplemental-metadata.json
# Photos from 1939/Scan10017.JPG
# Photos from 2017/17d2964e-e46e-4f0c-8c7a-5e1c2487419f.mp4
# Photos from 2017/17d2964e-e46e-4f0c-8c7a-5e1c2487419f.mp4.suppl.json
# Photos from 2017/20170414_141957_HDR.jpg
# Photos from 2017/20170414_141957_HDR.jpg.supplemental-metadata.json
# photos for profile/dscf0056.jpg.supplemental-metadata.json
# photos for profile/IMG_4239.JPG.supplemental-metadata.json
# photos for profile/IMG_4239.JPG
# 
# sets up usage
USAGE="usage: $0 -i --inputDir inputDir -o --destinationDir destinationDir --listDirectories yes|no --copyFiles yes|no -d --debug"

# set up defaults
DEBUG=0
list_numbered_directories=0
copy_files=0
using_downloads_folder=1
inputDir=~/inputDir
destinationDir=~/destinationDir

# parses and reads command line arguments
if [ $# -eq 0 ]; then
    >&2 echo "you did not provide a folder name; using downloads folder"
else
    using_downloads_folder=0
fi

while [ $# -gt 0 ]
do
  case "$1" in
    (-i) inputDir="$2"; shift;;
    (--inputDir) inputDir="$2"; shift;;
    (-o) destinationDir="$2"; shift;;
    (--destinationDir) destinationDir="$2"; shift;;
    (--listDirectories) listDirectories="$2"; shift;;
    (--copyFiles) copyFiles="$2"; shift;;
    (-d) DEBUG=1;;
    (--debug) DEBUG=1;;
    (-*) echo >&2 ${USAGE}
    exit 1;;
  esac
  shift
done

echo you entered values
echo   "From inputDir     : $inputDir"
echo   "To                : $destinationDir"
echo   "List directories  : $listDirectories"
echo   "Copy files        : $copyFiles"

if [ "$using_downloads_folder" -eq 1 ] ; then
    basefilepath=~/Downloads
else
    basefilepath=$(dirname "$inputDir")/$(basename "$inputDir")
fi

if [ "$listDirectories" = "yes" ] ; then
    list_numbered_directories=1
else
    list_numbered_directories=0
fi

if [ "$copyFiles" = "yes" ] ; then
    copy_files=1
else
    copy_files=0
fi

if [[ $list_numbered_directories -eq 1 ]] ; then
    echo listing directories
    echo > list_of_numbered_directories
    for numbered_directory in $basefilepath/Takeout* ; do
        if [[ -d "$numbered_directory" ]] ; then
            find "$numbered_directory" -type d -depth 2 >> list_of_numbered_directories
        fi
    done
else
    echo "not listing directories; to enable this, add --listDirectories yes"
fi

directory_count=0
if [[ $copy_files -eq 1 ]] ; then
    echo copying files
    if [[ -e list_of_numbered_directories ]] ; then
        while IFS= read -r numbered_source_directory; do
            if [[ ! -z "${numbered_source_directory// }" ]] ; then
                (( directory_count++ ))
                echo directory count: $directory_count
                numbered_directory_basename=$(basename "$numbered_source_directory")
                if [[ ! -d $destinationDir/"$numbered_directory_basename" ]] ; then
                    mkdir -p "$destinationDir/$numbered_directory_basename"
                fi
                cp "$numbered_source_directory"/* "$destinationDir"/"$numbered_directory_basename/"
            fi
        done < list_of_numbered_directories
    fi
else
    echo "not copying files; to enable this, add --copyFiles yes"
fi