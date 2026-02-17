#' Delete A Calculated Metric Function
#'
#' Use this function to delete a specific calculated metric.
#'
#' @param id Calculated Metric ID to be deleted.
#' @param warn Boolean of whether or not to include a warning message.
#' @param locale language - default 'en_US'
#' @param debug Default `FALSE`. Set this to TRUE to see the information about the api calls as they happen.
#' @param rsid Adobe report suite ID (RSID).  If an environment variable called
#' `AW_REPORTSUITE_ID` exists in `.Renviron` or elsewhere and no `rsid` argument
#' is provided, then the `AW_REPORTSUITE_ID` value will be used. Use [aw_get_reportsuites()]
#' to get a list of available `rsid` values.
#' @param company_id Company ID. If an environment variable called `AW_COMPANY_ID`
#' exists in `.Renviron` or elsewhere and no `company_id` argument is provided,
#' then the `AW_COMPANY_ID` value will be used. Use [get_me()] to get a list of
#' available `company_id` values.
#'
#' @return A string confirming the calculated metric is deleted
#'
#' @importFrom glue glue
#' @importFrom purrr map
#' @importFrom purrr map2
#' @importFrom utils menu
#' @export
#'
cm_delete <- function(id = NULL,
                      warn = TRUE,
                      locale = 'en_US',
                      debug = FALSE,
                      rsid = Sys.getenv("AW_REPORTSUITE_ID"),
                      company_id = Sys.getenv("AW_COMPANY_ID")){

  #assert that the 2 key arguments have values
  assertthat::assert_that(assertthat::not_empty(id), msg = 'Argument "id" cannot be empty')
  if(warn){
    if (utils::menu(c("Yes", "No"),
             title= "Are you sure you want to delete this Calculated Metric") == "1") {

      env_vars <- get_env_vars()
      token_headers <- get_token_config(client_id = env_vars$client_id,
                                        client_secret = env_vars$client_secret)

      req_path <- glue::glue('calculatedmetrics/{id}?locale={locale}')

      request_url <- sprintf("https://analytics.adobe.io/api/%s/%s",
                             company_id, req_path)

      # Build the request
      req <- httr2::request(request_url) %>%
          httr2::req_method("DELETE")

      # Add headers
      headers <- c(
          token_headers,
          `x-api-key` = env_vars$client_id,
          `x-proxy-global-company-id` = company_id
      )
      req <- httr2::req_headers(req, !!!headers)

      # Add retry logic
      req <- httr2::req_retry(req, max_tries = 3)

      # Add debug/verbose if requested
      if (debug) {
          req <- httr2::req_verbose(req)
      }

      # Disable automatic error handling to use custom error handling
      req <- httr2::req_error(req, is_error = function(resp) FALSE)

      # Perform request
      resp <- httr2::req_perform(req)

      handle_api_errors(resp = resp, body = NULL)
      # As a fall-through, for errors that fall through handle_api_errors
      if (httr2::resp_is_error(resp)) {
          stop("HTTP ", httr2::resp_status(resp), ": ", httr2::resp_status_desc(resp))
      }
      message(glue::glue('{httr2::resp_body_json(resp)$result}: {id} has been deleted'))
    } else { message("Ok, it will not be deleted.")}
  } else {
    env_vars <- get_env_vars()
    token_headers <- get_token_config(client_id = env_vars$client_id,
                                      client_secret = env_vars$client_secret)

    req_path <- glue::glue('calculatedmetrics/{id}?locale={locale}')

    request_url <- sprintf("https://analytics.adobe.io/api/%s/%s",
                           company_id, req_path)

    # Build the request
    req <- httr2::request(request_url) %>%
        httr2::req_method("DELETE")

    # Add headers
    headers <- c(
        token_headers,
        `x-api-key` = env_vars$client_id,
        `x-proxy-global-company-id` = company_id
    )
    req <- httr2::req_headers(req, !!!headers)

    # Add retry logic
    req <- httr2::req_retry(req, max_tries = 3)

    # Add debug/verbose if requested
    if (debug) {
        req <- httr2::req_verbose(req)
    }

    # Disable automatic error handling to use custom error handling
    req <- httr2::req_error(req, is_error = function(resp) FALSE)

    # Perform request
    resp <- httr2::req_perform(req)

    handle_api_errors(resp = resp, body = NULL)
    # As a fall-through, for errors that fall through handle_api_errors
    if (httr2::resp_is_error(resp)) {
        stop("HTTP ", httr2::resp_status(resp), ": ", httr2::resp_status_desc(resp))
    }
    message(glue::glue('{httr2::resp_body_json(resp)$result}: {id} has been deleted'))
  }

}
