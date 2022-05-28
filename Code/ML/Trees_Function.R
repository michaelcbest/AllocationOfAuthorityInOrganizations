#In this script I try to allocate observations which do not have matching 
#characteristics to control group

#You can set your working directory here and install the packages you don't already have
#and the code should run then

#This code runs a simple version of random forest - bagging of different trees

#After running this code, the function gets stored in R global environment
#Post that one can select the product details from ItemCodes.R and run the BaggingCode.R


rm(list = ls())
setwd("C:/Users/saksh/Dropbox/PunjabProcurement/Code/Data Cleaning/ML/Final")

#install.packages("devtools")
#install.packages("tree")
#install.packages("randomForest")
#install.packages("party")
#install.packages("dplyr")
#install.packages("rpart.utils")
#install.packages("DescTools")
#loading data 
#install.packages("readstata13")
#install.packages("rpart.plot")
#install.packages("tidyverse")

#' reg_rf
#' Fits a random forest with a continuous scaled features and target 
#' variable (regression)
#'
#' @param formula an object of class formula
#' @param n_trees an integer specifying the number of trees to sprout
#' @param feature_frac an numeric value defined between [0,1]
#'                     specifies the percentage of total features to be used in
#'                     each regression tree
#' @param data a data.frame or matrix
#'
#' @importFrom plyr raply
#' @return
#' @export
require(tree)
library(rpart)
library(treeClust)
require(plyr)
library(dplyr)
library(rpart.utils)
library(rpart.plot)
library(DescTools)
library(tidyverse)
library(readstata13)
library(foreign)


reg_rf <- function(formula, n_trees, feature_frac, data) {
  
  # define function to sprout a single tree
  sprout_tree <- function(formula, feature_frac, data) {
    # extract features (from the formula, extract everything except the dependent variable)
    features <- all.vars(formula)[-1]
    
    # extract target (from the formula, extract the dependent variables)
    #target is the dependent variable
    target <- all.vars(formula)[1]
    
    # bag the data
    # - randomly sample the data with replacement (duplicates are possible)
    # as of now we are not splitting the data into training and test datasets
    # to divide the datasets into 80% training and and 20% test data use-
    # data_idx = sample(1:nrow(data), nrow(data) /1.25 )
    # data_trn = data[data_idx,]
    # data_tst = data[-data_idx,]
    
    #size of the bootstrap sample should be the same as the sample size hence the size
    # in the following code is n(row)
    
    #we'll train the model on this data
    train <- data[sample(1:nrow(data), size = nrow(data), replace = TRUE),]
    
    # randomly sample features
    # - only fit the regression tree with feature_frac * 100 % of the features
    features_sample <- sample(features, size = ceiling(length(features) * feature_frac),
                              replace = FALSE)
    
    # create new formula
    #paste0 concatenates a series of strings
    #collapse specifies the element which is used to separate strings. 
    
    # as of now the following step gives a tree where only a random sample of the features is used to make the tree
    # not exactly what mtry does - it should take a random sample of features at each split
    formula_new <-as.formula(paste0(target, " ~ ", paste0(features_sample, collapse =  " + ")))
    
    # fit the regression tree
    # we can use any package for fitting trees here - tree, rpart etc.
    
    tree <- rpart(formula = formula_new,
                  data = train,
                  method="anova",model=TRUE)
    
    # we can save more things later based on what we need 
    # as of now I am saving predictions and the tree details
    return(list(tree))
  }
  
  # apply the rf_tree function n_trees times with plyr::raply
  # raply evalulates expression multiple times & then combines results into an array
  # plyr splits data apart, do stuff to it, and mash it back together
  # - track the progress with a progress bar
  
  trees <- plyr::raply(n_trees, sprout_tree(formula = formula, feature_frac = feature_frac,
                                            data = data), .progress = "text")
  
  
  ## this gives me n_tree number of trees which can then be later used to make predictions
  
}


######################################################################################
