#!/usr/bin/env Rscript
# front-end GUI for variant annotation and reporting tool
# author: Miles Benton
# created: 180411
# modified: 180417

# load packages
require(shiny)
require(shinycssloaders)
require(magrittr)
# require(shinyjs)
# define ui and server
runApp(list(ui = pageWithSidebar(
  headerPanel("Variant Annotation & Reporter Tool"),
  sidebarPanel(
    helpText("Enter details for annotation run and report generation."),
    
    textInput("user", "User Name", ""),
    textInput("sample", "Sample ID", ""),
    # comment about filename matching, can match any string from a given file in both 'barcode' and 'runID' values
    textInput("barcode", "Label (i.e. barcode)", ""),
    textInput("runID", "Run ID", ""),
    # textInput("build", "Genome Build", ""),
    selectInput("build", "Genome Build", choices = c('hg19', 'hg38')),
    # textInput("diagGenes", "Diagnostic Gene List", ""),
    fileInput("diagGenes", "Choose tier 0 gene list",
              accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
    # textInput("geneList", "User Defined Gene List", ""),
    fileInput("geneList", "Choose tier 1 gene list",
              accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
    textInput("directory", "Output Directory Name", ""),
    br(),
    actionButton("updateButton", "Update details"),
    helpText("Click the button to update the value displayed in the main panel.")
    
  ),
  mainPanel(
    
    helpText("Please review the details you entered below before proceeding."),
    
    tags$head(tags$style(" #container * { display: inline; }")),
    div(id="container", strong('Selected user:'), textOutput("user.value")),
    div(id="container", strong('Selected sample:'), textOutput("sample.value")),
    div(id="container", strong('Selected barcode:'), textOutput("barcode.value")),
    div(id="container", strong('Selected run ID:'), textOutput("runID.value")),
    div(id="container", strong('Selected genome build:'), textOutput("build.value")),
    div(id="container", strong('Selected tier 0 gene list:'), textOutput("diagGenes.value")),
    div(id="container", strong('Selected tier 1 gene list:'), textOutput("geneList.value")),
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
    
    )
),

server = function(input, output) {
  
  # allow updating of input variables
  output$user.value <- eventReactive(input$updateButton, { input$user } )
  output$sample.value <- eventReactive(input$updateButton, { input$sample } )
  output$barcode.value <- eventReactive(input$updateButton, { input$barcode } )
  output$runID.value <- eventReactive(input$updateButton, { input$runID } )
  output$build.value <- eventReactive(input$updateButton, { input$build } )
  output$diagGenes.value <- eventReactive(input$updateButton, { paste0('gene_lists/', input$diagGenes$name) } ) # sets directory structure
  output$geneList.value <- eventReactive(input$updateButton, { paste0('gene_lists/', input$geneList$name) } )   # sets directory structure
  output$dir.value <- eventReactive(input$updateButton, { input$directory } )

  # generate output for bash script and then initiate the pipeline
  observeEvent(input$goButton, { write.table(rbind(input$user, 
                                                 input$sample, 
                                                 input$barcode,
                                                 input$runID,
                                                 input$build,
                                                 paste0('gene_lists/', input$diagGenes$name),
                                                 paste0('gene_lists/', input$geneList$name),
                                                 input$directory), file = "./pipeline_input.txt", 
                                                 col.names = FALSE, row.names = FALSE, quote = FALSE)
                                  system("./WESdiag_pipeline_dev.sh") })
  
}
)
)
##/END