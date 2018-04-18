#!/bin/bash
#
# Created: 2016/04/04
# Last modified: 2018/04/19
# Author: Miles Benton
#
# """
# This script forms the start of the diagnostic WES pipeline, finding the most damaging muations and 
# generating MutationAssessor html links for them.
#
# E.g. INPUT
# ./assess_variants.sh sample_file.vcf.gz genome_build
#
# """

## Notes:
# write a script that generates html links for variants listed as MutationAssessor_pred=H (high prediction to cause damage)
# here is the url structure required:
# http://mutationassessor.org/r3/?cm=var&var=<GENOME_BUILD>,<CHR>,<POSITION>,<REF>,<ALT>&fts=all
# real example html link 
# http://mutationassessor.org/r3/?cm=var&var=hg19,1,201046184,A,G&fts=all
## 

# define the sample being processed
# INPUTFILE="$1"  # now defined initially
# INPUTFILE="$sampleID"
# GENOME_BUILD="$2"   # now defined initially

# filename=$(echo "$INPUTFILE" | tr "/ && ." " " | tr "_" " " | awk '{printf $2}')
echo "...starting annotation of sample $filename..."
# date
DATE=$(date +%Y_%m_%d)

OUTFILE=$(paste <(echo "$filename") <(echo "MutationAssessor_links") <(echo "$DATE") -d '_')
OUTFILE=$(paste <(echo results/mutation_links/) <(echo "$OUTFILE") <(echo ".txt") -d '')

# create output file or delete contents if it exists
if [ -f "$OUTFILE" ]; then
    echo "csv file found... deleting its contents!"
    cat /dev/null > "$OUTFILE"
else
    echo "output csv file created"
    > "$OUTFILE"
fi

# add header to csv file (i.e. write one line)
header=$(paste <(echo "GENOME_BUILD") \
				<(echo "CHR") \
                <(echo "POSITION") \
                <(echo "REF") \
                <(echo "ALT") \
                <(echo "RSNO") \
                <(echo "GENESYM") \
                <(echo "DP_coverage") \
                <(echo "URL") \
                --delimiters '\t')
echo "$header" >> "$OUTFILE"

# check for variables
[[ -z "$INPUTFILE" ]] && { echo "...Please provide a vcf file to analyse..." ; exit 1; }
[[ -z "$GENOME_BUILD" ]] && { echo "...Please provide a genome build (i.e. hg19, hg38, ...)..." ; exit 1; }

echo "...You are using $GENOME_BUILD..."

# extract all variants considered 'damaging' under Mutation Assessor and Mutation Taster
zcat "$INPUTFILE" | grep 'MutationAssessor_pred=H' | grep 'MutationTaster_pred=D\|MutationTaster_pred=A' | grep -P ';DP=[0-9]{1,}' > tmp_variants.txt

VARNO=$(wc -l tmp_variants.txt | awk '{print $1}')

GENOME_BUILD=$(for (( c=1; c<="$VARNO"; c++)) ; do echo "$GENOME_BUILD" ; done)

echo "...identified $VARNO variants that are MutationAssessor and MutationTaster damaging..."

# chromosome
CHR=$(awk '{print $1}' tmp_variants.txt | sed -e 's/^chr//g')
# echo "$CHR"
# position info
POSITION=$(awk '{print $2}' tmp_variants.txt)
POSITION=$(echo "$POSITION")
# ref geno
REF=$(awk '{print $4}' tmp_variants.txt)
# echo "$REF"
# alt geno
ALT=$(awk '{print $5}' tmp_variants.txt)
# echo "$ALT"
# get rs id (if present)
RSNO=$(cut -f 3 tmp_variants.txt)
# get coverage
DP_coverage=$(sed 's/^.*;DP=//' tmp_variants.txt | tr ";" " " | awk '{print $1}')
# extract gene symbol
gene_symbol=$(sed -e 's/^.*GENEINFO=//' tmp_variants.txt | tr "| && :" " " | awk '{print $1}' | sed -e 's/chr.*/./g')
gene_symbol2=$(sed -e 's/^.*GENE=//' tmp_variants.txt | tr "| && :" " " | awk '{print $1}' | sed -e 's/chr.*/./g')
GENESYM=$(paste -d' ' <(echo "$gene_symbol" | tr ' ' '\n') <(echo "$gene_symbol2" | tr ' ' '\n') | tr " " ";")

# generate url to Mutation Assessor
URL1=$(for (( c=1; c<="$VARNO"; c++)) ; do echo "http://mutationassessor.org/r3/?cm=var&var=" ; done)
URL2=$(for (( c=1; c<="$VARNO"; c++)) ; do echo "&fts=all" ; done)
URL3=$(paste <(echo "$GENOME_BUILD") <(echo "$CHR") <(echo "$POSITION") <(echo "$REF") <(echo "$ALT") -d ',')
URL=$(paste <(echo "$URL1") <(echo "$URL3") <(echo "$URL2") -d '')

# clean up
rm tmp_variants.txt

# create output
dataset=$(paste <(echo "$GENOME_BUILD") \
				<(echo "$CHR") \
                <(echo "$POSITION") \
                <(echo "$REF") \
                <(echo "$ALT") \
                <(echo "$RSNO") \
                <(echo "$GENESYM") \
                <(echo "$DP_coverage") \
                <(echo "$URL") \
                    --delimiters '\t')
echo "$dataset" >> "$OUTFILE"