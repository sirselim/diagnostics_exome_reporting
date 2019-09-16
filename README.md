# VCF-DART (VCF Diagnostics Annotation and Reporting Tool)

Pipeline to annotate and filter variant called format (vcf) files and generate a report document for clinical diagnostics. The variant annotation and filtering pipeline now uses a web server GUI implemented in R Shiny.

-----

## IMPORTANT - Please Read

**Disclaimer**

Please note that this is a beta version of the VCF-DART platform which is
still undergoing final testing before its official release. The
platform, its software and all content found on it are provided on an
“as is” and “as available” basis. VCF-DART does not give any warranties,
whether express or implied, as to the suitability or usability of the
website, server, its software or any of its content.

VCF-DART will not be liable for any loss, whether such loss is direct,
indirect, special or consequential, suffered by any party as a result
of their use of the VCF-DART platform, its software or content. Any
downloading or uploading of material to the website/server is done at the
user’s own risk and the user will be solely responsible for any
damage to any computer system or loss of data that results from such
activities.

Should you encounter any bugs, glitches, lack of functionality or
other problems on the website, please let us know immediately so we
can rectify these accordingly. Your help in this regard is greatly
appreciated! The best way to do this is to log an issue in this GitHub repository, 
or if you feel inclined you are welcome to create a pull request.

-----

## Software Dependencies

The following programs need to be available/installed for correct operation:

