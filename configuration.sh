#!/bin/bash

####
## configuration file for diagnostic pipeline
####

# set paths to software
SnpSift="$(~/Downloads/software/snpEff_latest_core/snpEff/SnpSift.jar)"
VEP="$()"
BGZIP="$(/home/miles/anaconda3/bin/bgzip)"
TABIX="$(/home/miles/anaconda3/bin/tabix)"
BCFTOOLS="$(/home/miles/anaconda3/bin/bcftools)"

# set paths to database directories
DBSNP_DATA="$()"
VEP_DATA="$()"
DBNSFP="$()"

# dir of your sequence data
