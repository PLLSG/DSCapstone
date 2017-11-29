# Data Science Capstone Project - Word Prediction App
#
# Nov2017
# Author: PLLSG
#
# This is a Shiny web application. You can run the application by 
# clicking the 'Run App' button above.
#

library(shiny)
library(shinythemes)
library(data.table)
library(readr)


# Load nlm model into indexed data table
nlm<-data.table(read_rds("nlm_final.rds"))

setkey(nlm,nkey)
setorderv(nlm,c("nkey","frequency","feature"),c(1,-1,1))


# Define UI for application
ui <- navbarPage(
    # Application title
    "WordPredictor",
    
    theme = shinythemes::shinytheme("flatly"),
    
    tabPanel("What's the Next Word?",
             # Side panel content
             sidebarPanel(
                 
                 textInput("sstr","Input partial phrase:"),
                 
                 sliderInput("pwords",
                             "Number of suggested word options:",
                             min=1, max=5, value=3, step=1),
                 h5(p(
                     "Select the required number of word options to be ", 
                     "offered as the next word prediction for the given input ",
                     "phrase.")),
                 br(),
                 actionButton("nwButton", "Next Word"),
                 p("Click the button to retrieve the suggested word options.")
             ),
             
             # Main panel content
             mainPanel(
                 # Dynamic display of next word suggestion options
                 uiOutput("results_ui")
             )
    ),
    
    tabPanel("About",
             h4("WordPredictor"),
             h6("Version 1.0 @2017 by PLLSG"),
             br(),
             h5(p(
                 "This app has been developed as part of the requirement ",
                 "for the Capstone Project in the Data Science ",
                 "specialization course offered by Johns Hopkins ",
                 "University's Bloomberg School of Public Health on ",
                 "Coursera.")),
             h5(p(
                 "The challenge is to build a predictive text model that ",
                 "works like that of the core function within the SwiftKey ",
                 "smart keyboard, whereby three word options are presented ",
                 "as what the next word in a phrase might be.")),
             h5(p(
                 "This entails applying data science in the area of ",
                 "natural language processing, involving the analysis of a ",
                 "large corpus of text documents to discover the structure ",
                 "in the text data & how words are put together. Steps ",
                 "taken include cleaning, normalizing & analyzing text ",
                 "data before formulating a language model along with ",
                 "appropriate algorithm to handle word contexts not seen ",
                 "in the training corpus. The text data provided for use ",
                 "as training corpus is an abstract from the Heliohost ",
                 "Corpora, collected via a web crawler searching publicly ",
                 "available sources on twitter, blogs and news sites. ",
                 "For the purpose of this project, analysis of text data ",
                 "structures from the 3 English databases in the given ",
                 "corpora was used."))
    ),
    
    tabPanel("Help",
             h4("How to use the WordPredictor app :-"),
             tags$ol(
                 tags$li(
                     "Type in a partial English phrase with at least one word ",
                     "within the input phrase text box on the left panel. "),
                 tags$li(
                     "Use the slider to specify the desired number of word ",
                     "options to be provided as suggestions for the prediction ",
                     "of the next word on the input phrase. "),
                 tags$li(
                     "Click the 'Next Word' button to activate the ",
                     "retrieval of the list of suggested word options. "),
                 tags$li(
                     "The list of next word choices will be presented on the ",
                     "right panel, with the first choice selected by default. "),
                 tags$li(
                     "Pick the word of choice by selecting the appropriate ",
                     "radio button. "),
                 tags$li(
                     "'Updated Phrase' will present the input phrase along with ",
                     "the chosen word appended. ")
             ),
             br(),
             tags$div(
                 tags$b("Caveat."),
                 tags$p(
                     "There may be cases where the app returns less ",
                     "than the indicated number of suggested next words, or ",
                     "perhaps none at all. This is due to the limitation of ",
                     "English text with which this application has been ",
                     "trained on in order to accommodate considerations for ",
                     "the app's memory size and performance constraints."))
    )
    
)


# Define WordPredictor function
wordpredictor<-compiler::cmpfun(function(sstr,nlm,pwords) {
    
    library(stringr)
    
    # Split input string into individual words
    swords<-str_split(str_to_lower(sstr),boundary("word"))[[1]]
    wnum<-length(swords)
    
    # Form ngram keys
    skey4<-ifelse(wnum>=3,
                  paste(swords[wnum-2],swords[wnum-1],swords[wnum],
                        sep="_"),"")
    skey3<-ifelse(wnum>=2,
                  paste(swords[wnum-1],swords[wnum],sep="_"),"")
    skey2<-swords[wnum]
    
    
    # Retrieve 4gram features with matching key
    f4<-nlm[skey4,on="nkey"]$feature
    
    # Retrieve 3gram features with matching key
    f3<-nlm[skey3,on="nkey"]$feature
    
    # Retrieve 2gram features with matching key
    f2<-nlm[skey2,on="nkey"]$feature
    
    plist<-c(f4,f3,f2)
    
    as.character(na.omit(
        na.omit(unique(word(plist,-1,sep="_")))[1:as.integer(pwords)]))
    
}, options=list(optimize=3))


# Define server logic
server <- function(input, output, session) {
    
    # Process input text thru WordPredictor function
    presults<-eventReactive(input$nwButton, {
        wordpredictor(input$sstr,nlm,input$pwords)
    })
    
    r_options<-list()
    
    observe({
        
        rwords <- reactiveValues(W=presults())
        
        for(i in 1:5) {
            r_options[[paste0(as.character(i),". ",
                              as.character(na.omit(rwords$W[i])))]] <-
                as.character(na.omit(rwords$W[i]))
        }
        
        
        # Render dynamic display of next word suggestion options
        output$results_ui <- renderUI({
            if (is.null(isolate(input$pwords))) {return()}
            
            tagList(
                h4("Select your choice word from this list of suggested word"),
                h4("options to form the next word in your input phrase:"),
                
                # Generate radio buttons ui according to input$pwords
                switch(as.character(isolate(input$pwords)),
                       "5" = radioButtons("inRadio", "",
                                          choices = r_options[1:5],
                                          selected = r_options[1]),
                       "4" = radioButtons("inRadio", "",
                                          choices = r_options[1:4],
                                          selected = r_options[1]),
                       "3" = radioButtons("inRadio", "",
                                          choices = r_options[1:3],
                                          selected = r_options[1]),
                       "2" = radioButtons("inRadio", "",
                                          choices = r_options[1:2],
                                          selected = r_options[1]),
                       "1" = radioButtons("inRadio", "",
                                          choices = r_options[1],
                                          selected = r_options[1])
                ),
                
                br(),br(),
                h3("Updated Phrase:"),
                h4(output$rphrase<-renderText({paste(isolate(input$sstr),
                                                     input$inRadio)}))
            )
        })
        
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
