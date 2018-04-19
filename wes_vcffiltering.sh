#!/bin/bash
#
# Created: 2016/02/19
# Last modified: 2018/04/20
# Author: Miles Benton
#
# """
# This script generates a subset of vcf files defined by supplied gene lists.
# The script accepts 3 arguments: [file name], [diagnostic_panel] and [gene list].
#
# E.g. INPUT
# ./wes_vcffiltering.sh /path/to/annotated_sample.vcf.gz gene_list/diagnostic_panel.txt gene_list/genelist.txt
#
# """

# define the sample being processed
# INPUTFILE="$1"	# annotated vcf file
INPUTFILE=$(ls -d vcf/* | grep "_dbSNP_VEP_dbNSFP.vcf.gz$")
filename=$(echo "$INPUTFILE" | tr "/ && ." " " | awk '{printf $2}')

# date
DATE=$(date +%Y_%m_%d)

# check for gene filter
[[ -z "$TIER0LIST" ]] && { echo "...Please provide a Tier0 gene list to fiter on..." ; exit 1; }
[[ -z "$TIER1LIST" ]] && { echo "...Please provide a Tier1 gene list to filter on..." ; exit 1; }
[[ -z "$TIER2LIST" ]] && { echo "...Please provide a Tier2 gene list to filter on..." ; exit 1; }

# start filtering
echo "...starting filtering of sample $filename..."

## create text file containing software/database version details
echo "...extracting software and database version information..."
zcat vcf/"$filename".vcf.gz | grep '##' | grep 'VEP=\|SnpSiftV\|file\|source=\|parameters[A-Z]\|tmap\|reference=' > vcf/"$filename"_versions.txt

# get vcf header for out files
"$BCFTOOLS" view -h vcf/"$filename".vcf.gz | tail -n 1 > vcf/vcf_header.txt

## Tier 0 Genes
# tier 0 filtering
echo "...filtering at tier 0 specfic genes..."
### modified tabix version
# replace grep filtering with tabix for speed
zcat Homo_sapiens.GRCh37.87.genes.bed.gz | grep -w -f "$TIER0LIST" | sort -k 1,1V -k2,2n -k3,3n > gene_lists/tier0_gene_regions.txt
"$TABIX" -R gene_lists/tier0_gene_regions.txt vcf/"$filename".vcf.gz > results/Tier_0/"$filename"_Tier_0_results.vcf
# add header back for processing
cat vcf/vcf_header.txt results/Tier_0/"$filename"_Tier_0_results.vcf > results/Tier_0/"$filename"_Tier_0_results_"$DATE".vcf
### ----------------------
# clean up
rm results/Tier_0/"$filename"_Tier_0_results.vcf
rm gene_lists/tier0_gene_regions.txt
# rm ${diagnosticGenes}_filter.txt 
# extract info for report and save as csv
/bin/bash ./vcfcompiler_diagnostics.sh results/Tier_0/"$filename"_Tier_0_results_"$DATE".vcf
# run Rscript to generate 'clean' csv output
/usr/bin/Rscript ExomeTableClean.R  results/Tier_0/"$filename"_Tier_0_results_"$DATE".csv

## Tier 1 Genes
# tier 1 filtering
echo "...filtering at tier 1 specific genes..."
### modified tabix version
# replace grep filtering with tabix for speed
zcat Homo_sapiens.GRCh37.87.genes.bed.gz | grep -w -f "$TIER1LIST" | sort -k 1,1V -k2,2n -k3,3n > gene_lists/tier1_gene_regions.txt
"$TABIX" -R gene_lists/tier1_gene_regions.txt vcf/"$filename".vcf.gz > results/Tier_1/"$filename"_Tier_1_results.vcf
# add header back for processing
cat vcf/vcf_header.txt results/Tier_1/"$filename"_Tier_1_results.vcf > results/Tier_1/"$filename"_Tier_1_results_"$DATE".vcf
### ----------------------
# clean up
rm results/Tier_1/"$filename"_Tier_1_results.vcf
rm gene_lists/tier1_gene_regions.txt
# rm ${genelist}_filter.txt 
# extract info for report and save as csv
/bin/bash ./vcfcompiler_diagnostics.sh results/Tier_1/"$filename"_Tier_1_results_"$DATE".vcf
# run Rscript to generate 'clean' csv output
/usr/bin/Rscript ExomeTableClean.R results/Tier_1/"$filename"_Tier_1_results_"$DATE".csv

## Tier 2 Genes
####
## commenting out this code while implementing user defined selection for this tier
## generation of this specific pathways gene list moved to separte GitHub repo
# generate combined pathways gene list
# remove previous versions
# if [ -f gene_lists/wes_gene_lists/pathways_list.txt ]; then
#     echo "...deleting existing pathways_list.txt"
#     rm gene_lists/wes_gene_lists/pathways_list.txt
# fi
# #	
# for file in gene_lists/wes_gene_lists/*.txt; do
# 	tail -n +3 "$file" >> gene_lists/wes_gene_lists/tmp_list.txt
# done
# sort gene_lists/wes_gene_lists/tmp_list.txt | uniq > gene_lists/wes_gene_lists/pathways_list.txt
# grep -f gene_lists/filter_from_pathways.txt gene_lists/wes_gene_lists/pathways_list.txt -v > gene_lists/wes_gene_lists/tmp_list.txt
# mv gene_lists/wes_gene_lists/tmp_list.txt gene_lists/wes_gene_lists/pathways_list.txt
## remove upon successful deployment
####
# tier 2 filtering
echo "...filtering at tier 2 specific genes..."
# replace grep filtering with tabix for speed
zcat Homo_sapiens.GRCh37.87.genes.bed.gz | grep -w -f "$TIER2LIST" | sort -k 1,1V -k2,2n -k3,3n > gene_lists/tier2_gene_regions.txt
"$TABIX" -R gene_lists/tier2_gene_regions.txt vcf/"$filename".vcf.gz > results/Tier_2/"$filename"_Tier_2_results.vcf
# add header back for processing
cat vcf/vcf_header.txt results/Tier_2/"$filename"_Tier_2_results.vcf > results/Tier_2/"$filename"_Tier_2_results_"$DATE".vcf
# clean up 
rm results/Tier_2/"$filename"_Tier_2_results.vcf
rm gene_lists/tier2_gene_regions.txt
# extract info for report and save as csv
/bin/bash ./vcfcompiler_diagnostics.sh results/Tier_2/"$filename"_Tier_2_results_"$DATE".vcf
# run Rscript to generate 'clean' csv output
/usr/bin/Rscript ExomeTableClean.R results/Tier_2/"$filename"_Tier_2_results_"$DATE".csv

## Tier 3: All Other Genes/Variants
# create list of all other genes
# combine the previously used filter lists and inverse grep
# remove previous versions
if [ -f gene_lists/filtered_list.txt ]; then
    echo "...deleting existing filtered_list.txt"
    rm gene_lists/filtered_list.txt
fi
#	
cat "$TIER0LIST" "$TIER1LIST" "$TIER2LIST" | sort | uniq > gene_lists/filtered_list.txt
# tier 3 filtering
echo "...filtering at tier 3 - all other genes..."
# replace grep filtering with tabix for speed, take inverse here to get remaining genes/variants
zcat Homo_sapiens.GRCh37.87.genes.bed.gz | grep -w -v -f gene_lists/filtered_list.txt | sort -k 1,1V -k2,2n -k3,3n > gene_lists/remaining_variant_regions.txt
"$TABIX" -R gene_lists/remaining_variant_regions.txt vcf/"$filename".vcf.gz > results/Tier_3/"$filename"_Tier_3_results.vcf
# add header back for processing
cat vcf/vcf_header.txt results/Tier_3/"$filename"_Tier_3_results.vcf > results/Tier_3/"$filename"_Tier_3_results_"$DATE".vcf
# clean up
rm results/Tier_3/"$filename"_Tier_3_results.vcf
rm gene_lists/remaining_variant_regions.txt
# extract info for report and save as csv
/bin/bash ./vcfcompiler_diagnostics.sh results/Tier_3/"$filename"_Tier_3_results_"$DATE".vcf
# run Rscript to generate 'clean' csv output
/usr/bin/Rscript ExomeTableClean.R results/Tier_3/"$filename"_Tier_3_results_"$DATE".csv

# ## Tier 4: Polymorphisms
# # tier 4 filtering
# echo "...filtering at tier 4: Polymorphisms..."
# zcat vcf/"$filename".vcf.gz | grep -f gene_lists/test_genes.txt | grep -v '##\|#' > results/Tier_4/"$filename"_Tier_4_results.vcf
# cat vcf/vcf_header.txt results/Tier_4/"$filename"_Tier_4_results.vcf > results/Tier_4/"$filename"_Tier_4_results_"$DATE".vcf
# # clean up
# rm results/Tier_4/"$filename"_Tier_4_results.vcf
# # extract info for report and save as csv
# /bin/bash ./vcfcompiler_diagnostics.sh results/Tier_4/"$filename"_Tier_4_results_"$DATE".vcf

# final clean
rm vcf/vcf_header.txt

echo "...filtering done..."