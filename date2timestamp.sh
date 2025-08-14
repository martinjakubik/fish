#!/bin/sh

# Expects a date string like "Wed 05 Jul 2023 04:55:30 PM +03" as first parameter.
# Evaluate if it's AM or PM
# remove the "AM/PM" string
# and set the time correction for the missing "PM" if necessary.

if [ "${1%?PM}"  !=  "${1}" ]; then
    timestamp_format=$(( $(date -j -f "%b %e, %Y, %l:%M:%S" "${1%?PM}" "+%s") + 43200 ))
else
    timestamp_format=$(date -j -f "%b %e, %Y, %l:%M:%S" "${1%?AM}" "+%s")
fi

date -r $timestamp_format +%Y-%m-%dT%H:%M:%S