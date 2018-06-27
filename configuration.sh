#!/bin/bash

####
## configuration file for VCF Diagnostics Annotation and Reporting Tool (VCF-DART) 
####

# set number of threads to use
THREADS="6"

####
# set paths to software
## taurus
# SNPEFF="/data/all/programs/snpeff/snpEff/snpEff.jar"
# SNPSIFT="/data/all/programs/snpeff/snpEff/SnpSift.jar"
# VEP="/data/all/programs/VEP/ensembl-vep/vep"
# BGZIP="/usr/local/bin/bgzip"
# TABIX="/usr/local/bin/tabix"
# BCFTOOLS="/usr/bin/bcftools"
# VCFSORT="/usr/bin/vcf-sort"
## wagyu
# SNPEFF="/data2/programs/snpeff/snpEff.jar"
# SNPSIFT="/data2/programs/snpeff/SnpSift.jar"
# VEP="/data2/programs/ensembl-vep/vep"
# BGZIP="/usr/bin/bgzip"
# TABIX="/usr/bin/tabix"
# BCFTOOLS="/usr/bin/bcftools"
# VCFSORT="/usr/bin/vcf-sort"
####
## wagyu
SNPEFF="/home/install/snpEFF/snpEff.jar"
SNPSIFT="/home/install/snpEFF/SnpSift.jar"
VEP="/home/install/ensembl-vep/vep"
BGZIP="/usr/bin/bgzip"
TABIX="/usr/bin/tabix"
BCFTOOLS="/usr/bin/bcftools"
VCFSORT="/usr/bin/vcf-sort"
####

####
# set paths to database directories
# DBSNP_DATA="/data/all/ncbi/hg19/All_20170710.vcf.gz"
# VEP_DATA="/data/all/VEPdata/"
##FASTA_REF="/data/all/VEPdata/homo_sapiens/89_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa"
## when you build a new version of VEP you might need to manually delete the index file (permission issues)
# FASTA_REF="/home/grcnata/fasta/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa"
## older dbNSFP version [hg19]
# DBNSFP="/data/all/dbNSFP/hg19/v2.9.3/dbNSFPv2.9.3_hg19_custom.txt.gz"
## newest dbNSFP version [hg19]
## DBNSFP="/data/all/dbNSFP/hg19/v3.5a/dbNSFPv3.5a.hg19.txt.gz"
## newest dbNSFP version [hg38]
## DBNSFP="/data/all/dbNSFP/hg38/v3.5a/dbNSFPv3.5a.txt.gz"
## wagyu
# DBSNP_DATA="/data2/dbSNP/hg19/All_20170710.vcf.gz"
# VEP_DATA="/data2/VEPdata/"
# FASTA_REF="/data2/VEPdata/homo_sapiens/92_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz"
# DBNSFP="/data2/dbNSFP/hg19/v2.9.3/dbNSFPv2.9.3_hg19_custom.txt.gz"
####
## VM
DBSNP_DATA="/data/dbSNP/hg19/All_20170710.vcf.gz"
VEP_DATA="/data/VEPdata/"
FASTA_REF="/data/VEPdata/homo_sapiens/92_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz"
DBNSFP="/data/dbNSFP/hg19/v2.9.3/dbNSFPv2.9.3_hg19_custom.txt.gz"
####

####
# dir of sequence and quality/coverage data
## taurus
# RAWDATA="/home/grcnata/raw_wes_files/"

## wagyu
# RAWDATA="/data2/vcfdart_data/"
####

## VM
RAWDATA="/data2/vcfdart_data/"
##