#!/bin/bash

# This script will be placed in a directory in nfs server:/dockerdata-nfs/

COMPONENTS=$(ls -al | awk '{print $9}')
COUNT=1

sudo du -hs .
for c in $COMPONENTS; do
	#echo "$COUNT: $c"
	#((COUNT++))
	sudo du -hs $c
done
