#' Validate the definition of a Calculated Metric
#'
#' This function checks if a calculated metric JSON string is valid
#'
#'
#' @param definition json string definition of a calculated metric
#' @param locale The location of the language. en-US is default.
#' @param migrating Include migration functions in validation. FALSE is default.
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
#' @return A string confirming the calculated metric is valid or is not valid.
#'
#' @import dplyr
#' @import assertthat
#' @import stringr
#' @importFrom glue glue
#' @importFrom jsonlite fromJSON
#' @export
#'
cm_val <- function(definition = NULL,
                        locale = 'en_US',
                        migrating = FALSE,
                        debug = FALSE,
                        rsid = Sys.getenv('AW_REPORTSUITE_ID'),
                        company_id = Sys.getenv("AW_COMPANY_ID")){

  assertthat::assert_that(assertthat::not_empty(definition), msg = "Definition must be supplied")
  #defined parts of the post request
  req_path <- glue::glue('calculatedmetrics/validate?locale={locale}&migrating={migrating}')

  body <- definition

  req <- aw_call_api(req_path = req_path,
                          body = body,
                          debug = debug,
                          content_type = 'application/json',
                          company_id = company_id)

  if(jsonlite::fromJSON(req)$valid) {
    "The calculated metric definition IS VALID"
  } else {
    glue::glue("The calculated metric definition IS NOT VALID \n {jsonlite::fromJSON(val)$message}")
  }
}
