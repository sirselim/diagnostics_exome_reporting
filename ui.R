#!/usr/bin/env Rscript
# front-end GUI for variant annotation and reporting tool
# author: Miles Benton
# created: 2018/04/11
# modified: 2019/04/05

# load packages
require(shiny)
require(shinycssloaders)
require(magrittr)
require(shinyBS)
# define ui and server
pageWithSidebar(
  headerPanel("VCF-DART (VCF Diagnostics Annotation and Reporting Tool)"),
  sidebarPanel(width=3,
    
    conditionalPanel(condition="input.conditionedPanels==1",
    helpText("Enter details for annotation run and report generation."),
    # default HomeDirectory location needs to be set on deployment
    textInput("HomeDirectory", "Home Directory (location of data)", "/home/ubuntu/"), # NOTE: user defined default directory!!
    bsTooltip("HomeDirectory", title = 'Please enter the directory where run results and report will be located.', 
              placement = "right", options = list(container = "body")),
    textInput("user", "User Name", ""),
    bsTooltip("user", title = 'Please enter your name.', 
              placement = "right", options = list(container = "body")),
    textInput("sample", "Sample ID", ""),
    bsTooltip("sample", title = 'Please enter the name of the sample. <b>This string must be present in both provided VCF and text filenames.</b>', 
              placement = "right", options = list(container = "body")),
    # comment about filename matching, can match any string from a given file in both 'barcode' and 'runID' values
    textInput("barcode", "Label (i.e. barcode)", ""),
    bsTooltip("barcode", 
              title = 'Please enter the sequencing barcode/sample number or similar. <b>This string must be present in both provided VCF and text filenames.</b>', 
              placement = "right", options = list(container = "body")),
    textInput("runID", "Run ID", ""),
    bsTooltip("runID", 
              title = 'Please enter an identifier for this run.', 
              placement = "right", options = list(container = "body")),
    selectInput("build", "Genome Build", choices = c('hg19', 'hg38')),
    bsTooltip("build", 
              title = 'Note: currently only hg19 is supported in this version of VCF-DART.', 
              placement = "right", options = list(container = "body")),
    tipify(fileInput("tier0List", "Choose Tier 0 gene list",
              accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
              title = 'Select a text file to upload for tier 0. This would usually be a short list of genes of immediate interest.', 
              placement = "right", options = list(container = "body")),
    tipify(fileInput("tier1List", "Choose Tier 1 gene list",
              accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
              title = 'Select a text file to upload for tier 1. This is usually a wider list of genes associated with your diease/disorder', 
              placement = "right", options = list(container = "body")),
    tipify(fileInput("tier2List", "Choose Tier 2 gene list",
              accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
              title = 'Select a text file to upload for tier 2. This is usually a list of genes involved in important related pathways', 
              placement = "right", options = list(container = "body")),
    textInput("directory", "Output Directory Name", ""),
    bsTooltip("directory", 
              title = 'Please enter an output directory. <b>Note: this directory will be used by VCF-DART Viewer to display results therefore it is good practice to include the same sample name you provided above as part of this.</b>', 
              placement = "right", options = list(container = "body")),
    # br(),
    actionButton("updateButton", "Update details"),
    helpText("Click to update values displayed in the main panel.")),
    
    conditionalPanel(condition="input.conditionedPanels==2",
      helpText("User upload panel")
    ),
    
    conditionalPanel(condition="input.conditionedPanels==3",
                     helpText("Log viewing panel...[under contruction...]")
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
    bsTooltip("goButton", title = 'Please confirm all entered details above are correct before proceeding. If you need to amend, do so to the right and then click "Update details" again.', 
              placement = "bottom", options = list(container = "body")),
    br(),
    HTML("<h3>Log file contents</h3>"),
    HTML("This section displays the last 10 lines of the most currently running sample's log file, 
                  which will signal when processing is complete and be useful to troubleshoot any potential errors."),
    tipify(verbatimTextOutput("log"), 
           title = "This displays the last 10 lines of the currently processed sample log file.", 
           placement = "left", options = list(container = "body"))
    # deactivated the activity wheel for now
    # br(),
    # conditionalPanel(condition="$('html').hasClass('shiny-busy')",
    #                  tags$div("Running..." %>%
    #                             withSpinner(color = "#0dc5c1", size = 1, type = 4), id="loadmessage"))
    ),
    
    tabPanel("User upload", value=2,
             HTML("<h2>Upload data to server</h2>"),
             HTML('<hr style="color: black;">'),
             tipify(fileInput("vcfFile", "Choose a VCF file to upload:", accept = c('text/plain', 'text/vcf'), width = "50%"),
                    title = "Select a VCF file to upload. Recommend that this is a compressed VCF (.vcf.gz), and that it has a detailed filename. <b>Example: S196_Exome_001.vcf.gz</b>", 
                    placement = "right", 
                    options = list(container = "body")),
             tipify(fileInput("txtFile", "Choose a txt file to upload (QC/coverage information):", accept = c('text/plain', 'text/txt'), width = "50%"),
                    title = "Select a coverage and QC text file to upload. Please ensure that this contains a detailed filename with the same content as the VCF file above (i.e. sample name and barcode/run label should be exactly the same in both files).  <b>Example: S196_Exome_001_Stats.txt</b>", 
                    placement = "right", 
                    options = list(container = "body"))
             )
        )
    )
)
