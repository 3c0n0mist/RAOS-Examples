#' ---
#' title: "Regression and Other Stories: Pearson Lee Heights"
#' author: "Andrew Gelman, Jennifer Hill, Aki Vehtari"
#' date: "`r format(Sys.Date())`"
#' ---
#'

#' The heredity of height. Published in 1903 by Karl Pearson and Alice Lee.
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
library("rstanarm")
options(mc.cores = parallel::detectCores())
library("HistData")

#' **Load data**
heights <- read.table(root("PearsonLee/data","Heights.txt"), header=TRUE)
daughter_height <- heights$daughter_height
mother_height <- heights$mother_height
n <- length(mother_height)

#' **Linear regression**
# MCMC sampling
#+ results='hide'
tic();fit_1 <- stan_glm(daughter_height ~ mother_height, data = heights, algorithm='optimizing', thin=1);toc()
# optimization and normal approximation at the mode is faster with similar
# accuracy, because n is big and there are only three parameters to estimate
# fit_1 <- stan_glm(daughter_height ~ mother_height, data = heights,
#                   algorithm="optimizing")
#+
print(fit_1, digits=2)
ab_hat <- coef(fit_1)

#' **Plot mothers' and daughters' heights**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("PearsonLee/figs","PearsonLee1.pdf"), height=4.5, width=4.5)
#+
par(mar=c(3, 3, 2, 1), mgp=c(1.7, .5, 0), tck=-.01)
par(pty="s")
rng <- range(mother_height, daughter_height)
plot(mother_height, daughter_height, xlab="Mother's height (inches)", ylab="Adult daughter's height (inches)", bty="l", xlim=rng, ylim=rng, xaxt="n", yaxt="n", pch=20, cex=.5)
x <- seq(48, 84, 6)
axis(1, x)
axis(2, x)
for (i in x){
  abline(h=i, col="gray70", lty=2)
  abline(v=i, col="gray70", lty=2)
}
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' **Plot mothers' and daughters' heights with jitter**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("PearsonLee/figs","PearsonLee2.pdf"), height=4.5, width=4.5)
#+
mother_height_jitt <- mother_height + runif(n, -0.5, 0.5)
daughter_height_jitt <- daughter_height + runif(n, -0.5, 0.5)
par(mar=c(3, 3, 2, 1), mgp=c(1.7, .5, 0), tck=-.01)
par(pty="s")
rng <- range(mother_height, daughter_height)
plot(mother_height_jitt, daughter_height_jitt, xlab="Mother's height (inches)", ylab="Adult daughter's height (inches)", bty="l", xlim=rng, ylim=rng, xaxt="n", yaxt="n", pch=20, cex=.2)
x <- seq(48, 84, 6)
axis(1, x)
axis(2, x)
for (i in x){
  abline(h=i, col="gray70", lty=2)
  abline(v=i, col="gray70", lty=2)
}
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' **Plot mothers' and daughters' heights and fitted regression line**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("PearsonLee/figs","PearsonLee3a.pdf"), height=4.5, width=4.5)
#+
par(mar=c(3, 3, 2, .1), mgp=c(2, .5, 0), tck=-.01)
par(pty="s")
rng <- range(mother_height, daughter_height)
plot(mother_height_jitt, daughter_height_jitt, xlab="Mother's height (inches)", ylab="Adult daughter's height (inches)", bty="l", xlim=c(rng[1], rng[2]), ylim=rng, xaxt="n", yaxt="n", pch=20, cex=.2)
x <- seq(48, 84, 6)
axis(1, x)
axis(2, x)
for (i in x){
  abline(h=i, col="gray70", lty=2)
  abline(v=i, col="gray70", lty=2)
}
abline(ab_hat[1], ab_hat[2], lwd=3, col="white")
abline(ab_hat[1], ab_hat[2], lwd=1.5)
points(mean(mother_height), mean(daughter_height), pch=20, cex=2, col="white")
mtext("Mothers' and daughters' heights,\naverage of data, and fitted regression line", side=3, line=0)
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' **Plot fitted regression line and the average of the data**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("PearsonLee/figs","PearsonLee3b.pdf"), height=4.5, width=4.5)
#+
par(mar=c(3, 3, 2, .1), mgp=c(2, .5, 0), tck=-.01)
par(pty="s")
rng <- range(mother_height, daughter_height)
plot(mother_height_jitt, daughter_height_jitt, xlab="Mother's height (inches)", ylab="Adult daughter's height (inches)", bty="l", xlim=c(rng[1], rng[2]), ylim=rng, xaxt="n", yaxt="n", pch=20, cex=.2, type="n")
x <- seq(54, 72, 6)
axis(1, x)
axis(2, x)
abline(ab_hat[1], ab_hat[2], lwd=3, col="white")
abline(ab_hat[1], ab_hat[2], lwd=1.5)
lines(rep(mean(mother_height), 2), c(0, mean(daughter_height)), lwd=.5)
lines(c(0, mean(mother_height)), rep(mean(daughter_height), 2), lwd=.5)
axis(1, mean(mother_height), round(mean(mother_height), 1))
axis(2, mean(daughter_height), round(mean(daughter_height), 1))
text(68, 64, paste("y =", round(ab_hat[1]), "+", round(ab_hat[2], 2), "x"))
text(63, 62, paste("Equivalently,  y = ", round(mean(daughter_height), 1), " + ", round(ab_hat[2], 2), " * (x - ", round(mean(mother_height), 1), ")", sep=""))
points(mean(mother_height), mean(daughter_height), pch=20, cex=2)
mtext("The fitted regression line and the average of the data      ", side=3, line=1)
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' **Plot fitted regression line**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("PearsonLee/figs","PearsonLee4a.pdf"), height=4, width=4.5)
#+
par(mar=c(3, 3, 2, .1), mgp=c(2, .5, 0), tck=-.01)
plot(c(0, 100), c(0, 100), xlab="", ylab="", xaxt="n", yaxt="n", bty="n", type="n")
abline(h=0)
abline(v=0)
axis(2, round(ab_hat[1]), tck=0, las=1)
axis(1, 0, tck=0, las=1, line=-.4)
axis(2, 0, tck=0, las=1)
abline(ab_hat[1], ab_hat[2], lwd=2)
text(40, 40, paste("slope", round(ab_hat[2], 2)))
mtext(paste("The line, y =", round(ab_hat[1]), "+", round(ab_hat[2], 2), "x"), side=3, line=0)
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' **Plot data and fitted regression line in the context of the data**
#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("PearsonLee/figs","PearsonLee4b.pdf"), height=4, width=4.5)
#+
par(mar=c(3, 3, 2, .1), mgp=c(2, .5, 0), tck=-.01)
plot(c(0, 100), c(0, 100), xlab="", ylab="", xaxt="n", yaxt="n", bty="n", type="n")
abline(h=0)
abline(v=0)
axis(2, round(ab_hat[1]), tck=0, las=1)
points(mother_height_jitt, daughter_height_jitt, pch=20, cex=.2)
abline(ab_hat[1], ab_hat[2], lwd=3, col="white")
abline(ab_hat[1], ab_hat[2], lwd=1.5)
axis(1, 0, tck=0, las=1, line=-.4)
axis(2, 0, tck=0, las=1)
axis(1, mean(mother_height), round(mean(mother_height), 1), tck=0, las=1, line=-.4)
axis(2, mean(daughter_height), round(mean(daughter_height), 1), tck=0, las=1, line=-.7)
lines(rep(mean(mother_height), 2), c(0, mean(daughter_height)), lwd=.5)
lines(c(0, mean(mother_height)), rep(mean(daughter_height), 2), lwd=.5)
text(40, 43, paste("slope", round(ab_hat[2], 2)), cex=.9)
mtext(paste("The line, y =", round(ab_hat[1]), "+", round(ab_hat[2], 2), "x, in the context of the data"), side=3, line=0)
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()
