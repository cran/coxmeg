% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fit_ppl.R
\name{fit_ppl}
\alias{fit_ppl}
\title{Estimate HRs using PPL given a known variance component (tau)}
\usage{
fit_ppl(
  X,
  outcome,
  corr,
  type,
  tau,
  eps = 1e-06,
  order = 1,
  solver = NULL,
  spd = TRUE,
  verbose = TRUE
)
}
\arguments{
\item{X}{A matrix of the predictors. Can be quantitative or binary values. Categorical variables need to be converted to dummy variables. Each row is a sample, and the predictors are columns.}

\item{outcome}{A matrix contains time (first column) and status (second column). The status is a binary variable (1 for failure / 0 for censored).}

\item{corr}{A relatedness matrix or a List object of matrices if there are multiple relatedness matrices. They can be a matrix or a 'dgCMatrix' class in the Matrix package. The matrix (or the sum if there are multiple) must be symmetric positive definite or symmetric positive semidefinite. The order of subjects must be consistent with that in outcome.}

\item{type}{A string indicating the sparsity structure of the relatedness matrix. Should be 'bd' (block diagonal), 'sparse', or 'dense'. See details.}

\item{tau}{A positive scalar or vector. A variance component(s) given by the user. If there are more than one related matrix, this must be a vector, the length of which corresponds to the number of matrices.}

\item{eps}{An optional positive value indicating the relative convergence tolerance in the optimization algorithm. Default is 1e-6.}

\item{order}{An optional integer value starting from 0. Only valid when dense=FALSE. It specifies the order of approximation used in the inexact newton method. Default is 1.}

\item{solver}{An optional binary value that can be either 1 (Cholesky Decomposition using RcppEigen) or 2 (PCG). Default is NULL, which lets the function select a solver. See details.}

\item{spd}{An optional logical value indicating whether the relatedness matrix is symmetric positive definite. Default is TRUE.}

\item{verbose}{An optional logical value indicating whether to print additional messages. Default is TRUE.}
}
\value{
beta: The estimated coefficient for each predictor in X.

HR: The estimated HR for each predictor in X.

sd_beta: The estimated standard error of beta.

p: The p-value.

iter: The number of iterations until convergence.

ppl: The PPL when the convergence is reached.
}
\description{
\code{fit_ppl} returns estimates of HRs and their p-values given a known variance component (tau).
}
\section{About \code{type}}{

Specifying the type of the relatedness matrix (whether it is block-diagonal, general sparse, or dense). In the case of multiple relatedness matrices, it refers to the type of the sum of these matrices.
\itemize{ 
\item{"bd"}{ - used for a block-diagonal relatedness matrix, or a sparse matrix the inverse of which is also sparse. }
\item{"sparse"}{ - used for a general sparse relatedness matrix the inverse of which is not sparse.}
\item{"dense"}{ - used for a dense relatedness matrix.}
}
}

\section{About \code{spd}}{

When \code{spd=TRUE}, the relatedness matrix is treated as SPD. If the matrix is SPSD or not sure, use \code{spd=FALSE}.
}

\section{About \code{solver}}{

Specifying which method is used to solve the linear system in the optimization algorithm.  
\itemize{ 
\item{"1"}{ - Cholesky decompositon (RcppEigen:LDLT) is used to solve the linear system.}
\item{"2"}{ - PCG is used to solve the linear system. When \code{type='dense'}, it is recommended to set \code{solver=2} to have better computational performance.}
}
}

\examples{
library(Matrix)
library(MASS)
library(coxmeg)

## simulate a block-diagonal relatedness matrix
tau_var <- 0.2
n_f <- 100
mat_list <- list()
size <- rep(10,n_f)
offd <- 0.5
for(i in 1:n_f)
{
  mat_list[[i]] <- matrix(offd,size[i],size[i])
  diag(mat_list[[i]]) <- 1
}
sigma <- as.matrix(bdiag(mat_list))
n <- nrow(sigma)

## simulate random effexts and outcomes
x <- mvrnorm(1, rep(0,n), tau_var*sigma)
myrates <- exp(x-1)
y <- rexp(n, rate = myrates)
cen <- rexp(n, rate = 0.02 )
ycen <- pmin(y, cen)
outcome <- cbind(ycen,as.numeric(y <= cen))

## fit the ppl
re = fit_ppl(x,outcome,sigma,type='bd',tau=0.5,order=1)
re
}
\keyword{Cox}
\keyword{mixed-effects}
\keyword{model}
