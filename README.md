# diagnostics_exome_reporting
Pipeline to filter whole exome vcf files and generate a report document for clinical diagnostics.

# Current to-do list and fixes

  - GitHub repo requires ssh passphrase each use
  - issue with grep using gene lists (files) and vcf.gz
    + look into using tabix (MUCH faster)
    + extract list of genes from a bed file (with position info), i.e. `grep -w -f 'gene_list.txt' UCSC_gene_positions_hg19.bed > gene_regions_hg19.txt`
    + use: `tabix -R gene_regions.txt variant.vcf.gz` 
