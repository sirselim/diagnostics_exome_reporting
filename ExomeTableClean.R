#!/usr/bin/env Rscript
# ExomeTableClean.R -- cleans and formats exome data for reporting

# load required packages
require('magrittr')

# capture argument from bash
arguments <- commandArgs(trailingOnly = TRUE)
for (i in 1:length(arguments)) {
  print(paste("...cleaning file", "=", arguments[i]))
}

# define date, file, input, output etc
fileDate <- format(Sys.time(), "%a_%b_%d_%Y")
filename <- arguments[1]
samplename <- paste(unlist(strsplit(filename, split = '/'))[3])
sampleID <- unlist(strsplit(samplename, split = '_'))[[1]]
outdir <- paste0(paste(unlist(strsplit(filename, split = '/'))[1:2], collapse = '/'), '/clean/')
outfile <- paste0(outdir, sampleID, '_Tier0_results_clean_', fileDate, '.csv')

###
# perform cleaning 
exome_table <- read.delim(filename, head = T, as.is = T)
# gene
exome_table$gene <- gsub('^.;', '', exome_table$gene) 
exome_table$gene <- sapply(sapply(strsplit(exome_table$gene, ";"), unique), paste, collapse = ";")
# SIFT
exome_table$SIFT <- sapply(sapply(strsplit(exome_table$SIFT, ","), unique), paste, collapse = ";")
# MutationTaster
exome_table$MutationTaster <- sapply(sapply(strsplit(exome_table$MutationTaster, ","), unique), paste, collapse = ";")
# Polyphen2
exome_table$Polyphen2 <- sapply(sapply(strsplit(exome_table$Polyphen2, ","), unique), paste, collapse = ";")
# 1KG allele freqs
exome_table$CAF1[exome_table$CAF1 == '.'] <- 0
exome_table$CAF1 <- as.numeric(exome_table$CAF1)
exome_table$CAF2[exome_table$CAF2 == '.'] <- 0
exome_table$CAF2 <- as.numeric(exome_table$CAF2)
###

# create output table
exome_table_clean <- data.frame(location = paste(exome_table$chromosome, exome_table$position, sep = ':'),
                          genotype = ifelse(exome_table$genotype == '0/1', paste(exome_table$reference_allele, exome_table$alternate_allele, sep = '/'), 
                          	ifelse(exome_table$genotype == '1/1', paste(exome_table$alternate_allele, exome_table$alternate_allele, sep = '/'), exome_table$genotype)),
                          ref = exome_table$reference_allele, 
                          alt = exome_table$alternate_allele,
                          dbSNP = exome_table$id,
                          gene = exome_table$gene,
                          transcript = unlist(lapply(strsplit(exome_table$transcript, split = ';'), `[[`, 1)),
                          coding = unlist(lapply(strsplit(exome_table$coding, split = ';'), `[[`, 1)),
                          AAchange = unlist(lapply(strsplit(exome_table$amino_acid_substitution, split = ';'), `[[`, 1)),
                          MutationTaster = exome_table$MutationTaster,
                          SIFT = exome_table$SIFT,
                          Polyphen2 = exome_table$Polyphen2,
                          coverage = paste0(exome_table$depth_coverage, ' ', exome_table$reference_allele, '(', exome_table$Ref_coverage, 
                                            ')', ' ', exome_table$alternate_allele, '(', exome_table$Alt_coverage, ')'),
                          ref_freq = exome_table$CAF1,
                          alt_freq = exome_table$CAF2)
# write clean table out to results dir
write.csv(exome_table_clean, outfile, row.names = F)