#!/bin/bash

tempFile="$1"
cat "$tempFile" | sed 's_.*/__' | sort |  uniq -d| 
while read fileName
do
    grep "/$fileName" $tempFile
done