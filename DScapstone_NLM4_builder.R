---
#title: "DScapstone - Build NLM - 4GRAMS"
#author: "PLLSG"
#date: "Nov 2017"
---

library(readr)
library(stringr)
library(data.table)
library(quanteda)
library(parallel)
library(doParallel)

# Load & process corpora samples by iteration

Sys.time()

# *** Define number of iterations ***
itn_num<-394

# Set up to utilise parallel processing for efficiency
cluster <- makeCluster(detectCores() - 1)
registerDoParallel(cluster)

# === start of iterative ngram processing ===
for(itn in 1:itn_num) {
txttwt<-read_lines("./course_data/final/en_US/en_US.twitter.txt",
                   skip = 6000*(itn-1), n_max = 6000)
txtnws<-read_lines("./course_data/final/en_US/en_US.news.txt",
                   skip = 3000*(itn-1), n_max = 3000)
txtblg<-read_lines("./course_data/final/en_US/en_US.blogs.txt",
                   skip = 2500*(itn-1), n_max = 2500)

txtc<-c(txttwt,txtnws,txtblg)


# TEXT PRE-PROCESSING
txtdt<-data.table(text=txtc)

rm(txttwt,txtnws,txtblg,txtc)
gc()

Sys.time()

# Remove email addresses
txtdt$text<-gsub(
    "[[:alnum:]]+[\\.+-_[:alnum:]]+@[[:alnum:]]+([\\.+-_[:alnum:]])+",
    "",txtdt$text)

# Remove urls & twitter addresses
txtdt$text<-gsub(
    "(http://|https://|www\\.|@|#)[[:alnum:]]+([\\.+-_&=/[:alnum:]])+",
    "",txtdt$text)


Sys.time()

# BUILDING N-GRAM MODELS
# 1st step: Tokenize text by segmenting sentences
nstnc<-tokens(as.character(txtdt),what="sentence")

# 2nd step: Normlize all tokenized text into lower casing
nstnc<-tokens_tolower(nstnc)


Sys.time()

# 3rd step: Tokenize text into 2 & 3 ngrams
ngm4<-tokens(as.character(nstnc),
             what="word",ngrams=4,concatenator="_",
             remove_numbers=T,remove_punct=T,remove_symbols=T,
             remove_separators=T,remove_hyphens=T,
             remove_twitter=T,remove_url=T)


# Remove objects to clear & retrieve unused memory
rm(list=ls(pattern="^txt"))
rm(nstnc)
gc(verbose=FALSE)


Sys.time()

# 4th step: Generate document frequency matrices
txtdfm4<-dfm(ngm4)

# Remove objects to clear & retrieve unused memory
rm(list=ls(pattern="^ngm"))
gc(verbose=FALSE)


Sys.time()

# 5th step: Tabulate feature frequencies
ngmfq<-as.data.table(textstat_frequency(txtdfm4))

if(sum((itn/20)==1:40)) {
    write_rds(ngmfq,paste0("./course_data/final/en_US/ngmfqbak",
                           as.character(itn),".rds"))}

# Remove token & dfm objects to save memory
rm(list=ls(pattern="^txtdfm"))
gc(verbose=FALSE)


if(itn==1) {nlm<-ngmfq[,1:2]} else {
    ntmp<-merge(nlm[,1:2],ngmfq,by="feature",all=TRUE)

    # Remove objects to save memory
    rm(list=ls(pattern="^ngmfq"))
    rm(nlm)
    gc(verbose=FALSE)
    
    ntmp$frequency<-apply(ntmp[,2:3],1,sum,na.rm=TRUE)
    nlm<-ntmp[,c("feature","frequency")]
    }

# Remove ngrams that have less than 2 occurrences
if(sum((itn/10)==1:80)) {
    nlm<-subset(nlm,frequency>=2)}

if(sum((itn/20)==1:40)) {
    write_rds(nlm,paste0("./course_data/final/en_US/nlmbak",
                         as.character(itn),".rds"))}

# Remove objects to save memory
if(itn>1) rm(ntmp)
gc(verbose=FALSE)

# === end of iterative ngram processing ===
}

stopCluster(cluster)
registerDoSEQ()
Sys.time()


# BUILD NLM FOR WORD PREDICTOR APP
Sys.time()

# Remove ngrams that have less than 2 occurrences
nlm<-subset(nlm,frequency>=2)

# Create 3-grams as key column for 4-ngrams
nlm$nkey<-word(nlm$feature,1,-2,sep="_")

# Set up key & order, save NLM
setkey(nlm,nkey)
setorderv(nlm,c("nkey","frequency","feature"),c(1,-1,1))
write_rds(nlm,"./course_data/final/en_US/nlm_4g.rds")

Sys.time()
