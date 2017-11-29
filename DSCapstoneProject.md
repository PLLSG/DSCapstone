WordPredictor
========================================================
author: PohLin LEE
date: Nov 2017
autosize: true

Introduction
========================================================
<small>
[WordPredictor](https://pllsg.shinyapps.io/WordPredictor/) is a web-based interactive app that has been developed as part of the requirement for the Capstone Project in the Data Science specialization course offered by Johns Hopkins University's Bloomberg School of Public Health on Coursera.

The challenge is to build a predictive text model that works like that of the core function within the SwiftKey smart keyboard, whereby three word options are presented as what the next word in a phrase might be.

This entails applying data science in the area of natural language processing, involving the analysis of a large corpus of text documents to discover the structure in the text data & how words are put together. Steps taken include cleaning, normalizing & analyzing text data before formulating a language model along with appropriate algorithm to handle word contexts not seen in the training corpus. 
</small>

Application Background
========================================================
<small><small><small>
The app was built with the aid of the following :-

**Tools/Environments Used**  
* Shiny, a web application framework for R  
* RStudio, an integrated development environment (IDE) for R  
* shinyapps.io, a cloud-based web hosting platform  
* R source code for building the app can be found [here](https://github.com/PLLSG/DSCapstone)

**Data**  
For purpose of training the Language Model, text data within the 3 English databases from an abstract of the __*Heliohost Corpora*__ was used. The HC Corpora is a collection of text documents gathered from publicly available sources on twitter, blogs and news sites via a web crawler.

**Language Model**  
The Language Model __*(LM)*__ is the foundation on which the app's predictive text capability is built. For this app, the LM is constructed with 2, 3 and 4 N-grams. 
</small></small></small>

<small><small><small><small>
NOTE:  an N-gram is a sequence of N words forming a phrase, eg. 2-gram or bigram is a two-word phrase, while 3-gram or trigram is a three-word phrase and a phrase sequence of four words is a 4-gram (quadgram).
</small></small></small></small>

Building WordPredictor App
========================================================
<small><small><small>
Following are the key aspects in the development of this app :-  

**Building the Language Model**
- Text data from the training corpus is cleansed & normalized before being analyzed and formulated into 2, 3 & 4 N-grams with their associated frequency counts
- Each N-gram is then defined with it's N-1 previous word sequence as the Key, after which pruning is done to retain only the top 5 most frequent N-grams for each unique Key value

**Handling New Word Sequences**
- Employed the _Stupid Backoff_ smoothing method to handle word contexts not captured in the LM
- Algorithm works by first trying to match input phrase using the Key of the 4-grams, failing which the 3-grams will be matched, with backoff terminating at 2-grams
- The Nth word of the matched N-grams will be listed as the predicted word options for the next word in the given input phrase

**Evaluating Accuracy**
- Used the [Next Word Prediction Benchmark tool](https://github.com/hfoffani/dsci-benchmark) shared by Data Science Capstone Project course alumni
- The benchmark tool runs the LM on a test set of text data that was not included in the training corpus
- This LM rated __*21.37%*__ for Overall Top-3 Precision. As a reference, SwiftKey themselves reported that their smart keyboard app predicts correctly a little less than _*30%*_ of the time

</small></small></small>

Using WordPredictor
========================================================
<small><small>
Use the WordPredictor app to provide suggestions for what the next word of a given phrase might be.    
</small></small>

<small><small><small>
For instance, given __*"This app is top of the"*__ as the input phrase, clicking the **Next Word** button yields a pre-selected number of word options from which one can select to complete the given input phrase :-
</small></small></small>
![](wpeg.png)

Acknowledgements & References
========================================================
<small><small><small>

[Language Modeling with Ngrams- Speech and Language Processing. Daniel Jurafsky & James H. Martin. Copyright 2016.](https://web.stanford.edu/~jurafsky/slp3/4.pdf)

[Language Modeling- Course notes for NLP by Michael Collins, Columbia University](http://www.cs.columbia.edu/~mcollins/lm-spring2013.pdf)

[Machine Learning for Language Modelling. Marek Rei, University of Tartu, University of Cambridge](http://www.marekrei.com/pub/Machine_Learning_for_Language_Modelling_-_lecture2.pdf)

[Large Language Models in Machine Translation. Thorsten Brants,Ashok C. Popat,Peng Xu,Franz J. Och,Jeffrey Dean](http://www.aclweb.org/anthology/D07-1090.pdf)

[Capstone Strategy. Data Science Specialization Community Mentor, Len Greski](https://github.com/lgreski/datasciencectacontent/blob/master/markdown/capstone-simplifiedApproach.md)

[Capstone: Choosing a Text Analysis package. Data Science Specialization Community Mentor, Len Greski ](https://github.com/lgreski/datasciencectacontent/blob/master/markdown/capstone-choosingATextPackage.md)

[Next word prediction benchmark. Hernan Foffani,Jan-San](https://github.com/hfoffani/dsci-benchmark)

</small></small></small>
