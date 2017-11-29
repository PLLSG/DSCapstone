#title: "DScapstone - Cleaning & Trimming NLM"
#author: "PLLSG"
#date: "Nov 2017"
---
    
library(readr)
library(stringr)
library(data.table)

# Combine 2-/3-ngram model with 4-ngram model

nlm<-data.table(read_rds("./course_data/final/en_US/nlm_2nd.rds"))
nlm4g<-data.table(read_rds("./course_data/final/en_US/nlm_4g.rds"))
nlm<-rbind(nlm,nlm4g)

# Index on ngram prefix & sort in decreasing frequency
setkey(nlm,nkey)
setorderv(nlm,c("nkey","frequency","feature"),c(1,-1,1))


# Remove ngrams which start or end with numerals
nlm_sub<-nlm[grep("^[a-z]",nlm$nkey)]
nlm_sub<-nlm_sub[-(grep("_([a-z])?[0-9]+([a-z])?$",nlm_sub$feature))]


# Remove ngrams containing profane words
exclwords<-read_lines("./course_data/final/en_US/exclusion_words.txt")
exclpattn<-str_c(exclwords,collapse="|")
nlm_sub<-nlm_sub[-(grep(exclpattn,nlm_sub$feature))]


# Trim NLM to carry at most 5 top frequency ngrams for each ngram prefix
nlm_sub<-nlm_sub[,head(.SD,5),by="nkey"]


# Save final NLM
write_rds(nlm_sub,"./course_data/final/en_US/nlm_final.rds")

