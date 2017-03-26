#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# test if there are provided arguments (sampleID and run no): if not, return an error
if (length(args)==0) {
  stop("Please provide a sample ID (e.g. DG1021).\n", call.=FALSE)
} else if (length(args)==1) {
  stop("Please provide a run ID (e.g. XXXX).\n", call.=FALSE)
}

# generate report
rmarkdown::render("report/GRC_report_v0.1.3.Rmd", output_file = paste(args[1], args[2], "GRC_report.docx", sep = "_"))
