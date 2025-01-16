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
#' @import assertthat httr
get_me <- function(req_path = 'discovery/me') {
    assertthat::assert_that(
        assertthat::is.string(req_path)
    )

    env_vars <- get_env_vars()

    token_config <- get_token_config(client_id = env_vars$client_id,
                                     client_secret = env_vars$client_secret)

    request_url <- sprintf("https://analytics.adobe.io/%s",
                           req_path)

    req <- httr::RETRY("GET",
                       url = request_url,
                       encode = "json",
                       body = FALSE,
                       token_config,
                       httr::add_headers(
                           `x-api-key` = env_vars$client_id
                       ))



    stop_for_status(req)
    res <- httr::content(req, as = "text",encoding = "UTF-8")

    me <- jsonlite::fromJSON(res)

    me$imsOrgs$companies %>%
               dplyr::bind_rows() %>%
               dplyr::select(1:2)
}
