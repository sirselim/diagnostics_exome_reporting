#!/bin/bash
#
# Created: 2016/02/25
# Last modified: 2016/02/29
# Author: Miles Benton
# Version: 0.1
#
# """
# This script adds strict strings to gene lists to allow exact grep functionality.
# The script accepts 1 argument (file name).
#
# E.g. INPUT
# ./genelist_prep.sh /path/to/gene_list.txt
# """

# create variables
INPUTFILE="$1"
OUTPUT_DIRECTORY="$( dirname "$INPUTFILE" )"
OUTPUT_FILE_NAME=$(echo "${INPUTFILE##*/}" | grep -oP '.*?(?=\.)')
OUTFILE=$(paste <(echo "$OUTPUT_DIRECTORY") <(echo "$OUTPUT_FILE_NAME") --delimiters '\/')
OUT_CSV_FILE=$(paste <(echo "$OUTFILE") <(echo "_filter.txt") --delimiters '')

# create output file or delete contents if it exists
if [ -f "$OUT_CSV_FILE" ]; then
    echo "csv file found... deleting its contents!"
    cat /dev/null > "$OUT_CSV_FILE"
else
    echo "output csv file created"
    > "$OUT_CSV_FILE"
fi

genelist_filter1=$(awk '{print "|"$1"|"}' "$INPUTFILE")
genelist_filter2=$(awk '{print "GENE="$1""}' "$INPUTFILE")
genelist_filter3=$(awk '{print "GENEINFO="$1":"}' "$INPUTFILE")

finallist=$(cat <(echo "$genelist_filter1") \
				<(echo "$genelist_filter2") \
				<(echo "$genelist_filter3"))

echo "$finallist" >> "$OUT_CSV_FILE"