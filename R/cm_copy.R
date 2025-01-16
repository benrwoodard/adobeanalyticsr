#' Copy a Calculated Metric
#'
#' This function copies and existing function and creates a duplicate based on the definition.
#'
#' @param id The id of the old calculated metric
#' @param name This is the name of the new calculated metric.  If not provided, the prefix "Copy_" will be added to the existing name. (optional)
#' @param description  This is the description of the segment (optional)
#' @param polarity Also known as 'Show Upward Trend As' in the UI. Options include 'positive' or 'negative'.
#' Default is based on original calculated metric definition.
#' This metric polarity setting shows whether Analytics should consider an upward trend in the metric as good (green) or bad (red).
#' As a result, the report’s graph will show as green or red when it’s going up.
#' Default is based on original calculated metric definition.
#' @param precision Shows how many decimal places will be shown in the report.
#' The maximum number of decimal places you can specify is 10. Also known as 'Decimal Places' in the UI.
#' Default is based on original calculated metric definition.
#' @param type Choices include decimal (default), time, percent, and currency.
#' Also known as 'Format' in the UI. Default is based on original calculated metric definition.
#' @param create_cm Used to determine if the segment should be created in the
#' report suite or if the definition should be returned to be validated using cm_validate.
#' Default is FALSE
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
#' @importFrom jsonlite unbox
#' @importFrom jsonlite toJSON
#' @importFrom glue glue
#' @export
#'
cm_copy <- function(id,
                    name = NULL,
                    description = NULL,
                    polarity = NULL,
                    precision = NULL,
                    type = NULL,
                    create_cm = FALSE,
                    debug = FALSE,
                    rsid = NULL,
                    company_id = Sys.getenv("AW_COMPANY_ID")){


  #validate arguments
  if(is.null(id)) {
    stop('The arguments `id` and `name` must be provided')
  }

  ## Use the id provided to grab the original calculated metric definition
  cm_var <- aw_get_calculatedmetrics(filterByIds = id,
                                     expansion = 'definition',
                                     company_id = company_id)
  ## Name the new calculated metric using the original name and adding "copy" to it
  if(is.null(name)) {
    name <- glue::glue('Copy_{cm_var$name}')
  }
  ## Define description according to the original definition
  if(is.null(description)){
    description <- jsonlite::unbox(cm_var$description)
  }
  ## Define polarity according to the original definition
  if(is.null(polarity)){
    polarity <- jsonlite::unbox(cm_var$polarity)
  }
  ## Define precision according to the original definition
  if(is.null(precision)){
    precision <- jsonlite::unbox(cm_var$precision)
  }
  ## Define type according to the original definition
  if(is.null(type)){
    type <- jsonlite::unbox(cm_var$type)
  }
  ## Define rsid according to the original definition
  if(is.null(rsid)){
    rsid <- jsonlite::unbox(cm_var$rsid)
  }

  ## create the complete definition object
  definition <- list(rsid = rsid,
                     name = name,
                     description = description,
                     definition = jsonlite::unbox(cm_var$definition),
                     polarity = polarity,
                     precision = precision,
                     type = type)


  #defined parts of the post request
  req_path <- 'calculatedmetrics'

  ## if create_cm is set to TRUE then hit the API endpoint, if FALSE then return
  ## the calculated metric object which can be saved and/or validated
  if (!create_cm) {
    req <- jsonlite::toJSON(definition, auto_unbox = T)
  } else if (create_cm) {
    req <- aw_call_api(req_path = req_path,
                       body = definition,
                       debug = debug,
                       company_id = company_id)
  }
  req
}
