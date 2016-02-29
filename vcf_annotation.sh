#!/bin/bash
#
# Created: 2016/02/18
# Last modified: 2016/02/19
# Author: Miles Benton
#
# """
# This script forms the start of the diagnostic WES pipeline, annotating vcf files with various databases.
# The script accepts 1 argument (file name).
#
# E.g. INPUT
# ./pipe_test.sh /path/to/exome_sample.vcf.gz
#
# """

# define the sample being processed
INPUTFILE="$1"
filename=$(echo "$INPUTFILE" | tr "/ && ." " " | awk '{printf $2}')
echo "...starting annotation of sample $filename..."

## add dbSNP info (rs ID, CAF etc)
echo "...annotating with dbSNP..."
java -jar /home/miles/install/snpEff/SnpSift.jar annotate /data/all/ncbi/hg19/All_20151104.vcf.gz vcf/"$filename".vcf.gz > vcf/"$filename"_dbSNP.vcf

## annotate with VEP
echo "...annotating with VEP..."
/data/all/programs/VEP/ensembl-tools-release-82/scripts/variant_effect_predictor/variant_effect_predictor.pl --assembly GRCh37 --fasta /ramdisk/hg19_mod.fa.gz --cache \
--merged -i vcf/"$filename"_dbSNP.vcf --offline --stats_text --everything -o vcf/"$filename"_dbSNP_VEP.vcf --vcf --dir /home/gringer/.vep --fork 10 --force_overwrite

## SNPSift dbNSFP
echo "...annotating with SnpSift dbNSFP..."
# split on chr
# can greatly speed up the process by first splitting the vcf 
java -jar /home/miles/install/snpEff/SnpSift.jar split vcf/"$filename"_dbSNP_VEP.vcf
# create list of chr vcf files
find vcf/"$filename"_dbSNP_VEP.chr* -maxdepth 1 -type f -printf '%f\n' > chr_list.txt
# run in parallel
cat chr_list.txt | parallel -j 12 'java -jar /home/miles/install/snpEff/SnpSift.jar dbnsfp -v -db /data/all/dbNSFP/hg19/dbNSFP.txt.gz vcf/{} > vcf/test_{}'
# join them back together
java -jar /home/miles/install/snpsift/SnpSift.jar split -j vcf/test_* > vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf
# clean up
rm chr_list.txt
rm vcf/test_*
rm vcf/*.chr*

## SNPSift gwascatalog
# java -jar /home/miles/install/snpEff/SnpSift.jar gwasCat -db /data/all/dbNSFP/gwascatalog/gwascatalog.txt vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf > vcf/"$filename"_dbSNP_VEP_dbNSFP_gwas.vcf
# this only seems to be annotated at hg38 level

## bgzip step to compress
echo "...compressing to vcf.gz..."
bgzip -c vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf > vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf.gz
tabix -p vcf vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf.gz

# add additional GENE annotation to INFO
bcftools annotate -a UCSC_wholegenes.bed.gz -c CHROM,FROM,TO,GENE -h <(echo '##INFO=<ID=GENE,Number=1,Type=String,Description="Gene symbol">') vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf.gz > vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf
bgzip -c vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf > vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf.gz
tabix -p vcf vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf.gz

# final clean up
rm vcf/"$filename"_dbSNP.vcf
rm vcf/"$filename"_dbSNP_VEP.vcf
rm vcf/"$filename"_dbSNP_VEP_dbNSFP.vcf

echo "...done..."