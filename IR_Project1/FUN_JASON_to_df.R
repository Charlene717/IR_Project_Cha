library(jsonlite)

JASON_to_df = function(input.datapath,Keyword){
try({  
##### JASON to df #####
  jason.all <- list()
  for (k in 1:length(input.datapath)) {
    jason1 <- fromJSON(input.datapath[k])
    jason.all <- rbind(jason.all,jason1)
    rm(jason1)
  }
  jason.all$tweet_text <- gsub('^"|"$','',jason.all$tweet_text) # https://blog.csdn.net/Yann_YU/article/details/107232946 #https://r3dmaotech.blogspot.com/2016/04/r.html
 # jason.all$tweet_text <- gsub( "\\..*http.?$",".",jason.all$tweet_text)
  
  jason.all["CHAR"]=0
  jason.all["WORD"]=0
  jason.all["SENT"]=0
  jason.all["Search Word"]=0
  jason.all["NO."]=0
  for (i in 1:length(jason.all[,1])) {
    try({
    jason.all[i,15] <- sum(nchar(jason.all[i,colnames(jason.all)=="tweet_text"], type = "chars", allowNA = T, keepNA = NA))
    
    Twtext.All <- jason.all[i,colnames(jason.all)=="tweet_text"]
    Twtext.All_df <- tibble(line = 1:length(Twtext.All), text = Twtext.All)
    Twtext.All_df %>%
      unnest_tokens(word, text) -> Twtext.All_df.Word
    
    Twtext.All_df.Word2 <- as.data.frame(Twtext.All_df.Word)
    Keyword.df <- Twtext.All_df.Word2[Twtext.All_df.Word2[,2] %in% c(Keyword,tolower(Keyword),toupper(Keyword),capitalize(Keyword)),]
    
   # jason.all[i,16] <- length(as.data.frame(Twtext.All_df.Word)[,2])
    jason.all[i,16] <- sapply(str_split(Twtext.All, " "), length)
    jason.all[i,17] <- nsentence(Twtext.All) # https://rdrr.io/cran/quanteda/man/nsentence.html
   # jason.all[i,17] <- length(gregexpr('[[:alnum:] ][.!?]', Twtext.All)[[1]])
   # jason.all[i,17] <- length(gregexpr('[[:alnum:] ][.!?]', Twtext.All_df[,2])[[1]])
    jason.all[i,18] <- length(as.data.frame(Keyword.df)[,2])
    jason.all[i,19] <- i
    })
  }
  JASON.df <- jason.all
})  
return(JASON.df)
}
