#!/bin/bash
#
# Created: 2018/04/11
# Last modified: 2018/04/20
# Author: Miles Benton
#
# """
# This script was created to automate the module scripts from the WES reporting pipeline.
# It first asks the user for required information, seeks confirmation to proceed, and then
# runs through all pipeline scripts to completion. The latest update has added a Shiny GUI
# which takes user input and writes variables to a file which bash then accepts. 
# """

## move into script directory
cd "$(dirname "$0")"

## LOGGING
# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee -i WES_pipeline_run.log)
exec 2>&1
Everything below will go to the file 'WES_pipeline_run.log':
##

## [0] required user input
echo "############################################################################"
echo "## GRC Whole Exome Sequencing Annotation Filtering and Reporting Pipeline ##"
echo "############################################################################"
# set up time and date
RUNTIME=$(date +"%H:%M:%S")
RUNTIME_START=$(date +"%H:%M:%S" | awk -F: '{print ($1 * 3600) + ($2 * 60) + $3 }')
DATE=$(date +"%m-%d-%Y")
echo "## DATE: $DATE"
echo "## Run started: $RUNTIME"
# provide user name
USERNAME=$(sed '1q;d' pipeline_input.txt)
echo "Run initiated by: $USERNAME"
echo ""
# define specific variables from user input (R Shiny)
sampleID=$(sed '2q;d' pipeline_input.txt)
LABELID=$(sed '3q;d' pipeline_input.txt)
RUNID=$(sed '4q;d' pipeline_input.txt)
GENOME_BUILD=$(sed '5q;d' pipeline_input.txt)
TIER0LIST=$(sed '6q;d' pipeline_input.txt)
TIER1LIST=$(sed '7q;d' pipeline_input.txt)
TIER2LIST=$(sed '8q;d' pipeline_input.txt)
sampleDIR=$(sed '9q;d' pipeline_input.txt)
# overview variables for confirmation
echo "## You have entered the following details: "
echo "sampleID: $sampleID "
echo "Label (i.e. barcode): $LABELID "
echo "runID: $RUNID"
echo "genome: $GENOME_BUILD "
echo "Tier0 gene list: $TIER0LIST "
echo "Tier1 gene list: $TIER1LIST "
echo "Tier2 gene list: $TIER2LIST "
echo "Directory for analysis: $sampleDIR "
## removed user check (relied on xmessage thus X11 env)
# ask for confirmation before proceedingChoo2geez=ai0g
# can remove this eventually but retaining as sanity check for now
# echo ""
# # added a graphical prompt for user check
# xmessage -center -buttons Yes,No -default No -center "Are these details correct and do you wish to proceed?"
# ans="$?"
# if [[ "$ans" == 101 ]]; then
#        :;
# else
#     exit;
# fi
# commandline user check 
#echo "## Are these correct and do you wish to proceed?"
#select yn in "Yes" "No"; do
#    case $yn in
#        Yes ) echo "...continuing with WES pipeline..."; break;;
#        No ) echo "...exiting WES pipline script..."; exit;;
#    esac
#done
echo ""
##/END define variables 


## [1] directory and file setup
# 
# """
# This script sets up the directory structure and pipeline scripts required for analysis and reporting.
# """
echo "############################################################################"
echo "################# Setting up directory and pipeline files ##################"
echo "############################################################################"
# warn if no sampleID is provided
[[ -z "$sampleID" ]] && { echo "...Please provide a WES sampleID..." ; exit 1; }
# check for existing directory before creating
if [ -d "$sampleDIR" ]
then
    echo "ERROR: Directory already exists, quitting out. Please define a unique directory." ; exit 1
else
    mkdir "$sampleDIR"
