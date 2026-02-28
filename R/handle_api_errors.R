#' Handle API response errors
#'
#' Handles 206 errors (wrong segment, dimension, or metric) and returns full
#' error messages for 400-499 errors, instead of the abbreviated version
#' returned by automatic error handling.
#'
#' @param resp Response object from `httr2`
#' @param body Request body, or `NULL` if there is no body. Used to get more
#' information about the offending components.
#'
#' @noRd
handle_api_errors <- function(resp, body) {
  status <- httr2::resp_status(resp)


  # 206 indicates wrong segment, dimension, or metric
  # Multiple errors may occur and be returned
  if (status == 206) {
    req_errors <- httr2::resp_body_json(resp)$columns$columnErrors

    msgs <- purrr::map_chr(req_errors, function(e) {
      col_info <- get_by_column_id(body, e$columnId)
      msg <- paste0(e$errorCode, ": ", e$errorDescription)

      # Metric and dimension errors are not in the message, so append them
      if (e$errorCode == "unauthorized_metric") {
        msg <- paste0(msg, ": ", col_info$metric)
      } else if (e$errorCode == "unauthorized_dimension_global") {
        msg <- paste0(msg, ": ", col_info$dimension)
      }

      msg
    })

    # Put all the error messages together
    stop(paste(unique(msgs), collapse = "\n"))
  }
  # 400 errors
  else if (status >= 400 & status <= 500 & "errorCode" %in% names(httr2::resp_body_json(resp))) {
    e_content <- httr2::resp_body_json(resp)
    msg <- glue::glue(
      "errorCode: {e_content$errorCode}\nerrorDescription: {e_content$errorDescription}"
    )

    stop(msg)
  }
}


#' Get information about a column ID
#'
#' Get global segments, metrics, and dimension for a body request column ID. Most useful
#' for handling 206 errors from the API, which return a list of offending
#' column IDs.
#'
#' @param body Body content for the API request
#' @param column_id Column ID to return information for
#'
#' @return List
#' @noRd
get_by_column_id <- function(body, column_id) {
  global_segs <- purrr::keep(body$globalFilters, ~ .x$type == "segment")
  global_segs <- unique(purrr::map_chr(global_segs, ~ .x$segmentId))

  metric <- purrr::keep(body$metricContainer$metrics, ~ .x$columnId == column_id)
  metric <- unique(purrr::map_chr(metric, ~ .x$id))

  # Each request may have only one proper dimension
  # Dimensions may act as metric filters, but in order to be a metric filter
  # a dimension must have already been the request's overall dimension, so any error
  # would've been caught
  dimension <- body$dimension

  purrr::compact(list(
    global_segs = global_segs,
    metric = metric,
    dimension = dimension
  ))
}