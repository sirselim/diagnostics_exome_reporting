#!/usr/bin/env Rscript
# front-end GUI for variant annotation and reporting tool
# author: Miles Benton
# created: 18/04/11
# modified: 18/04/18

function(input, output) {
    
    options(warn=2, shiny.error=recover)
    # allow updating of input variables
    output$HomeDirectory.value <- eventReactive(input$updateButton, { input$HomeDirectory } )
    output$user.value <- eventReactive(input$updateButton, { input$user } )
    output$sample.value <- eventReactive(input$updateButton, { input$sample } )
    output$barcode.value <- eventReactive(input$updateButton, { input$barcode } )
    output$runID.value <- eventReactive(input$updateButton, { input$runID } )
    output$build.value <- eventReactive(input$updateButton, { input$build } )
    output$tier0List.value <- eventReactive(input$updateButton, { paste0('gene_lists/', input$tier0List$name) } ) # sets directory structure
    output$tier1List.value <- eventReactive(input$updateButton, { paste0('gene_lists/', input$tier1List$name) } ) # sets directory structure
    output$tier2List.value <- eventReactive(input$updateButton, { paste0('gene_lists/', input$tier2List$name) } ) # sets directory structure
    output$dir.value <- eventReactive(input$updateButton, { input$directory } )
    
    # generate output for bash script and then initiate the pipeline
    observeEvent(input$goButton, { write.table(rbind(input$user, 
                                                     input$sample, 
                                                     input$barcode,
                                                     input$runID,
                                                     input$build,
                                                     paste0('gene_lists/', input$tier0List$name),
                                                     paste0('gene_lists/', input$tier1List$name),
                                                     paste0('gene_lists/', input$tier2List$name),
                                                     input$directory), file = paste0(input$HomeDirectory, "pipeline_input.txt"), 
                                               col.names = FALSE, row.names = FALSE, quote = FALSE)
      system(paste0(input$HomeDirectory, "./WESdiag_pipeline_dev.sh")) })
    
  }
##/END