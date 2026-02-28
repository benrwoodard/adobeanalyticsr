#' Gets the data from Adobe Analytics API v2
#'
#' This gives a raw call to the API, but it is intended other functions call
#' this one. Decides whether the request is a GET or a POST based on whether
#' the `body` argument is `NULL` or not.
#'
#' @noRd
#'
#' @param req_path The endpoint for that particular report
#' @param body Optional, list data structure to use as the body of the request
#' @param debug Default `FALSE`. Set this to TRUE to see the information about the api calls as they happen.
#' @param company_id Set in environment args, or pass directly here
#'
#' @examples
#'
#' \dontrun{
#'
#' aa_call_api(req_path = "reports/ranked",
#'             company_id = "mycompanyid")
#'
#' }
#'
aw_call_api <- function(req_path,
                        body = NULL,
                        content_type = NULL,
                        debug = FALSE,
                        company_id) {
    assertthat::assert_that(
        assertthat::is.string(req_path),
        assertthat::is.string(company_id)
    )

    env_vars <- get_env_vars()
    token_headers <- get_token_config(client_id = env_vars$client_id,
                                      client_secret = env_vars$client_secret)

    request_url <- sprintf("https://analytics.adobe.io/api/%s/%s",
                           company_id, req_path)

    # Build the request
    req <- httr2::request(request_url) %>%
        httr2::req_method(ifelse(is.null(body), "GET", "POST"))

    # Add headers
    headers <- c(
        token_headers,
        `x-api-key` = env_vars$client_id,
        `x-proxy-global-company-id` = company_id
    )
    if (!is.null(content_type)) {
        headers$`Content-type` <- content_type
    }
    req <- httr2::req_headers(req, !!!headers)

    # Add body if present
    if (!is.null(body)) {
        req <- httr2::req_body_json(req, body)
    }

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

    handle_api_errors(resp = resp, body = body)

    # As a fall-through, for errors that fall through handle_api_errors
    if (httr2::resp_is_error(resp)) {
        stop("HTTP ", httr2::resp_status(resp), ": ", httr2::resp_status_desc(resp))
    }

    httr2::resp_body_string(resp)
}

