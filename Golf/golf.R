#' ---
#' title: "Regression and Other Stories: Golf"
#' author: "Andrew Gelman, Jennifer Hill, Aki Vehtari"
#' date: "`r format(Sys.Date())`"
#' ---

#' Gold putting accuracy: Fitting a nonlinear model using Stan
#' 
#' -------------
#' 

#+ setup, include=FALSE
knitr::opts_chunk$set(message=FALSE, error=FALSE, warning=FALSE, comment=NA)
# switch this to TRUE to save figures in separate files
savefigs <- FALSE

#' **Load packages**
library("rprojroot")
root<-has_dirname("RAOS-Examples")$make_fix_file()
library("rstan")
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
invlogit <- plogis

#' **Set up the data**
golf <- read.table(root("Golf/data","golf.txt"), header=TRUE, skip=2)
golf$se <- with(golf, sqrt((y/n)*(1-y/n)/n))
r <- (1.68/2)/12
R <- (4.25/2)/12
golf_data <- list(x=golf$x, y=golf$y, n=golf$n, J=nrow(golf), r=r, R=R)

#' **Plot data**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("Golf/figs","golf0.pdf"), height=5, width=7)
#'
par(mar=c(3,3,2,1), mgp=c(1.7,.5,0), tck=-.02)
with(golf, {
    plot(x, y/n, xlim=c(0, 1.1*max(x)), ylim=c(0, 1.02),
         xaxs="i", yaxs="i", pch=20, bty="l",
         xlab="Distance from hole (feet)", ylab="Probability of success",
         main="Data on putts in pro golf")
    segments(x, y/n + se, x, y/n-se, lwd=.5)
    text(x + .4, y/n + se + .02, paste(y, "/", n,sep=""), cex=.6, col="gray40")
})
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' **Fit the geometry based nonlinear model**
stanfile_golf1 <- root("Golf","golf1.stan")
writeLines(readLines(stanfile_golf1))
fit1 <- stan(file = stanfile_golf1, data = golf_data)
print(fit1)

#' Post-processing
sims1 <- extract(fit1)
sigma_hat <- median(sims1$sigma)

#' **Fit naive logistic regression**
stanfile_golf2 <- root("Golf","golf_logistic.stan")
writeLines(readLines(stanfile_golf2))
fit2 <- stan(file = stanfile_golf2, data = golf_data)
print(fit2)

#' Post-processing
sims2 <- extract(fit2)
a_hat <- median(sims2$a)
b_hat <- median(sims2$b)

#' **Plot logistic regression result**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("Golf/figs","golf1.pdf"), height=5, width=7)
#+
par(mar=c(3,3,2,1), mgp=c(1.7,.5,0), tck=-.02)
with(golf, {
    plot(x, y/n, xlim=c(0, 1.1*max(x)), ylim=c(0, 1.02),
         xaxs="i", yaxs="i", pch=20, bty="l",
         xlab="Distance from hole (feet)", ylab="Probability of success",
         main="Fitted logistic regression")
    segments(x, y/n + se, x, y/n-se, lwd=.5)
    curve(invlogit(a_hat + b_hat*x), from=0, to=1.1*max(x), add=TRUE)
    text(10.6, .57, paste("Logistic regression,\n    a = ",
                          round(a_hat, 2), ", b = ", round(b_hat, 2), sep=""))
})
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' **Plot geometry based model result**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("Golf/figs","golf2.pdf"), height=5, width=7)
#+
par(mar=c(3,3,2,1), mgp=c(1.7,.5,0), tck=-.02)
with(golf, {
    plot(x, y/n, xlim=c(0, 1.1*max(x)), ylim=c(0, 1.02),
         xaxs="i", yaxs="i", pch=20, bty="l",
         xlab="Distance from hole (feet)", ylab="Probability of success",
         main="Custom nonlinear model fit in Stan")
    segments(x, y/n + se, x, y/n-se, lwd=.5)
    x_grid <- seq(R-r, 1.1*max(x), .01)
    p_grid <- 2*pnorm(asin((R-r)/x_grid) / sigma_hat) - 1
    lines(c(0, R-r, x_grid), c(1, 1, p_grid))
    text(18.5, .26, paste("Geometry-based model,\n sigma = ",
                          round(sigma_hat*180/pi, 1), " degrees", sep=""))
})
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' **Plot geometry based model posterior draws of sigma**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("Golf/figs","golf2a.pdf"), height=5, width=7)
#+
par(mar=c(3,3,2,1), mgp=c(1.7,.5,0), tck=-.02)
with(golf, {
    plot(x, y/n, xlim=c(0, 1.1*max(x)), ylim=c(0, 1.02),
         xaxs="i", yaxs="i", pch=20, bty="l",
         xlab="Distance from hole (feet)", ylab="Probability of success",
         main="Custom nonlinear model fit in Stan")
    segments(x, y/n + se, x, y/n-se, lwd=.5)
    x_grid <- seq(R-r, 1.1*max(x), .01)
    n_sims <- length(sims1$sigma)
    for (s in sample(n_sims, 20)){
        p_grid <- 2*pnorm(asin((R-r)/x_grid) / sims1$sigma[s]) - 1
        lines(c(0, R-r, x_grid), c(1, 1, p_grid), lwd=0.5)
    }
    text(18.5, .26, "Geometry-based model,\n post draws of sigma")
})
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' **Plot two models in same figure**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("Golf/figs","golf3.pdf"), height=5, width=7)
#+
par(mar=c(3,3,2,1), mgp=c(1.7,.5,0), tck=-.02)
with(golf, {
    plot(x, y/n, xlim=c(0, 1.1*max(x)), ylim=c(0, 1.02),
         xaxs="i", yaxs="i", pch=20, bty="l",
         xlab="Distance from hole (feet)", ylab="Probability of success",
         main="Two models fit to the golf putting data")
    segments(x, y/n + se, x, y/n-se, lwd=.5)
    curve(invlogit(a_hat + b_hat*x), from=0, to=1.1*max(x), add=TRUE)
    x_grid <- seq(R-r, 1.1*max(x), .01)
    p_grid <- 2*pnorm(asin((R-r)/x_grid) / sigma_hat) - 1
    lines(c(0, R-r, x_grid), c(1, 1, p_grid))
    text(10.3, .58, "Logistic regression")
    text(18.5, .24, "Geometry-based model")
})
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()
