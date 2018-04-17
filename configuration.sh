#!/bin/bash

####
## configuration file for diagnostic pipeline
####

# set paths to software
SNPEFF="/data/all/programs/snpeff/snpEff/snpEff.jar"
SNPSIFT="/data/all/programs/snpeff/snpEff/SnpSift.jar"
VEP="/data/all/programs/VEP/vep-87-github-release/vep.pl"
BGZIP="/usr/local/bin/bgzip"
TABIX="/usr/local/bin/tabix"
BCFTOOLS="/usr/bin/bcftools"

# set paths to database directories
DBSNP_DATA="/data/all/ncbi/hg19/All_20170710.vcf.gz"
VEP_DATA="/data/all/VEPdata/"
FASTA_REF="/data/all/VEPdata/homo_sapiens/89_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa"
DBNSFP="/data/all/dbNSFP/hg19/v2.9.3/dbNSFPv2.9.3_hg19_custom.txt.gz"

# dir of your sequence data
