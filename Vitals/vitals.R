#' ---
#' title: "Regression and Other Stories: Vitals"
#' author: "Andrew Gelman, Jennifer Hill, Aki Vehtari"
#' date: "`r format(Sys.Date())`"
#' ---

#' Predict weight
#' 
#' -------------
#' 

#+ setup, include=FALSE
knitr::opts_chunk$set(message=FALSE, error=FALSE, warning=FALSE, comment=NA)

#' **Load packages**
library("rprojroot")
root<-has_dirname("RAOS-Examples")$make_fix_file()
library("rstanarm")
options(mc.cores = parallel::detectCores())

#' **Load data**
vitals_full <- read.csv(root("Vitals/data","vitals.csv"))
minidata <- vitals_full[, c("weight","height","female","ethnicity","exercise","smokenow")]
minidata$weight[minidata$weight>990]=NA;
ok <- apply(is.na(minidata), 1, sum) == 0
vitals <- minidata[ok,]

#' **Show some data**
print(vitals[1:5,])

#' ### Simulating uncertainty for linear predictors and predicted values

#' **Predict weight (in pounds) from height (in inches)**
#'
#' The option `refresh = 0` supresses the default Stan sampling
#' progress output. This is useful for small data with fast
#' computation. For more complex models and bigger data, it can be
#' useful to see the progress.
fit_1 <- stan_glm(weight ~ height, data=vitals, refresh = 0)
print(fit_1)

#' **Predict weight for 66 inches person
coefs_1 <- coef(fit_1)
predicted_1 <- coefs_1[1] + coefs_1[2]*66

#' **Center heights**
vitals$c_height <- vitals$height - 66
fit_2 <- stan_glm(weight ~ c_height, data=vitals, refresh = 0)
print(fit_2)

#' **Point prediction**
new <- data.frame(c_height=4.0)
point_pred_2 <- predict(fit_2, newdata=new)

#' **Posterior simulations**
#' 
#' variation coming from posterior uncertainty in the coefficients
linpred_2 <- posterior_linpred(fit_2, newdata=new)
hist(linpred_2)

#' **Posterior predictive simulations**
#' 
#' variation coming from posterior uncertainty in the coefficients and
#' predictive uncertainty
postpred_2 <- posterior_predict(fit_2, newdata=new)
hist(postpred_2)

#' ### Indicator variables

#' **Predict weight (in pounds) from height (in inches)**
new <- data.frame(height=66)
pred <- posterior_predict(fit_1, newdata=new)
cat("Predicted weight for a 66-inch-tall person is", round(mean(pred)), "pounds with a sd of", round(sd(pred)), "\n")

#' **Including a binary variable in a regression**
fit_3 <- stan_glm(weight ~ c_height + female, data=vitals, refresh = 0)
print(fit_3)
new <- data.frame(c_height=4, female=1)
pred <- posterior_predict(fit_3, newdata=new)
cat("Predicted weight for a 70-inch-tall female is", round(mean(pred)), "pounds with a sd of", round(sd(pred)), "\n")

#' **Using indicator variables for multiple levels of a categorical predictor**<br/>
#' Include ethnicity in the regression as a factor
fit_4 <- stan_glm(weight ~ c_height + female + factor(ethnicity),
                  data=vitals, refresh = 0)
print(fit_4)

#' Choose the baseline category by setting the levels
vitals$eth <- factor(vitals$ethnicity,
  levels=c("white", "black", "hispanic", "other"))
fit_5 <- stan_glm(weight ~ c_height + female + eth, data=vitals, refresh = 0)
print(fit_5)

#' Alternatively create indicators for the four ethnic groups directly:
vitals$eth_white <- ifelse(vitals$ethnicity=="white", 1, 0)
vitals$eth_black <- ifelse(vitals$ethnicity=="black", 1, 0)
vitals$eth_hispanic <- ifelse(vitals$ethnicity=="hispanic", 1, 0)
vitals$eth_other <- ifelse(vitals$ethnicity=="other", 1, 0)
fit_6 <- stan_glm(weight ~ c_height + female + eth_black + eth_hispanic + eth_other,
                  data=vitals, refresh = 0)
print(fit_6)