fi
# extract/clone pipeline into created directory
echo "...cloning and extracting latest pipeline scripts and directories from GitHub..."
# tar -C "$sampleDIR" -xzf GRC_wes_pipeline_files.tar.gz
# replaced tar.gz with private GitHub repository for more detailed versioning 
# git clone git@github.com:sirselim/diagnostics_exome_reporting.git "$sampleDIR"
## testing the feature branch
git clone git@github.com:sirselim/diagnostics_exome_reporting.git --branch user-defined-tiers --single-branch "$sampleDIR"
##
# capture vcf and quality information files from 'raw' directory
echo "...transfering required files..."
# define the label and .vcf.gz string to narrow search
IONLABEL=$(paste -d'.' <(echo "$LABELID") <(echo 'vcf.gz'))
echo "$IONLABEL"
# 
if ls -d ./raw_wes_files/* | grep "$sampleID" | grep -q "$IONLABEL"; then
    VCFFILE=$(ls -d ./raw_wes_files/* | grep "$sampleID" | grep "$IONLABEL")
    echo "...found vcf file: $VCFFILE..."
else
    echo "...no match for vcf.gz file, please check that the sampleID and IonExpress Label are correct and match..."
    RUNTIME=$(date +"%H:%M:%S")
	DATE=$(date +"%m-%d-%Y")
	echo "...outputting log file..."
	LOGFILE=$(ls *.log)
	LOGOUT=$(paste -d'_' <(echo "$sampleID") <(echo "$LOGFILE"))
	mv "$LOGFILE" "$LOGOUT"
	mv "$LOGOUT" "$sampleDIR"
	echo "...Pipeline run of $sampleID terminated on $DATE at $RUNTIME due to mismatch..."
    exit $?
fi
# find the coverage file
# there is an issue of the quality files not having IonExpress Label informaiton
# if there are txt files for the same sample then we have a problem
TXTfile=$(ls -d ./raw_wes_files/* | grep "$sampleID" | grep '.txt')
echo "...found quality information file: $TXTfile..."
## removed user check (relied on xmessage thus X11 env)
# check once again that this is the correct sample and file
# ask for confirmation before proceeding
# ECHO ""
# XMESSAGE -CENTER -BUTTONS YES,NO -DEFAULT NO -CENTER "IS THIS THE CORRECT FILE - $VCFFILE - AND DO YOU WISH TO PROCEED?"
# ANS="$?"
# IF [[ "$ANS" == 101 ]]; THEN
#        ECHO "...CONTINUING WITH WES PIPELINE..."; :;
# ELSE
#    ECHO "...EXITING WES PIPLINE SCRIPT..."; RM -R "$SAMPLEDIR"; EXIT;
# FI
#echo "## Is this the correct file - $VCFFILE - and do you WISH to proceed?"
#select yn in "Yes" "NO"; do
#    case $yn in
#        Yes ) echo "...continuing with WES pipeline..."; break;;
#        No ) echo "...exiting WES pipline script..."; rm -R "$sampleDIR"; exit;;
#    esac
#done
echo ""
# copy these to correct location within sample directory
# copy vcf file
cp "$VCFFILE" "$sampleDIR"/vcf/
# copy quality statistics file
cp "$TXTfile" "$sampleDIR"/coverage_stats/
# message
echo "...setup complete..."
cd "$sampleDIR"
echo "...moving to VCF annotation..."
echo ""
echo ""
##/END [1]

## [2] vcf file annotation
#
# """
# This script forms the start of the diagnostic WES pipeline, annotating vcf files with various databases.
# """
# set perl locale
export LC_ALL=C
##
# source configuration file to set software and database paths
# users should edit configuration.sh accordingly
echo "...reading in configuration options..."
. ./configuration.sh
echo ""
##
echo "############################################################################"
echo "###################### Performing VCF file annotation ######################"
echo "############################################################################"
# define the sample being processed
INPUTFILE=$(ls -d vcf/* | grep "$sampleID" | grep "$LABELID" | grep '.vcf.gz')
filename=$(echo "$INPUTFILE" | tr "/ && ." " " | awk '{printf $2}')
# sort vcf file by chrom position (faster for VEP annotation) and index
# message
echo "...sorting and indexing VCF file of sample $filename..."
echo ""
"$VCFSORT" -c vcf/"$filename".vcf.gz | "$BGZIP" -c > tmp.vcf.gz
mv tmp.vcf.gz vcf/"$filename".vcf.gz
"$TABIX" vcf/"$filename".vcf.gz
#
# message
echo "...starting annotation of sample $filename..."
echo ""
## add dbSNP info (rs ID, CAF etc)
echo "############################################################################"
echo "####################### dbSNP information annotation #######################"
echo "############################################################################"
echo "...annotating with dbSNP..."
java -jar "$SNPSIFT" annotate "$DBSNP_DATA" vcf/"$filename".vcf.gz > vcf/"$filename"_dbSNP.vcf
## annotate with VEP
echo ""
echo "############################################################################"
echo "############################## VEP annotation ##############################"
echo "############################################################################"
echo "...annotating with VEP..."
perl "$VEP" --assembly GRCh37 --fasta "$FASTA_REF" --cache --merged -i vcf/"$filename"_dbSNP.vcf --offline --stats_text --everything -o vcf/"$filename"_dbSNP_VEP.vcf --vcf --dir "$VEP_DATA" --fork "$THREADS" --force_overwrite
## SNPSift dbNSFP
echo ""
echo "############################################################################"
echo "############################ dbNSFP annotation #############################"
echo "############################################################################"
echo "...annotating with SnpSift dbNSFP..."
# split on chr
# can greatly speed up the process by first splitting the vcf 
java -jar "$SNPSIFT" split vcf/"$filename"_dbSNP_VEP.vcf
# create list of chr vcf files
find vcf/"$filename"_dbSNP_VEP.chr* -maxdepth 1 -type f -printf '%f\n' > chr_list.txt
# run in parallel
cat chr_list.txt | parallel -j "$THREADS" 'java -jar '$SNPSIFT' dbnsfp -v -db '$DBNSFP' vcf/{} > vcf/test_{}'
# join them back together
java -jar "$SNPSIFT" split -j vcf/test_* > vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf
# clean up
rm chr_list.txt
rm vcf/test_*
rm vcf/*.chr*
## NOTE: this section needs feature devleopment
## only available when annotating against hg38 
## SNPSift gwascatalog
# java -jar "$SNPSIFT" gwasCat -db /data/all/dbNSFP/gwascatalog/gwascatalog.txt vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf > vcf/"$filename"_dbSNP_VEP_dbNSFP_gwas.vcf
# this only seems to be annotated at hg38 level
## bgzip step to compress
echo "...compressing to vcf.gz..."
"$BGZIP" -c vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf > vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf.gz
"$TABIX" -p vcf vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf.gz
# add additional GENE annotation to INFO (currently only hg19)
echo ""
echo "############################################################################"
echo "######################### custom gene annotation ###########################"
echo "############################################################################"
"$BCFTOOLS" annotate -a UCSC_wholegenes.bed.gz -c CHROM,FROM,TO,GENE -h <(echo '##INFO=<ID=GENE,Number=1,Type=String,Description="Gene symbol">') vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf.gz > vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf
"$BGZIP" -c vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf > vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf.gz
"$TABIX" -p vcf vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf.gz
# final clean up
rm vcf/"$filename"_dbSNP.vcf
rm vcf/"$filename"_dbSNP_VEP.vcf
rm vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf
# message
echo "...annotation done..."
echo "...moving on to filtering..."
echo ""
echo ""
##/END [2]


## [3] filtering vcf files prior to reporting
# call upon ./wes_vcffiltering.sh
#
# the above script also calls upon the following module scripts automatically:
# ./vcfcompiler_diagnostics.sh 
# ./ExomeTableClean.R
echo "############################################################################"
echo "######################### Performing VCF filtering #########################"
echo "############################################################################"
# message
echo "...starting vcf filtering of sample $filename..."
. ./wes_vcffiltering.sh
echo "...filtering done..."
echo "...moving on to most damaging variant assessment..."
echo ""
echo ""
##/END [3]


## [4] assess the most damaging variants and generate html links for report
# call upon assess_variants.sh
# this script identifies all variants that are MutationTaster_pred=D (damaging) and MutationAssessor_pred=H (high)
# and creates MutationAssessor html links which are entered as an appendix table in the final report
echo "############################################################################"
echo "###################### Performing variant assessment #######################"
echo "############################################################################"
# message
echo "...starting most damaging variant assessment..."
. ./assess_variants.sh
echo "...assessment complete..."
echo "...moving on to report generation..."
echo ""
echo ""
##/END [4]


## [5] create final report (docx) using RMarkdown
# call upon wes_reporting.R
echo "################################################ ############################"
echo "####################### Generating the final report ########################"
echo "############################################################################"
# message
echo "...starting final report generation..."
Rscript ./wes_reporting.R "$sampleID" "$RUNID"
echo "...final report complete..."
echo ""
echo ""
##/END [5]


## move log file into current directory
RUNTIME=$(date +"%H:%M:%S")
RUNTIME_END=$(date +"%H:%M:%S" | awk -F: '{print ($1 * 3600) + ($2 * 60) + $3 }')
# calculate total run time in seconds
TOTAL_TIME=$(echo $(("$RUNTIME_END"-"$RUNTIME_START")))
DATE=$(date +"%m-%d-%Y")
echo "...outputting log file..."
LOGFILE=$(ls -d ../*pipeline_run.log)
echo "...$LOGFILE has been created..."
mv "$LOGFILE" .
LOGFILE=$(ls *.log)
LOGOUT=$(paste -d'_' <(echo "$sampleID") <(echo "$LOGFILE"))
mv "$LOGFILE" "$LOGOUT"
echo "...Pipeline run of $sampleID finished on $DATE at $RUNTIME..."
echo "...Total run time was $TOTAL_TIME seconds..."
echo ""
##
## To-do: add a step to zip the sample directory and then organise a transfer 
## of the compressed file to a specific location
##
echo "############################################################################"
echo "############################## RUN COMPLETED ###############################"
echo "############################################################################"
##/END