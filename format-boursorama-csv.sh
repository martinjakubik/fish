#!/bin/bash

WORK_FILE=~/Downloads/export-operations-test-0.csv

cp ~/Downloads/export-operations-test.csv $WORK_FILE

sed -e '1,$s/,/./g' -i '.bak' $WORK_FILE
sed -e '1,$s/;/,/g' -i '.bak' $WORK_FILE
sed -e '1,$s/\([0-9]\) \([0-9]\)/\1\2/g' -i '.bak' $WORK_FILE
