#' Build a Calculated Metric
#'
#' This function combines formulas to create calculated metrics in Adobe Analytics
#'
#'
#' @param name This is the name of the new calculated metric (required)
#' @param description  This is the description of the segment (optional)
#' @param formula Formulas are list objects created using the [`cm_formula()`] function.
#' @param seg_filter A segment filter to be added to a metric in the formula
#' @param polarity Also known as 'Show Upward Trend As' in the UI. Options include 'positive' (default) or 'negative'.
#' This metric polarity setting shows whether Analytics should consider an upward trend in the metric as good (green) or bad (red).
#' As a result, the report’s graph will show as green or red when it’s going up.
#' @param precision Shows how many decimal places will be shown in the report.
#' The maximum number of decimal places you can specify is 10. Also known as 'Decimal Places' in the UI.
#' Default is `0`. Must be a numeric.
#' @param type Choices include Decimal (default), Time, Percent, and Currency. Also known as 'Format' in the UI.
#' @param create_cm Used to determine if the segment should be created in the
#' report suite or if the definition should be returned to be validated using cm_validate.
#' Default is FALSE
#' @param tagNames Apply tag names to the newly created calculated metric. Single string or a vector.
#' @param internal Determines if this segment is to be available in the UI.
#' Default is FALSE, meaning the segment will not be available in the UI, nor will
#' the ID be available in the `aw_get_segments` function call.
#' @param rsid Adobe report suite ID (RSID).  If an environment variable called
#' `AW_REPORTSUITE_ID` exists in `.Renviron` or elsewhere and no `rsid` argument
#' is provided, then the `AW_REPORTSUITE_ID` value will be used. Use [aw_get_reportsuites()]
#' to get a list of available `rsid` values.
#' @param debug This enables the api call information to show in the console for
#' help with debugging issues. default is FALSE
#' @param company_id Company ID. If an environment variable called `AW_COMPANY_ID`
#' exists in `.Renviron` or elsewhere and no `company_id` argument is provided,
#' then the `AW_COMPANY_ID` value will be used. Use [get_me()] to get a list of
#' available `company_id` values.
#'
#' @details
#' See more information [here](https://experienceleague.adobe.com/en/docs/analytics/components/calculated-metrics/calcmetric-workflow/cm-build-metrics)
#'
#' @return If the "create_cm" argument is set to FALSE a list object definition
#' will be returned. If the "create_cm" argument is set to TRUE and the calculated metric
#' is valid it will return a data frame of the newly created calculated metric id along
#' with some other basic meta data. If it returns an error then the error
#' response will be returned to help understand what needs to be corrected.
#'
#' @import dplyr
#' @import assertthat
#' @import stringr
#' @importFrom glue glue
#' @importFrom jsonlite toJSON
#' @export
#'
cm_build <- function(name = NULL,
                     description = NULL,
                     formula = NULL,
                     seg_filter = NULL,
                     polarity = 'positive',
                     precision = 0,
                     type = 'decimal',
                     create_cm = FALSE,
                     tagNames = NULL,
                     internal = FALSE,
                     debug = FALSE,
                     rsid = Sys.getenv('AW_REPORTSUITE_ID'),
                     company_id = Sys.getenv("AW_COMPANY_ID")){


  #validate arguments
  if(is.null(name) || is.null(formula) || is.null(rsid)) {
    stop('The arguments `name`, `formula`, and `rsid` must be provided')
  }
  if(!is.null(seg_filter)) {
  filter <- list(func = 'segment-ref',
                  id = seg_filter)
  } else if(is.null(seg_filter)) {
    filter <- NULL
  }

  definition <- if(is.null(filter)) {
    list(rsid = rsid,
         name = name,
         description = description,
         internal = internal,
         definition = list(
           formula = formula,
           version = list(1, 0, 0),
           func = 'calc-metric'),
         polarity = polarity,
         precision = precision,
         type = type)
  } else {
    list(rsid = rsid,
         name = name,
         description = description,
         internal = internal,
         definition = list(
           formula = formula,
           filters = list(filter),
           version = list(1, 0, 0),
           func = 'calc-metric'),
         polarity = polarity,
         precision = precision,
         type = type)
  }

  #defined parts of the post request
  req_path <- 'calculatedmetrics'

  body <- definition

  if (!create_cm) {
    req <- jsonlite::toJSON(body, auto_unbox = T)
    req
  } else if (create_cm) {
    req <- aw_call_api(req_path = req_path,
                       body = body,
                       debug = debug,
                       company_id = company_id)
    if(!is.null(tagNames)){
      tags_add(company_id = company_id,
               componentId = jsonlite::fromJSON(req)$id,
               componentType = 'calculatedMetric',
               tagNames = tagNames,
               debug = debug)
    }
    jsonlite::fromJSON(req)
  }
}
