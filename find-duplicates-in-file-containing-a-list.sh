#!/bin/bash

elementList="$1"
cat "$elementList" | sed 's_.*/__' | sort |  uniq -d| 
while read elementName
do
    grep "/$elementName" $elementList
done