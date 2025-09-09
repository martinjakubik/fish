#!/bin/bash
# sets up usage
USAGE="usage: $0 -i --inputDir inputDir -d --debug"

# set up defaults
DEBUG=0
inputDir=$HOME/inputDir

# parses and reads command line arguments
while [ $# -gt 0 ]
do
  case "$1" in
    (-i) inputDir="$2"; shift;;
    (--inputDir) inputDir="$2"; shift;;
    (-d) DEBUG=1;;
    (--debug) DEBUG=1;;
    (-*) echo >&2 ${USAGE}
    exit 1;;
  esac
  shift
done

find "$inputDir" \( -name '*.jpg' -o -name '*.JPG' -name '*.jpeg' -o -name '*.JPEG' -name '*.png' -o -name '*.PNG' -name '*.webp' -o -name '*.WEBP' -name '*.heic' -o -name '*.HEIC' -name '*.mov' -o -name '*.MOV' -name '*.mp4' -o -name '*.MP4' \)