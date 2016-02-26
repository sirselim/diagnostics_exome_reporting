#!/bin/bash
#
# Created: 2016/02/19
# Last modified: 2016/02/26
# Author: Miles Benton
#
# Last modified comment: This is not tested and will likely break
# Last modification by: Ray Blick

# """
# This script generates a subset of vcf files defined by supplied gene lists.
# The script accepts 2 arguments: [file name] and [gene list].
#
# E.g. INPUT
# ./wes_vcffiltering.sh /path/to/annotated_sample.vcf.gz genelist.txt
#
# """

#---------------  DEFINE VARS  ---------------
INPUTFILE="$1"
GENELIST="$2"
genelist=$(echo ${GENELIST} | sed 's/.txt//g')
filename=$(echo $INPUTFILE | tr "/ && ." " " | awk '{printf $2}')

# date
DATE=`date +%Y_%m_%d`

# scripts
genelist_prep_sh='/bin/bash gene_lists/./genelist_prep.sh'
vcfcompiler_diagnostics_sh='/bin/bash ./vcfcompiler_diagnostics.sh'

# check for gene filter
[[ -z "$GENELIST" ]] && { echo "...Please provide a disease gene list to filter on..." ; exit 1; }

#---------------  PREPROCESSING  ---------------
## create text file containing software/database version details
echo "...extracting software and database version information..."
zcat vcf/${filename}.vcf.gz | grep '##' | grep 'VEP=v\|SnpSiftV\|file\|source=\|parameters[A-Z]\|tmap\|reference=' > vcf/${filename}_versions.txt

# get vcf header for out files
vcf_header='vcf/vcf_header.txt'
bcftools view -h vcf/${filename}.vcf.gz | tail -n 1 > ${vcf_header}

# remove existing text files if they exist
# Tier_2
if [ -f gene_lists/wes_gene_lists/pathways_list.txt ]; then
    echo "...deleting existing pathways_list.txt"
    rm gene_lists/wes_gene_lists/pathways_list.txt
fi
# Tier_3
if [ -f gene_lists/filtered_list.txt ]; then
    echo "...deleting existing filtered_list.txt"
    rm gene_lists/filtered_list.txt
fi
#Tier 4
#if [ -f gene_lists/Tier_4_list.txt ]; then
#    echo "...deleting existing Tier_4_list.txt"
#    rm gene_lists/Tier_4_list.txt
#fi


#----------------  FUNCTION  ------------------
function diagnostics_exome_reporter () {
    #tier is defined before function call
    # e.g.
    # tier='Tier_1'
    # diagnostics_exome_reporter
    # tier='Tier_2'
    # diagnostics_exome_reporter

    # create variables
    results_path_handle='results/${tier}/${filename}_${tier}_results'


    #--------  CREATE GENES LIST  ---------------
    if [$tier = Tier_1]; then
        ${genelist_prep_sh} ${GENELIST}

    elif [$tier = Tier_2]; then
        for file in gene_lists/wes_gene_lists/*.txt; do
        	tail -n +3 $file >> gene_lists/wes_gene_lists/tmp_list.txt
        done
        sort gene_lists/wes_gene_lists/tmp_list.txt | uniq > gene_lists/wes_gene_lists/pathways_list.txt
        rm gene_lists/wes_gene_lists/tmp_list.txt
        ${genelist_prep_sh} gene_lists/wes_gene_lists/pathways_list.txt

    elif [$tier = Tier_3]; then
        cat gene_lists/test_genes.txt gene_lists/wes_gene_lists/pathways_list.txt | sort | uniq > gene_lists/filtered_list.txt
        ${genelist_prep_sh} gene_lists/filtered_list.txt

    #elif [$tier = Tier_4]; then
        # ...
        # ${genelist_prep_sh} gene_lists/Tier_4_list.txt
    else
        echo "Please enter a valid Tier (e.g. Tier_1, Tier_2 etc...)"
        exit 1
    fi

    #------------  FILTERING  -----------------
    # Filtering message
    echo "Filtering at ${tier}..."

    # assign a grep handle for each tier
    if [$tier = Tier_1]; then
        grep_handle='grep -f ${genelist}_filter.txt'

    elif [$tier = Tier_2]; then
        grep_handle='grep -f gene_lists/wes_gene_lists/pathways_list_filter.txt'

    elif [$tier = Tier_3]; then
        grep_handle='grep -v -f gene_lists/filtered_list_filter.txt'

    #elif [$tier = Tier_4]; then
        # ...grep_handle=

    else
        echo "There appears to be a error assigning a grep_handle"
    fi

    # filter out comments zipped vcf
    zcat vcf/${filename}.vcf.gz | ${grep_handle} | grep -v '##\|#' > ${results_path_handle}.vcf

    # datestamp an unzipped vcf
    cat ${vcf_header} ${results_path_handle}.vcf > ${results_path_handle}_${DATE}.vcf


    #----------------  CLEAN UP  -------------------
    rm ${results_filename_handle}.vcf
    # need to check each of these based on tier name
    if [$tier = Tier_1]; then
        rm results/Tier_1/${genelist}_filter.txt
    elif [$tier = Tier_2]; then
        rm gene_lists/wes_gene_lists/pathways_list_filter.txt
    elif [$tier = Tier_3]; then
        rm gene_lists/filtered_list_filter.txt
    #elif [$tier = Tier_4]; then
    #    rm gene_lists/Tier_4_list.txt.txt
    fi
    # Final clean up
    rm vcf/vcf_header.txt

    #-------------- RUN DIAGNOSTICS  ---------------
    ${vcfcompiler_diagnostics_sh} ${results_path_handle}.vcf
    echo "...filtering done..."
}
