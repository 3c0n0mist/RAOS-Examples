#' ---
#' title: "Regression and Other Stories: Logistic regression priors"
#' author: "Andrew Gelman, Jennifer Hill, Aki Vehtari"
#' date: "`r format(Sys.Date())`"
#' ---

#' Effect of priors in logistic regression
#' 
#' -------------
#' 

#+ setup, include=FALSE
knitr::opts_chunk$set(message=FALSE, error=FALSE, warning=FALSE, comment=NA)

#' **Load packages**
library("arm")
library("rstanarm")
options(mc.cores = parallel::detectCores())

#' **Define a function running glm and stan_glm with simulated data**<br>
#' Arguments are the number of simulated observations, and prior
#' parameters a and
bayes_sim <- function(n, a=-2, b=0.8){
  x <- runif(n, -1, 1)
  z <- rlogis(n, a + b*x, 1)
  y <- ifelse(z>0, 1, 0)
  fake <- data.frame(x, y)
  glm_fit <- glm(y ~ x, family = binomial(link = "logit"), data = fake)
  stan_fit <- stan_glm(y ~ x, family = binomial(link = "logit"),
     prior=normal(0.5, 0.5, autoscale=FALSE), data = fake)
  display(glm_fit, digits=1)
  print(stan_fit, digits=1)
}

#' **Fit models to an increasing number of observations**
set.seed(363852)
bayes_sim(10)
bayes_sim(100)
bayes_sim(1000)
