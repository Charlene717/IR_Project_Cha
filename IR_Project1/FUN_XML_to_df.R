XML_to_df = function(input.datapath,Keyword){
  
  
    ##### XML to df #####
    XML.df <- data.frame(matrix(nrow = 0,ncol = 9))
    colnames(XML.df) <- c("NO.","PMID","PubYear","Title","Abstract","CHAR","WORD","SENT","Search Word")
    
    xml.all <- list()
    
    for (k in 1:length(input.datapath)) {
      xml1 <- xmlParse(input.datapath[k], encoding="UTF-8") %>% 
        xmlToList() 
      xml.all <- c(xml.all,xml1)
      rm(xml1)
    }   
    
    
    for (i in 1:length(xml.all)) {
      
      Abstract <- xml.all[[i]][["MedlineCitation"]][["Article"]][["Abstract"]]
      
      if (length(Abstract)==0 ) {
        XML.df[i,1] <- i
        XML.df[i,2] <- paste0("PMID: ",xml.all[[i]][["MedlineCitation"]][["PMID"]][["text"]])
        # XML.df[i,2] <- paste0("PMID: ",xml.all[[i]][["MedlineCitation"]][[1]][["text"]])
        
        #   XML.df[i,2] <- paste0("PMID: ",xml.all[[i]][["PubmedArticle"]][["PubmedData"]][["ArticleIdList"]][["ArticleId"]][["text"]])
        XML.df[i,3] <- xml.all[[i]][["MedlineCitation"]][["Article"]][["Journal"]][["JournalIssue"]][["PubDate"]][["Year"]]
        XML.df[i,4] <- xml.all[[i]][["MedlineCitation"]][["Article"]][["ArticleTitle"]]
        XML.df[i,5:9] <- 0
        
      }else {
        try({
          if (length(Abstract)==1) {
            Abstract.All <- str_c(Abstract[["AbstractText"]], collapse = " ") 
          }else {
            if (length(Abstract[["CopyrightInformation"]])==1) {

              #Abstract.All <- Abstract[[1]][["text"]]
              Abstract.All <- ""
              for (j in 1:(length(Abstract)-1)) {
              Abstract.All <- paste0(Abstract.All," ", str_c(Abstract[[j]][["text"]],collapse=" "))}
              Abstract.All <- gsub("^\\s", "", Abstract.All)
              
            }else {
              
                                  
              Abstract.All <- ""
              for (j in 1:(length(Abstract))) {
              Abstract.All <- paste0(Abstract.All," ", str_c(Abstract[[j]][["text"]],collapse=" "))}
              Abstract.All <- gsub("^\\s", "", Abstract.All)
            }
          }
          
          Abstract.All2 <- gsub('=','',Abstract.All) # https://blog.csdn.net/Yann_YU/article/details/107232946 #https://r3dmaotech.blogspot.com/2016/04/r.html
          
          
          Abstract.All_df <- tibble(line = 1:length(Abstract.All), text = Abstract.All)

          try({
          Abstract.All_df %>%
            unnest_tokens(word, text) -> Abstract.All_df.Word
          })
          # Abstract.All_df <- strsplit(Abstract.All, " ")
          # Abstract.All_df.Word <- as.data.frame(Abstract.All_df)
          # Abstract.All_df.Word <- as.data.frame(str_replace_all(Abstract.All_df.Word[,1], "[[:punct:]]", " ")) # https://cloud.tencent.com/developer/ask/44882
          # Abstract.All_df.Word <- data.frame(1,Abstract.All_df.Word)
          # colnames(Abstract.All_df.Word) <- c("line", "word")
        
        Abstract.All_df.Word2 <- as.data.frame(Abstract.All_df.Word)
        Keyword.df <- Abstract.All_df.Word2[Abstract.All_df.Word2[,2] %in% c(Keyword,tolower(Keyword),toupper(Keyword),capitalize(Keyword)),]
        # Fill the statistic result to df
        XML.df[i,1] <- i
        XML.df[i,2] <- paste0("PMID: ",xml.all[[i]][["MedlineCitation"]][["PMID"]][["text"]])
        #  XML.df[i,2] <- paste0("PMID: ",xml.all[[i]][["PubmedArticle"]][["PubmedData"]][["ArticleIdList"]][["ArticleId"]][["text"]])
        
        XML.df[i,3] <- xml.all[[i]][["MedlineCitation"]][["Article"]][["Journal"]][["JournalIssue"]][["PubDate"]][["Year"]]
        XML.df[i,4] <- xml.all[[i]][["MedlineCitation"]][["Article"]][["ArticleTitle"]]
        
        Abstract.All.paste0 <- ""
        for (c in 1:length(Abstract.All)) {
          Abstract.All.paste0 <-paste0(Abstract.All.paste0, Abstract.All[c])
        }
        XML.df[i,5] <- Abstract.All.paste0
        
        XML.df[i,6] <- sum(nchar(Abstract.All, type = "chars", allowNA = T, keepNA = NA))  # https://stat.ethz.ch/R-manual/R-devel/library/base/html/nchar.html
        #  XML.df[i,7] <- length(as.data.frame(Abstract.All_df.Word)[,2])
        XML.df[i,7] <- sapply(str_split(Abstract.All, " "), length) # https://www.tutorialspoint.com/how-to-count-the-number-of-words-in-a-string-in-r
        #    Abstract.All2.EX <- gsub('^\\d&\\.$','',Abstract.All2) # https://blog.csdn.net/Yann_YU/article/details/107232946 #https://r3dmaotech.blogspot.com/2016/04/r.html
        
        XML.df[i,8] <- nsentence(Abstract.All2)  # https://rdrr.io/cran/quanteda/man/nsentence.html
        #  XML.df[i,8] <- length(gregexpr('[[:alnum:] ][.!?]', Abstract.All)[[1]])
        
        XML.df[i,9] <- length(as.data.frame(Keyword.df)[,2])
        rm(Abstract.All,Abstract.All2, Abstract.All_df, Abstract.All_df.Word)
        })
      }
    }

  return(XML.df)
}
