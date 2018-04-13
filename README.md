# diagnostics_exome_reporting
Pipeline to filter whole exome vcf files and generate a report document for clinical diagnostics.

# Current to-do list and fixes pending

  - ~~GitHub repo requires ssh passphrase each use~~
  - ~~issue with grep using gene lists (files) and vcf.gz~~
    + ~~look into using tabix (MUCH faster)~~
    + ~~extract list of genes from a bed file (with position info), i.e. `grep -w -f 'gene_list.txt' UCSC_gene_positions_hg19.bed > gene_regions_hg19.txt`~~
    + ~~use: `tabix -R gene_regions.txt variant.vcf.gz`~~

# Docker container

## Pull docker container

`docker pull rink72/diag-exome-reporting`

## Run docker container

`docker run -d --rm -p port:8080 rink72/diag-exome-reporting`

`port` - is the local port you want to have the website hosted on. ie, you may want this to be port 80 and then the site could be reached by http://localhost or 8080 and the site could be reached at http://localhost:8080


## Retrieve logs

First the get docker container id with `docker ps`

Example output would be:

```
CONTAINER ID        IMAGE                         COMMAND                  CREATED             STATUS              PORTS                                              NAMES
e13a3095ec09        rink72/diag-exome-reporting   "Rscript diagnostics…"   3 seconds ago       Up 2 seconds        0.0.0.0:3003->8080/tcp                             pensive_fermat
```

You can now use `docker logs e13a3095ec09` to get the docker logs


