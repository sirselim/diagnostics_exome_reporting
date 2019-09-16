#!/bin/bash
# Miles Benton
# created: 2019-03-08
# modified: 2019-03-08

# this script obtains the latest tab delim variant summary from ClinVar and filters out specific
# columns as well as creates a url to each variant, this will be used for addtional annotation

# download latest clinvar summary
# check for previous file, delete if present, download latest
if [ -f "variant_summary.txt.gz" ]; then
    echo "...previous version found... deleting file now...."
    rm variant_summary.txt.gz
    echo "...downloading latest ClinVar summary from: ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz..."
    wget "ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz"
    echo "...done..."
else
    echo "...downloading latest ClinVar summary from: ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz..."
    wget "ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz"
    echo "...done..."
fi

# filter clinvar summary data to specific columns and output to new file
zcat variant_summary.txt.gz | awk -F'\t' -v OFS='\t' '{print $17,$19,$20,$21,$22,$23,$31,$3,$7}' | bgzip -c > clinvar_variant_summary_filtered.txt.gz
# output header 
zcat clinvar_variant_summary_filtered.txt.gz | head -n 1 | sed 's/$/\tURL/' > header.txt
# create tmp file 
zcat clinvar_variant_summary_filtered.txt.gz | tail -n +2 > tmp.txt

# create clinvar url
# eg. https://www.ncbi.nlm.nih.gov/clinvar/variation/18337/
# number of variants to loop over
VARNO=$(wc -l tmp.txt | awk '{print $1}')
# grab clinvar IDs to fill in url
VariationID=$(awk -F'\t' -v OFS='\t' '{print $7}' tmp.txt)
URL1=$(for (( c=1; c<="$VARNO"; c++)) ; do echo "https://www.ncbi.nlm.nih.gov/clinvar/variation/" ; done)
URL2=$(paste <(echo "$VariationID") -d '')
URL=$(paste <(echo "$URL1") <(echo "$URL2") -d '')

# bring it all together 
echo $URL | tr ' ' '\t' | datamash transpose | paste tmp.txt - -d'\t' | cat header.txt - | bgzip -c > clinvar_variant_summary_filtered_url.txt.gz

# save out an RDS for faster loading
Rscript -e 'clinvarSum <- read.delim("~/gitrepos/diagnostics_exome_reporting/clinvar_variant_summary_filtered_url.txt.gz", head = T, as.is = F);saveRDS(clinvarSum, file = "~/gitrepos/diagnostics_exome_reporting/clinvar_variant_summary_filtered_url.RDS")'

# clean up
rm tmp.txt clinvar_variant_summary_filtered.txt.gz header.txt variant_summary.txt.gz
##/END