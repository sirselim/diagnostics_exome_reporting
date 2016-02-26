#!/bin/bash
#
# Created: 2016/02/10
# Last modified: 2016/02/23
# Authors: Ray Blick, Miles Benton
# Version: 0.2
# This is a major re-write of the basic script format, replaced while read; do loop 
# to greatly increase processing speed. 
#
# """
# This script pulls out information from vcf files.
# The script accepts 1 argument (file name).
#
# E.g. INPUT
# ./vcfcompiler_diagnostics.sh /path/to/initial_filter.vcf
#
# The output is a csv file named after the vcf
# WARNING: if the csv file already exists, this script will REPLACE ALL OF ITS CONTENT
# E.g. OUTPUT
# initial_filter.csv
# """

# create variables
INPUTFILE="$1"
OUTPUT_DIRECTORY="$( dirname "$INPUTFILE" )"
OUTPUT_FILE_NAME=$(echo "${INPUTFILE##*/}" | grep -oP '.*?(?=\.)')
OUTFILE=$(paste <(echo "$OUTPUT_DIRECTORY") <(echo "$OUTPUT_FILE_NAME") --delimiters '\/')
OUT_CSV_FILE=$(paste <(echo "$OUTFILE") <(echo ".csv") --delimiters '')

# create output file or delete contents if it exists
if [ -f $OUT_CSV_FILE ]; then
    echo "csv file found... deleting its contents!"
    cat /dev/null > $OUT_CSV_FILE
else
    echo "output csv file created"
    > $OUT_CSV_FILE
fi

# add header to csv file (i.e. write one line)
header=$(paste <(echo "chromosome") \
                <(echo "position") \
                <(echo "id") \
                <(echo "reference_allele") \
                <(echo "alternate_allele") \
                <(echo "genotype") \
                <(echo "QUAL") \
                <(echo "depth_coverage") \
                <(echo "Ref_coverage") \
                <(echo "Alt_coverage") \
                <(echo "CAF1") \
                <(echo "CAF2") \
                <(echo "variant_type") \
                <(echo "gene") \
                <(echo "transcript") \
                <(echo "coding") \
                <(echo "amino_acid_substitution") \
                <(echo "MutationTaster") \
                <(echo "SIFT") \
                <(echo "Polyphen2") \
                --delimiters '\t')
echo "$header" >> $OUT_CSV_FILE

# define all the variables to output
chrom=$(sed 1d $INPUTFILE | cut -f 1)
pos=$(sed 1d $INPUTFILE | cut -f 2)
id=$(sed 1d $INPUTFILE | cut -f 3)
ref=$(sed 1d $INPUTFILE | cut -f 4)
alt=$(sed 1d $INPUTFILE | cut -f 5)
qual=$(sed 1d $INPUTFILE | cut -f 6)
DP_coverage=$(sed '1d; s/^.*;DP=//' $INPUTFILE | tr ";" " " | awk '{print $1}')
REF_coverage=$(sed '1d; s/^.*;RO=//' $INPUTFILE | tr ";" " " | awk '{print $1}')
ALT_coverage=$(sed '1d; s/^.*;AO=//' $INPUTFILE | tr ";" " " | awk '{print $1}')
GENO=$(grep -oP '[0-3]/[0-3]:' $INPUTFILE | sed -e 's/://g')    # genotype, will have to convert to letters in R
CAF1=$(sed '1d; s/^.*;CAF=//' $INPUTFILE | tr ";" " " | awk '{print $1}' | sed -e 's/chr.*/./g' | tr "," " " | awk '{print $1}') 
CAF2=$(sed '1d; s/^.*;CAF=//' $INPUTFILE | tr ";" " " | awk '{print $1}' | sed -e 's/chr.*/./g' | tr "," " " | awk '{print $2}' | sed -e 's/^$/./g')
variant_type=$(sed '1d; s/^.*CSQ=//' $INPUTFILE |  tr "|" " " | awk '{print $2}')        # get variant type from VEP data
# get dbSNP gene symbol (only viable if an rs number is assigned) and extra gene info
gene_symbol=$(sed -e '1d; s/^.*GENEINFO=//' $INPUTFILE | tr "| && :" " " | awk '{print $1}' | sed -e 's/chr.*/./g')
gene_symbol2=$(sed -e '1d; s/^.*GENE=//' $INPUTFILE | tr "| && :" " " | awk '{print $1}' | sed -e 's/chr.*/./g')
genes=$(paste -d' ' <(echo $gene_symbol| tr ' ' '\n') <(echo $gene_symbol2|tr ' ' '\n') | tr " " ";")
# future work to tidy the above
coding=$(tail -n +2 $INPUTFILE | tr "| && :" " " | gawk --re-interval '{ printf "." ; for ( i = 2 ; i <= NF ; i ++ ) { if ( $i ~ /c\.[A-Z0-9]{2,}[A-Z]/ ) { printf $i ";" } } printf "\n" }' | sed -e 's/^.c/c/g')
amino_acid_substitution=$(tail -n +2 $INPUTFILE | tr "| && :" " " | gawk --re-interval '{ printf "." ; for ( i = 2 ; i <= NF ; i ++ ) { if ( $i ~ /p\.[A-Za-z0-9]{3,}/ ) { printf $i ";" } } printf "\n" }' | sed -e 's/^.p/p/g')
transcript=$(sed '1d; s/^.*Transcript|//' $INPUTFILE | tr "; && |" " " | awk '{print $1}') 
MutationTaster=$(sed '1d; s/^.*MutationTaster_pred=//' $INPUTFILE | tr "; && |" " " | awk '{print $1}' | sed -e 's/chr.*/./g')
SIFT=$(sed '1d; s/^.*SIFT_pred=//' $INPUTFILE | tr "; && |" " " | awk '{print $1}' | sed -e 's/chr.*/./g')
Polyphen2=$(sed '1d; s/^.*Polyphen2_HDIV_pred=//' $INPUTFILE | tr "; && |" " " | awk '{print $1}' | sed -e 's/chr.*/./g')

dataset=$(paste <(echo "$chrom") \
                <(echo "$pos") \
                <(echo "$id") \
                <(echo "$ref") \
                <(echo "$alt") \
                <(echo "$GENO") \
                <(echo "$qual") \
                <(echo "$DP_coverage") \
                <(echo "$REF_coverage") \
                <(echo "$ALT_coverage") \
                <(echo "$CAF1") \
                <(echo "$CAF2") \
                <(echo "$variant_type") \
                <(echo "$genes") \
                <(echo "$transcript") \
                <(echo "$coding") \
                <(echo "$amino_acid_substitution") \
                <(echo "$MutationTaster") \
                <(echo "$SIFT") \
                <(echo "$Polyphen2") \
                    --delimiters '\t')
echo "$dataset" >> $OUT_CSV_FILE
