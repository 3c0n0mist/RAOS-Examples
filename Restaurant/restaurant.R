#' ---
#' title: "Regression and Other Stories: Restaurant"
#' author: "Andrew Gelman, Jennifer Hill, Aki Vehtari"
#' date: "`r format(Sys.Date())`"
#' ---

#' Demonstration of using Stan for optimization
#' 
#' -------------
#' 

#+ setup, include=FALSE
knitr::opts_chunk$set(message=FALSE, error=FALSE, warning=FALSE, comment=NA)

#' **Load packages**
library("rprojroot")
root<-has_dirname("RAOS-Examples")$make_fix_file()
library("rstan")
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

#' **Show Stan code**
writeLines(readLines(root("Restaurant","restaurant.stan")))

#' **Compile Stan code**
#+ results='hide'
resto <- stan_model(root("Restaurant","restaurant.stan"))

#' **Optimize**
fit <- optimizing(resto)
print(fit)
