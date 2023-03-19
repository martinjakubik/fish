#!/bin/bash

# sets up usage
USAGE="usage: $0 -i infile -c lineCount"

# set up defaults
infile=~/infile.txt
rowRange=100

# parses and reads command line arguments
while [ $# -gt 0 ]
do
  case "$1" in
    (-i) infile="$2"; shift;;
    (-c) rowRange="$2"; shift;;
    (--outfile) outfile="$2"; shift;;
    (-*) echo >&2 ${USAGE}
    exit 1;;
  esac
  shift
done

if [[ ! -e  $outfile ]] ; then
  outfilebasedir=$(dirname $outfile)
  mkdir -p $outfilebasedir
fi

echo you entered values
echo   From infile : $infile
echo   To          : $outfile

# prints one spreadsheet formula for each line read from the input file, for a given spreadsheet range
while read -r line; do
  echo -E "=SUMIF(G1:G"$rowRange",\"="$line"\",F1:F"$rowRange")"
done < $infile

# prints one label for each line read from the input file
while read -r line; do
  echo -E "$line"
done < $infile