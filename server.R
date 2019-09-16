#!/usr/bin/env Rscript
# front-end GUI for variant annotation and reporting tool
# author: Miles Benton
# created: 2018/04/11
# modified: 2019/04/05

function(input, output, session) {
    
    options(warn=2, shiny.error=recover)
    options(shiny.maxRequestSize = 25*1024^2) # set maximum file size allowed to be uploaded (25MB here)
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
      # take user uploaded lists and put them into gene_lilsts dir (created below) 
      # check for directory first and remove if present
      unlink(paste0(input$HomeDirectory, 'gene_lists/', recursive = TRUE))
      # create gene_lists and populate
      dir.create(paste0(input$HomeDirectory, 'gene_lists/'))
      file.copy(input$tier0List$datapath, paste0(input$HomeDirectory, 'gene_lists/', input$tier0List$name))
      file.copy(input$tier1List$datapath, paste0(input$HomeDirectory, 'gene_lists/', input$tier1List$name))
      file.copy(input$tier2List$datapath, paste0(input$HomeDirectory, 'gene_lists/', input$tier2List$name))
      # these genes will be copied to the output dir and this gene_list dir will be removed (in main bash script)
      # start main pipeline bash script
      system(paste0(input$HomeDirectory, "./WESdiag_pipeline_dev.sh &"))
      # shell process is now being sent to the background
      # TO DO: look at adding email notification upon completion here
      })
    
    # allow user upload of VCF file
    observeEvent(input$vcfFile, {
      in_vcfFile <- input$vcfFile
      if (is.null(in_vcfFile))
        return()
      file.copy(in_vcfFile$datapath, file.path(".", in_vcfFile$name))  # NOTE: this file.path needs to reflect the location of exome data (user edit)
    })
    
    # allow user upload of text QC file
    observeEvent(input$txtFile, {
      in_txtFile <- input$txtFile
      if (is.null(in_txtFile))
        return()
      file.copy(in_txtFile$datapath, file.path(".", in_txtFile$name))  # NOTE: this file.path needs to reflect the location of exome data (user edit)
    })
    
    output$log <- renderText({
      ### 1sec refresh
      invalidateLater(1000, session)
      ### read log file 40 tail
      logFile <- list.files(path = paste0(input$HomeDirectory), pattern = "*.log", full.names = T)
      if (length(logFile) == 0) return(NULL)
      text_log <- readLines(logFile) %>% tail(10) %>% paste(collapse = "\n")
      return(text_log)
    })
    
  }
##/END