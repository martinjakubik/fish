#!/bin/bash
# sets up usage
USAGE="usage: $0 -i infile --outfile outfile -o outfile"

# set up defaults
infile=~/infile.txt
outfile=~/outfile.txt

# parses and reads command line arguments
while [ $# -gt 0 ]
do
  case "$1" in
    (-i) infile="$2"; shift;;
    (--outfile) outfile="$2"; shift;;
    (-o) outfile="$2"; shift;;
    (-*) echo >&2 ${USAGE}
    exit 1;;
  esac
  shift
done

if [[ ! -e  $outfile ]] ; then
  outfilebasedir=$(basedir $outfile)
  mkdir -p $outfilebasedir
fi

echo you entered values
echo   From infile : $infile
echo   To          : $outfile
