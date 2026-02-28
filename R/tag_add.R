#' Add a tag to a component
#'
#' Enables the creation of a new tag and applies the new tag to the passed component
#'
#' @param company_id Company ID. If an environment variable called `AW_COMPANY_ID` exists in `.Renviron` or
#' elsewhere and no `company_id` argument is provided, then the `AW_COMPANY_ID` value will be used.
#' Use \code{\link{get_me}} to get a list of available `company_id` values.
#' @param componentId The component id being requested. Default is `NULL`
#' @param componentType The component type being requested. Options include segment, dashboard, bookmark,
#' calculatedMetric, project, dateRange, metric, dimension, virtualReportSuite, scheduledJob, alert, classification.
#' Default is NULL
#' @param tagNames Comma separated vector of tag names.
#' @param overwrite Overwrite the existing tag names on a component. To append a
#' new tag name use FALSE (default). To overwrite the existing tags on a component
#' use TRUE.
#' @param debug Include the output and input of the api call in the console for debugging. Default is FALSE
#'
#'
#' @return A data frame of segments and their meta data.
#'
#' @importFrom purrr possibly
#' @importFrom purrr map
#' @importFrom tidyr unnest
#'
#' @export
#'
tags_add <- function(company_id = Sys.getenv("AW_COMPANY_ID"),
                     componentId = NULL,
                     componentType = NULL,
                     tagNames = NULL,
                     overwrite = FALSE,
                     debug = FALSE)
{
  #get existing tags
  try_tags <- purrr::possibly(aw_get_tags, otherwise = NULL)
  tags <- try_tags(company_id = company_id,
                   componentId = componentId,
                   componentType = componentType)

if(overwrite){
  tagsr = tagNames
} else {
  #append the tagNames listed in the function call
  tagsr = unique(append(tags$name, tagNames))
}
  #create the body of the add tag update call
  body <- list(list(
    componentId = componentId,
    componentType = componentType,
    tags = purrr::map(tagsr, \(x) list(name = x))
  ))

  urlstructure <- 'componentmetadata/tags/tagitems'

  res <- aw_put_data(req_path = urlstructure,
                     body = body,
                     content_type = 'application/json',
                     debug = debug,
                     company_id = company_id)

  table <- tidyr::as_tibble(httr2::resp_body_json(res)[[1]]) %>%
    tidyr::unnest(status) %>%
    tidyr::unnest_wider(tags)

  return(table)
}