- [VEP](https://www.ensembl.org/vep)
- [snpEFF](snpeff.sourceforge.net/) (for SNPSift dbNSFP annotation)
- [tabix](www.htslib.org/doc/tabix.html) (compression and indexing)
- parallel
- [bedops](https://bedops.readthedocs.io/) (for vcf-sort)
- [bcftools](https://samtools.github.io/bcftools/bcftools.html)
- [R](https://www.r-project.org/)
- [Shiny Server](https://www.rstudio.com/products/shiny/shiny-server/)

## R Package Dependencies

VCF-DART currently requires the following packages (and their dependencies) to be installed for correct operation:

```R
# CRAN
install.packages('magrittr')
install.packages('shiny')
install.packages('shinyBS')
install.packages('rmarkdown')
install.packages('pander')
```

*NOTE: for Shiny Server to be correctly installed you will require both `shiny` and `rmarkdown` packages to be installed.*

## Current to-do list and fixes/features pending

- [ ] fix bug in `assess_variants.sh` that means Mutation Assessor links don't work
  - [ ] hg19 is being replaced by GRCh37, creating dead links
- [ ] look at moving this to-do list over to a roadmap in the wiki
- [x] ~~add a tab to the UI that captures and displays the tail of the most recent log file~~
  - [x] ~~to do this add ability for shell (bash) pipeline call to be sent to background processing freeing up Shiny Server reactivity~~
  - [ ] this has been implemented, but has meant the removal of the activity wheel (for now)
- [ ] option to run without coverage text file (more a research purpose)
- [ ] look at integrating VCF-DART and VCF-DART Viewer into a shinydashboard (and within a docker/singularity container)
  - [ ] explore docker/singularity
- [ ] explore having options for which databases to annotate against, i.e. not running VEP `--everything` could cut run time by 30+ mins
  - [x] ~~reducing the number of threads to 6 and removing the `--merged` VEP option reduce run times to 10-15 mins for vcf files 30-50K variants in size~~
- [ ] implement selection of genome build (currently only hg19 is working)
  - [ ] this is a big feature as the current databases aren't all built for hg38
    - [ ] create a separate feature branch to develop this  
- [ ] add more extracted features to the `vcfcompiler_diagnostics.sh` script (i.e. CADD score)
  - [x] ~~make CADD score available (add extraction routine in `vcfcompiler_diagnostics.sh`)~~
  - [x] ~~added MutationTaster and MutationAssessor to viewable output as well~~
  - [x] ~~build script to scrape clinvar and provide updated annotation~~
  - [x] ~~add more Clinvar information~~
    - [x] ~~add a script that pulls the most recent clinvar, process it and save as an RDS for quick access (a version of this is included in the repo)~~
  - [ ] combine above this with results
- [ ] look into adding a cancel/exit button to the Shiny App to kill run
- [ ] explore asking user for raw data dir in GUI or configuration file (currently hard-coded)
- [ ] evaluate whether we need to continue to allow the user to define the 'home' dir
- [ ] generate and send an email and/or text message upon run completion
- [ ] look into developing an option for "off-line mode"
  - [ ] design a check for internet connection
  - [ ] would need a local copy of the repository available
- [ ] check for and ignore `.tbi` files in the data directory
- [ ] explore adding a check for label in the coverage text file as well
- [ ] add a check for input variables and warn/error display that this is the case if missing
- [x] ~~look at adding a tab for help/guide~~
  - [x] ~~added tooltips throughout app, detailed help/documentation can be found at GitHub wiki~~
- [x] ~~add a tab with options to upload files (VCF and coverage text files)~~
- [x] ~~check for existing `gene_list` dir and delete if present~~
- [x] ~~removed the need for an external configuration file~~
  - [x] ~~config options are now at the start of the script (user defined)~~
- [x] ~~GitHub repo requires ssh passphrase each use~~  
- [x] ~~add a Shiny GUI to the front end~~  
- [x] ~~update DART-view (other shiny app) to point to the correct directory for viewing results~~
- [x] ~~issue with grep using gene lists (files) and vcf.gz~~  
  - [x] ~~look into using tabix (MUCH faster)~~  
  - [x] ~~extract list of genes from a bed file (with position info), i.e. `grep -w -f'gene_list.txt' UCSC_gene_positions_hg19.bed > gene_regions_hg19.txt`~~  
  - [x] ~~use: `tabix -R gene_regions.txt variant.vcf.gz`~~  
- [x] ~~remove the xmessage checks (relies on having X11 environment installed, not ideal)~~
  - [x] ~~decide if we need to have user checks at these two locations~~
- [x] ~~ensure the log files are being moved back into the correct location~~
- [x] ~~overhaul Shiny script to allow hosting via Shiny Server~~
  - [x] ~~split into `ui.R` and `server.R`~~
  - [x] ~~add home directory variable to set location for data and scripts~~
  - [x] ~~test working when deployed remotely~~
- [x] ~~added code to set working dir to main script location~~
- [x] ~~create a configuration file to allow users to set paths to software and databases (temp)~~
- [x] ~~remove all hard-coded paths (software, databases and directories)~~
  - [x] ~~remove from the main bash script (`WESdiag_pipeline_dev.sh`)~~
  - [x] ~~remove from `wes_vcffiltering.sh`~~
  - [x] ~~remove from `assess_variants.sh`~~
  - [x] ~~remove from `vcfcompiler_diagnostics.sh`~~
- [x] ~~add user defined option for the 3rd tier gene list~~
  - [x] ~~create a feature branch for this to be implemented (user-defined-tiers)~~
  - [x] ~~update variable names of gene lists to be universal~~
  - [x] ~~use user uploaded gene lists (download into `gene_list` dir)~~
  - [x] ~~add integration with a self contained and user curated gene list repository~~
- [x] ~~explore the presence of duplicate variants in the final tier (tier 3)~~
- [x] ~~add ability to determine variant caller used to generate VCF file to allow allele depthspecific filtering~~
  - [x] ~~testing an IF ELSE statement which looks for AD term (GATK format)~~
- [x] ~~test whether bgzipping and creating tabix index for the vcf file improves VEP performance~~
- [x] ~~add time taken at the end of the pipeline (in main bash script)~~
- [x] ~~implement multiple row selection and copy to clipboard~~

## License

    Copyright (C) 2018  Miles Benton

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
