#' Get Company Ids
#'
#' This function will quickly pull the list of company ids that you have access to.
#'
#' @param req_path The endpoint for that particular report
#'
#' @return A data frame of company ids and company names
#' @examples
#' \dontrun{
#' get_me()
#' }
#' @export
#' @import assertthat
get_me <- function(req_path = 'discovery/me') {
    assertthat::assert_that(
        assertthat::is.string(req_path)
    )

    env_vars <- get_env_vars()

    token_headers <- get_token_config(client_id = env_vars$client_id,
                                      client_secret = env_vars$client_secret)

    request_url <- sprintf("https://analytics.adobe.io/%s",
                           req_path)

    # Build the request
    req <- httr2::request(request_url) %>%
        httr2::req_method("GET")

    # Add headers
    headers <- c(
        token_headers,
        `x-api-key` = env_vars$client_id
    )
    req <- httr2::req_headers(req, !!!headers)

    # Add retry logic
    req <- httr2::req_retry(req, max_tries = 3)

    # Perform request (with automatic error handling)
    resp <- httr2::req_perform(req)

    res <- httr2::resp_body_string(resp)

    me <- jsonlite::fromJSON(res)

    me$imsOrgs$companies %>%
               dplyr::bind_rows() %>%
               dplyr::select(1:2)
}
