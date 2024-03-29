% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cm_copy.R
\name{cm_copy}
\alias{cm_copy}
\title{Copy a Calculated Metric}
\usage{
cm_copy(
  id,
  name = NULL,
  description = NULL,
  polarity = NULL,
  precision = NULL,
  type = NULL,
  create_cm = FALSE,
  debug = FALSE,
  rsid = NULL,
  company_id = Sys.getenv("AW_COMPANY_ID")
)
}
\arguments{
\item{id}{The id of the old calculated metric}

\item{name}{This is the name of the new calculated metric.  If not provided, the prefix "Copy_" will be added to the existing name. (optional)}

\item{description}{This is the description of the segment (optional)}

\item{polarity}{Also known as 'Show Upward Trend As' in the UI. Options include 'positive' or 'negative'.
Default is based on original calculated metric definition.
This metric polarity setting shows whether Analytics should consider an upward trend in the metric as good (green) or bad (red).
As a result, the report’s graph will show as green or red when it’s going up.
Default is based on original calculated metric definition.}

\item{precision}{Shows how many decimal places will be shown in the report.
The maximum number of decimal places you can specify is 10. Also known as 'Decimal Places' in the UI.
Default is based on original calculated metric definition.}

\item{type}{Choices include decimal (default), time, percent, and currency.
Also known as 'Format' in the UI. Default is based on original calculated metric definition.}

\item{create_cm}{Used to determine if the segment should be created in the
report suite or if the definition should be returned to be validated using cm_validate.
Default is FALSE}

\item{debug}{This enables the api call information to show in the console for
help with debugging issues. default is FALSE}

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
If the "create_cm" argument is set to FALSE a list object definition
will be returned. If the "create_cm" argument is set to TRUE and the calculated metric
is valid it will return a data frame of the newly created calculated metric id along
with some other basic meta data. If it returns an error then the error
response will be returned to help understand what needs to be corrected.
}
\description{
This function copies and existing function and creates a duplicate based on the definition.
}
\details{
See more information \href{https://experienceleague.adobe.com/docs/analytics/components/calculated-metrics/calcmetric-workflow/cm-build-metrics.html?lang=en}{here}
}
