# diagnostics_exome_reporting
Pipeline to filter variant called format (vcf) files and generate a report document for clinical diagnostics.

# Current to-do list and fixes pending

  - [x] ~~GitHub repo requires ssh passphrase each use~~  
  - [x] ~~issue with grep using gene lists (files) and vcf.gz~~  
    + [x] ~~look into using tabix (MUCH faster)~~  
    + [x] ~~extract list of genes from a bed file (with position info), i.e. `grep -w -f 'gene_list.txt' UCSC_gene_positions_hg19.bed > gene_regions_hg19.txt`~~  
    + [x] ~~use: `tabix -R gene_regions.txt variant.vcf.gz`~~  
  - [x] ~~add a Shiny GUI to the front end~~  
  - [x] create a configuration file to allow users to set paths to software and databases (temp)
  - [ ] remove all hard-coded paths (software, databases and directories)
    + [x] remove from the main bash script (`WESdiag_pipeline_dev.sh`)
    + [ ] remove from `wes_vcffiltering.sh`
    + [ ] remove from `assess_variants.sh`
    + [ ] remove from `vcfcompiler_diagnostics.sh`
  - [ ] implement selection of genome build (currently only hg19 is working)
  - [ ] remove the xmessage checks
    + [ ] decide if we need to have user checks at these two locations
  - [ ] integrate docker branch (this is likely to address some/all above concerns)
