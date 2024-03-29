% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cm_formula.R
\name{cm_formula}
\alias{cm_formula}
\title{Create A Calculated Metric Formula}
\usage{
cm_formula(
  operator = c("divide", "multiply", "subtract", "add"),
  metrics = c("visits", "singlepagevisits"),
  seg_filters = NA,
  rsid = Sys.getenv("AW_REPORTSUITE_ID"),
  company_id = Sys.getenv("AW_COMPANY_ID")
)
}
\arguments{
\item{operator}{Formula operators are divide (default), multiply, subtract, or add.}

\item{metrics}{The one or two metrics in a formula calculation}

\item{seg_filters}{A vector of segment filters to be added to a metric in the formula}

\item{rsid}{Adobe report suite ID (RSID).  If an environment variable called
\code{AW_REPORTSUITE_ID} exists in \code{.Renviron} or elsewhere and no \code{rsid} argument
is provided, then the \code{AW_REPORTSUITE_ID} value will be used. Use \code{\link[=aw_get_reportsuites]{aw_get_reportsuites()}}
to get a list of available \code{rsid} values.}

\item{company_id}{Company ID. If an environment variable called \code{AW_COMPANY_ID}
exists in \code{.Renviron} or elsewhere and no \code{company_id} argument is provided,
then the \code{AW_COMPANY_ID} value will be used. Use \code{\link[=get_me]{get_me()}} to get a list of
available \code{company_id} values.}
}
\value{
A JSON string formula to be used in a calculated metric
}
\description{
Returns a JSON string formula to be used to build a calculated (derived) metric.
}
