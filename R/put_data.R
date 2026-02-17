#' Puts data into Adobe Analytics API v2 - Internal Function
#'
#' This gives a raw call to the API, but it is intended other functions call this one
#'
#' @noRd
#'
#' @param req_path The endpoint for that particular report
#' @param body An R list that will be parsed to JSON
#' @param content_type The cotent type of the PUT request body
#' @param debug Default `FALSE`. Set this to TRUE to see the information about the api calls as they happen.
#' @param company_id Set in environment args, or pass directly here
#' @param use_oob Always set to TRUE. Needed for tests
#'
#' @examples
#'
#' \dontrun{
#'
#' aw_put_data("reports/ranked",
#'             body = list(..etc..),
#'             company_id = "blah")
#'
#' }
#' @import assertthat purrr
#'
aw_put_data <- function(req_path,
                        body = NULL,
                        content_type = 'application/json',
                        debug = FALSE,
                        company_id,
                        use_oob = TRUE
){
    assert_that(
        is.string(req_path),
        is.list(body),
        is.string(company_id)
    )

    env_vars <- get_env_vars()
    token_headers <- get_token_config(client_id = env_vars$client_id,
                                      client_secret = env_vars$client_secret)

    request_url <- sprintf("https://analytics.adobe.io/api/%s/%s",
                           company_id, req_path)

    # Build the request
    req <- httr2::request(request_url) %>%
        httr2::req_method("PUT")

    # Add headers
    headers <- c(
        token_headers,
        `Content-Type` = content_type,
        `x-api-key` = env_vars$client_id,
        `x-proxy-global-company-id` = company_id
    )
    req <- httr2::req_headers(req, !!!headers)

    # Add body
    req <- httr2::req_body_json(req, body)

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

    # Check for errors
    if (httr2::resp_is_error(resp) && httr2::resp_status(resp) != 206) {
        stop("HTTP ", httr2::resp_status(resp), ": ", httr2::resp_status_desc(resp))
    }

    req_errors <- httr2::resp_body_json(resp)$columns$columnErrors[[1]]

    if(httr2::resp_status(resp) == 206  & length(req_errors) != 0) {
        stop(paste0('The error code is ', req_errors$errorCode, ' - ', req_errors$errorDescription))
    } else if(httr2::resp_status(resp) == 206) {
        stop(paste0('Please check the metrics your requested. A 206 error was returned.'))
    }
   resp
}
