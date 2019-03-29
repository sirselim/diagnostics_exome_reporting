#!/usr/bin/Rscript

setwd("/data/PostDoc/WelingtonGeneticsLab/annotated/ESR004_20190305")

# load RDS file
clinvarSum <- readRDS(file = "clinvar_variant_summary_filtered_url.RDS")

# ensure genome build is correct format
clinvarSum$Assembly <- gsub("GRCh37", "hg19", clinvarSum$Assembly)
# rename columns to facilitate merge
colnames(clinvarSum)[c(1:3,5,6,10)] <- c("GENOME_BUILD", "CHR", "POSITION", "REF", "ALT", "ClinVarURL")

# load mutation data from pipeline
mutFile <- list.files('results/mutation_links/', full.names = T)[1]
mutation <- read.delim(mutFile, head = T, as.is = F)
# ensure genome build is correct format
mutation$GENOME_BUILD <- gsub("GRCh37", "hg19", mutation$GENOME_BUILD)
# rename URL
colnames(mutation)[12] <- "MutAssessorURL"

# merge clinvar and mutation data
mergeData <- merge(mutation, clinvarSum, by = c("GENOME_BUILD", "CHR", "POSITION", "REF", "ALT"), all.x = T)
# select columns to display
mergeData <- mergeData[c(1:11,14:17,12)]

# write output

##/END