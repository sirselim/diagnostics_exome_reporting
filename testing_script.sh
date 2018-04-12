#!/bin/bash
#
# Created: 2018/04/11
# Last modified: 2018/04/12
# Author: Miles Benton
#
# """
# This script was created to automate the module scripts from the WES reporting pipeline.
# It first asks the user for required information, seeks confirmation to proceed, and then
# runs through all pipeline scripts to completion.
# """

## LOGGING
# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee -i WES_pipeline_run.log)
exec 2>&1
# Everything below will go to the file 'WES_pipeline_run.log':
##

## [0] required user input
echo "############################################################################"
echo "## GRC Whole Exome Sequencing Annotation Filtering and Reporting Pipeline ##"
echo "############################################################################"
# set up time and date
RUNTIME=$(date +"%H:%M:%S")
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
diagnosticList=$(sed '6q;d' pipeline_input.txt)
GENELIST=$(sed '7q;d' pipeline_input.txt)
sampleDIR=$(sed '8q;d' pipeline_input.txt)
# overview variables for confirmation
echo "## You have entered the following details: "
echo "sampleID: $sampleID "
echo "IonExpress Label: $LABELID "
echo "runID: $RUNID"
echo "genome: $GENOME_BUILD "
echo "Tier0 gene list: $diagnosticList "
echo "Tier1 gene list: $GENELIST "
echo "Directory for analysis: $sampleDIR "
# ask for confirmation before proceeding
# can remove this eventually but retaining as sanity check for now
echo ""
# added a graphical prompt for user check
xmessage -center -buttons Yes,No -default No -center "Are these details correct and do you wish to proceed?"
ans="$?"
if [[ "$ans" == 101 ]]; then
       :;
else
    exit;
fi
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
git clone git@github.com:sirselim/diagnostics_exome_reporting.git "$sampleDIR"
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
# check once again that this is the correct sample and file
# ask for confirmation before proceeding
echo ""
xmessage -center -buttons Yes,No -default No -center "Is this the correct file - $VCFFILE - and do you wish to proceed?"
ans="$?"
if [[ "$ans" == 101 ]]; then
       echo "...continuing with WES pipeline..."; :;
else
   echo "...exiting WES pipline script..."; rm -R "$sampleDIR"; exit;
fi
#echo "## Is this the correct file - $VCFFILE - and do you wish to proceed?"
#select yn in "Yes" "No"; do
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
