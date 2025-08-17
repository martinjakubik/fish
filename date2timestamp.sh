#!/bin/sh

# expects a date string like "Jan 1, 1950, 6:04:00 PM UTC" as first parameter.
# evaluates if it's AM or PM
# removes the "AM/PM" string
# and sets the time correction for the missing "PM" if necessary.

echo stripping PM: "${1%?PM UTC}"
if [ "${1%?PM UTC}" != "${1}" ]; then
    echo it is PM
    timestamp_format=$(( $(date -j -f "%b %e, %Y, %l:%M:%S" "${1%?PM UTC}" "+%s") + 43200 ))
else
    echo it is AM
    timestamp_format=$(date -j -f "%b %e, %Y, %l:%M:%S" "${1%?AM UTC}" "+%s")
fi

date -r $timestamp_format +%Y-%m-%dT%H:%M:%S