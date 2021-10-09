##### Server #####
server = function(input, output, session){
  
#####  Function setting ##### 
  
  ## Call function
  # Import R files in the same folder
  filePath <- ""
  getFilePath <- function(fileName) {
    path <- setwd(getwd())   # path <- setwd("~") # Absolute path of project folder
    filePath <<- paste0(path ,"/" , fileName)    # Combine strings without gaps  
    sourceObj <- source(filePath)  #? Assigning values to global variable
    return(sourceObj)
  }
  
  getFilePath("FUN_XML_to_df.R") # Load file
  getFilePath("FUN_JASON_to_df.R") # Load file
  
##### Main reactive #####
  df_reactive_XML = reactive({
    XML.df <- XML_to_df(input$file1$datapath,input$word_select)
  })
  
  df_reactive_JASON = reactive({
    JASON.df <- JASON_to_df(input$file2$datapath,input$word_select)
  })
  
##### summary graph #####  
  output$HisFig <- renderPlot({
    if (length(input$file1)>0 && length(input$file2)==0){
      ## Bar plot for XML
      p1 <- ggplot(df_reactive_XML(), aes(x=df_reactive_XML()[,2], y=df_reactive_XML()[,6])) + geom_bar(stat="identity")+
        geom_bar(stat="identity", fill="#f5e6e8", colour="black") +
        xlab("PMID") + ylab("Number of Characters")+ 
        theme(axis.text.x = element_text(angle=90, hjust=1)) +
        theme(axis.text=element_text(size=10), axis.title=element_text(size=14,face="bold")) 
      
      p2 <- ggplot(df_reactive_XML(), aes(x=df_reactive_XML()[,2], y=df_reactive_XML()[,7])) + geom_bar(stat="identity")+
        geom_bar(stat="identity", fill="#d5c6e0", colour="black")+
        xlab("PMID") + ylab("Number of Words")+ 
        theme(axis.text.x = element_text(angle=90, hjust=1)) +
        theme(axis.text=element_text(size=10), axis.title=element_text(size=14,face="bold"))  
      
      p3 <- ggplot(df_reactive_XML(), aes(x=df_reactive_XML()[,2], y=df_reactive_XML()[,8])) + geom_bar(stat="identity")+
        geom_bar(stat="identity", fill="#aaa1c8", colour="black")+
        xlab("PMID") + ylab("Number of Sentences")+ 
        theme(axis.text.x = element_text(angle=90, hjust=1)) +
        theme(axis.text=element_text(size=10), axis.title=element_text(size=14,face="bold")) 
      
      p4 <- ggplot(df_reactive_XML(), aes(x=df_reactive_XML()[,2], y=df_reactive_XML()[,9])) + geom_bar(stat="identity")+
        geom_bar(stat="identity", fill="#967aa1", colour="black")+
        xlab("PMID") + ylab("Number of Search Words")+ 
        theme(axis.text.x = element_text(angle=90, hjust=1)) +
        theme(axis.text=element_text(size=10), axis.title=element_text(size=14,face="bold")) 
      
      grid.arrange(p1, p2 ,p3 ,p4 , nrow = 1)
      
      
    }else if(length(input$file1)==0 && length(input$file2)>0){
      ## Bar plot for JASON
      p1 <- ggplot(df_reactive_JASON(), aes(x=df_reactive_JASON()[,1], y=df_reactive_JASON()[,15])) + geom_bar(stat="identity")+
        geom_bar(stat="identity", fill="#e9d8a6", colour="black") +
        xlab("User name") + ylab("Number of Characters")+ 
        theme(axis.text.x = element_text(angle=90, hjust=1)) +
        theme(axis.text=element_text(size=10), axis.title=element_text(size=14,face="bold")) 
      
      p2 <- ggplot(df_reactive_JASON(), aes(x=df_reactive_JASON()[,1], y=df_reactive_JASON()[,16])) + geom_bar(stat="identity")+
        geom_bar(stat="identity", fill="#94d2bd", colour="black")+
        xlab("User name") + ylab("Number of Words")+ 
        theme(axis.text.x = element_text(angle=90, hjust=1)) +
        theme(axis.text=element_text(size=10), axis.title=element_text(size=14,face="bold")) 
      
      p3 <- ggplot(df_reactive_JASON(), aes(x=df_reactive_JASON()[,1], y=df_reactive_JASON()[,17])) + geom_bar(stat="identity")+
        geom_bar(stat="identity", fill="#0a9396", colour="black")+
        xlab("User name") + ylab("Number of Sentences")+ 
        theme(axis.text.x = element_text(angle=90, hjust=1)) +
        theme(axis.text=element_text(size=10), axis.title=element_text(size=14,face="bold")) 
      
      p4 <- ggplot(df_reactive_JASON(), aes(x=df_reactive_JASON()[,1], y=df_reactive_JASON()[,18])) + geom_bar(stat="identity")+
        geom_bar(stat="identity", fill="#005f73", colour="black")+
        xlab("User name") + ylab("Number of Search Words")+ 
        theme(axis.text.x = element_text(angle=90, hjust=1)) +
        theme(axis.text=element_text(size=10), axis.title=element_text(size=14,face="bold")) 
      
      grid.arrange(p1, p2 ,p3 ,p4 , nrow = 1)
      
    }else{
      p1 <- ggplot()
      p2 <- ggplot()
      p3 <- ggplot()
      p4 <- ggplot()
      grid.arrange(p1, p2 ,p3,p4 , nrow = 1)
    }
  })

  
##### Summary table #####  
  output$SumTable <- renderTable({
    if (length(input$file1)>0 && length(input$file2)==0){
      df_reactive_XML()[,c(1:3,6:9)]
    }else if(length(input$file1)==0 && length(input$file2)>0){
      # df_reactive_JASON()[,c(1,2,5,15,16,17,18)]
      df_reactive_JASON()[,c(1,5,15,16,17,18)]
    }else{
      XML.df0 <- data.frame(matrix(nrow = 0,ncol = 8))
      colnames(XML.df0) <- c("NO.","ID","Time","Text","CHAR","WORD","SENT","Search Word")
      XML.df0
    }
    
  },digits=0)  

  
##### Searching the Keywords #####
  # https://newbedev.com/highlight-word-in-dt-in-shiny-based-on-regex
  df_reactive_HL = reactive({
    if(length(input$file1)>0 && length(input$file2)==0){
      XML.df.Hl <- XML_to_df(input$file1$datapath,input$word_select)
      XML.df.Hl[,c(2,4,5)] %>%
        # Filter if input is anywhere, even in other words.
        filter_all(any_vars(grepl(input$word_select, ., T, T))) %>% 
        # Replace complete words with same in HTML.
        mutate_all(~ gsub(
          paste(c("\\b(", input$word_select, ")\\b"), collapse = ""),
          "<span style='background-color:#d0d1ff;color:#7251b5;font-family: Calibra, Arial Black;'>\\1</span>", # font-family: Lobster, cursive
          .,
          TRUE,
          TRUE
        )
        )
    }else if(length(input$file1)==0 && length(input$file2)>0){
      JASON.df <- JASON_to_df(input$file2$datapath,input$word_select)
      JASON.df[,c(1,2,4,5,6)] %>%
        # Filter if input is anywhere, even in other words.
        filter_all(any_vars(grepl(input$word_select, ., T, T))) %>% 
        # Replace complete words with same in HTML.
        mutate_all(~ gsub(
          paste(c("\\b(", input$word_select, ")\\b"), collapse = ""),
          "<span style='background-color:#e9d8a6;color:#005f73;font-family: Calibra, Arial Black;'>\\1</span>",
          .,
          TRUE,
          TRUE
        )
        )
    }else{
      XML.df0 <- data.frame(matrix(nrow = 0,ncol = 3))
      colnames(XML.df0) <- c("PMID","Title","Abstract")
      XML.df0
    }
  })

  output$table <- renderDataTable({
    datatable(df_reactive_HL(), escape = F, options = list(searchHighlight = TRUE,dom = "lt"))
  })
  
  
  
}
