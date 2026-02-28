# Setup for httptest2 testing
# This file is run before all tests

if (requireNamespace("httptest2", quietly = TRUE)) {
  library(httptest2)

  # Set options for httptest2
  # Redact sensitive information from recorded fixtures
  set_redactor(function(response) {
    # Redact Authorization headers
    response <- gsub_response(response, "Bearer [A-Za-z0-9._-]+", "REDACTED_TOKEN")
    # Redact x-api-key headers
    response <- gsub_response(response, '"x-api-key":"[^"]+"', '"x-api-key":"REDACTED_API_KEY"')
    # Redact client_id in URLs or bodies
    response <- gsub_response(response, '"client_id":"[^"]+"', '"client_id":"REDACTED_CLIENT_ID"')
    # Redact client_secret
    response <- gsub_response(response, '"client_secret":"[^"]+"', '"client_secret":"REDACTED_CLIENT_SECRET"')
    # Redact access tokens in response bodies
    response <- gsub_response(response, '"access_token":"[^"]+"', '"access_token":"REDACTED_ACCESS_TOKEN"')
    return(response)
  })

  # Set the directory for mock files
  # By default, httptest2 looks in tests/testthat/{test-name}/{request-pattern}
  # This can be customized if needed

  message("httptest2 is configured for testing")
} else {
  message("httptest2 not available - API tests will be skipped")
}
