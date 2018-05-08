## VCF-DART (VCF Diagnostics Annotation and Reporting Tool)
Pipeline to annotate and filter variant called format (vcf) files and generate a report document for clinical diagnostics. The variant annotation and filtering pipeline now uses a web server GUI implemented in R Shiny. 

## Possible names for software

  - **DART** - **D**iagnostics **A**nnotation and **R**eporting **T**ool
    + this means that the other Shiny app could be **DART-view** or **DART-viewer**

## Software Dependencies

The following programs need to be available/installed for correct operation:
  - [VEP](https://www.ensembl.org/vep)
  - [snpEFF](snpeff.sourceforge.net/) (for SNPSift dbNSFP annotation)
  - [tabix]()www.htslib.org/doc/tabix.html (compression and indexing)
  - [bedops](https://bedops.readthedocs.io/) (for vcf-sort)
  - [bcftools](https://samtools.github.io/bcftools/bcftools.html) 
  - [R](https://www.r-project.org/)
  - [Shiny Server](https://www.rstudio.com/products/shiny/shiny-server/)

## R Package Dependencies

VCF-DART currently requires the following packages (and their dependencies) to be installed for correct operation:
```R
# required packages
install.packages('magrittr')
require('magrittr')
```

## Current to-do list and fixes/features pending

  - [ ] look at moving this to-do list over to a roadmap in the wiki
  - [x] ~~GitHub repo requires ssh passphrase each use~~  
  - [x] ~~issue with grep using gene lists (files) and vcf.gz~~  
    + [x] ~~look into using tabix (MUCH faster)~~  
    + [x] ~~extract list of genes from a bed file (with position info), i.e. `grep -w -f 'gene_list.txt' UCSC_gene_positions_hg19.bed > gene_regions_hg19.txt`~~  
    + [x] ~~use: `tabix -R gene_regions.txt variant.vcf.gz`~~  
  - [x] ~~add a Shiny GUI to the front end~~  
  - [x] ~~create a configuration file to allow users to set paths to software and databases (temp)~~
  - [x] ~~remove all hard-coded paths (software, databases and directories)~~
    + [x] ~~remove from the main bash script (`WESdiag_pipeline_dev.sh`)~~
    + [x] ~~remove from `wes_vcffiltering.sh`~~
    + [x] ~~remove from `assess_variants.sh`~~
    + [x] ~~remove from `vcfcompiler_diagnostics.sh`~~
  - [ ] implement selection of genome build (currently only hg19 is working)
    + [ ] this is a big feature as the current databases aren't all built for hg38
    + [ ] create a separate feature branch to develop this  
  - [x] ~~remove the xmessage checks (relies on having X11 environment installed, not ideal)~~
    + [x] ~~decide if we need to have user checks at these two locations~~
  - [x] ~~ensure the log files are being moved back into the correct location~~
  - [x] ~~overhaul Shiny script to allow hosting via Shiny Server~~ 
    + [x] ~~split into `ui.R` and `server.R`~~
    + [x] ~~add home directory variable to set location for data and scripts~~
    + [x] ~~test working when deployed remotely~~
  - [x] ~~added code to set working dir to main script location~~
  - [ ] explore having options for which databases to annotate against, i.e. not running VEP `--everything` could cut run time by 30+ mins
  - [ ] add more extracted features to the `vcfcompiler_diagnostics.sh` script (i.e. CADD score)
    + [ ] make CADD score available (add extraction routine in `vcfcompiler_diagnostics.sh`)
  - [x] ~~add user defined option for the 3rd tier gene list~~
    + [x] ~~create a feature branch for this to be implemented (user-defined-tiers)~~
    + [x] ~~update variable names of gene lists to be universal~~
    + [x] ~~use user uploaded gene lists (download into `gene_list` dir)~~
    + [x] ~~add integration with a self contained and user curated gene list repository~~ 
  - [ ] look into adding a cancel/exit button to the Shiny App to kill run
  - [ ] explore asking user for raw data dir in GUI or configuration file (currently hard-coded)
  - [ ] evaluate whether we need to continue to allow the user to define the 'home' dir
  - [ ] generate and send an email and/or text message upon run completion 
  - [ ] test whether bgzipping and creating tabix index for the vcf file improves VEP performance
  - [ ] integrate docker branch (this is likely to address some/all above concerns)
  - [x] ~~update DART-view (other shiny app) to point to the correct directory for viewing results~~
