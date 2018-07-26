#!/usr/bin/env Rscript
# front-end GUI for variant annotation and reporting tool
# author: Miles Benton
# created: 18/04/11
# modified: 18/07/27

# load packages
require(shiny)
require(shinycssloaders)
require(magrittr)
# define ui and server
pageWithSidebar(
  headerPanel("VCF-DART (VCF Diagnostics Annotation and Reporting Tool)"),
  sidebarPanel(width=3,
    
    conditionalPanel(condition="input.conditionedPanels==1",
    helpText("Enter details for annotation run and report generation."),
    
    textInput("HomeDirectory", "Home Directory (location of data)", "/home/miles/"),
    textInput("user", "User Name", ""),
    textInput("sample", "Sample ID", ""),
    # comment about filename matching, can match any string from a given file in both 'barcode' and 'runID' values
    textInput("barcode", "Label (i.e. barcode)", ""),
    textInput("runID", "Run ID", ""),
    selectInput("build", "Genome Build", choices = c('hg19', 'hg38')),
    fileInput("tier0List", "Choose Tier 0 gene list",
              accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
    fileInput("tier1List", "Choose Tier 1 gene list",
              accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
    fileInput("tier2List", "Choose Tier 2 gene list",
              accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
    textInput("directory", "Output Directory Name", ""),
    # br(),
    actionButton("updateButton", "Update details"),
    helpText("Click to update values displayed in the main panel.")),
    
    conditionalPanel(condition="input.conditionedPanels==2",
      helpText("User upload panel...[under contruction...]")
    )
    
  ),
  mainPanel(
    tabsetPanel(id = "conditionedPanels",
    tabPanel("VCF-DART", value=1,
    helpText("Please review the details you entered below before proceeding."),
    
    tags$head(tags$style(" #container * { display: inline; }")),
    div(id="container", strong('Selected home dir:'), textOutput("HomeDirectory.value")),
    div(id="container", strong('Selected user:'), textOutput("user.value")),
    div(id="container", strong('Selected sample:'), textOutput("sample.value")),
    div(id="container", strong('Selected barcode:'), textOutput("barcode.value")),
    div(id="container", strong('Selected run ID:'), textOutput("runID.value")),
    div(id="container", strong('Selected genome build:'), textOutput("build.value")),
    div(id="container", strong('Selected tier 0 gene list:'), textOutput("tier0List.value")),
    div(id="container", strong('Selected tier 1 gene list:'), textOutput("tier1List.value")),
    div(id="container", strong('Selected tier 2 gene list:'), textOutput("tier2List.value")),
    div(id="container", strong('Selected output directory:'), textOutput("dir.value")),
    
    tags$div(
      style="margin-top:25px;",
      helpText("If you are happy with the above please continue.")
    ),
    
    tags$head(tags$style(type="text/css", "
                         #loadmessage {
                         position: bottom;
                         top: 0px;
                         left: 0px;
                         width: 100%;
                         padding: 5px 0px 5px 0px;
                         text-align: center;
                         font-weight: bold;
                         font-size: 100%;
                         color: #000000;
                         background-color: #ffffff;
                         z-index: 105;
                         }
                         ")),
    div(id="container", actionButton("goButton", "Go!", width = '80px'), helpText("Click the button to start analysis.")),
    br(),
    conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                     tags$div("Running..." %>%
                                withSpinner(color = "#0dc5c1", size = 2, type = 4), id="loadmessage"))
    ),
    
    tabPanel("User upload", value=2,
             HTML("<h2>Upload data to server</h2>"),
             HTML('<hr style="color: black;">'),
             fileInput("vcfFile", "Choose a VCF file to upload:", accept = c('text/plain', 'text/vcf'), width = "50%"),
             fileInput("txtFile", "Choose a txt file to upload (QC/coverage information):", accept = c('text/plain', 'text/txt'), width = "50%"))
    
    )
    
    )
)
