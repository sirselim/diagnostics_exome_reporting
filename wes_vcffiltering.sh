#!/bin/bash
#
# Created: 2016/02/19
# Last modified: 2019/11/11
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
INPUTFILE=$(ls vcf/ | grep "_dbSNP_VEP_dbNSFP.vcf.gz$")
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

## Tier 0 Genes - filtering
echo "...filtering at tier 0 specfic genes..."
# replace grep filtering with tabix for speed
# zcat Homo_sapiens.GRCh37.87.genes.bed.gz | grep -w -f "$TIER0LIST" | sort -k 1,1V -k2,2n -k3,3n > gene_lists/tier0_gene_regions.txt
# added an awk filter to convert windows encoding if present 
zcat Homo_sapiens.GRCh37.87.genes.bed.gz | grep -w -f <(awk '{ sub("\r$", ""); print }' "$TIER0LIST") | sort -k 1,1V -k2,2n -k3,3n > gene_lists/tier0_gene_regions.txt
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

## Tier 1 Genes - filtering 
echo "...filtering at tier 1 specific genes..."
# replace grep filtering with tabix for speed
# zcat Homo_sapiens.GRCh37.87.genes.bed.gz | grep -w -f "$TIER1LIST" | sort -k 1,1V -k2,2n -k3,3n > gene_lists/tier1_gene_regions.txt
# added an awk filter to convert windows encoding if present 
zcat Homo_sapiens.GRCh37.87.genes.bed.gz | grep -w -f <(awk '{ sub("\r$", ""); print }' "$TIER1LIST") | sort -k 1,1V -k2,2n -k3,3n > gene_lists/tier1_gene_regions.txt
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

## Tier 2 Genes - filtering 
echo "...filtering at tier 2 specific genes..."
# replace grep filtering with tabix for speed
# zcat Homo_sapiens.GRCh37.87.genes.bed.gz | grep -w -f "$TIER2LIST" | sort -k 1,1V -k2,2n -k3,3n > gene_lists/tier2_gene_regions.txt
# added an awk filter to convert windows encoding if present 
zcat Homo_sapiens.GRCh37.87.genes.bed.gz | grep -w -f <(awk '{ sub("\r$", ""); print }' "$TIER2LIST") | sort -k 1,1V -k2,2n -k3,3n > gene_lists/tier2_gene_regions.txt
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

## Tier 3 Genes - All Other Genes/Variants filtering
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

# final clean
rm vcf/vcf_header.txt

echo "...filtering done..."
##/END
