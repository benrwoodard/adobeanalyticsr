# Helper functions for authentication in tests

#' Check if we can run live API tests
#'
#' Tests will only run live if credentials are available
can_run_live_tests <- function() {
  # Check if we're in CI or if credentials are set
  has_credentials <- !identical(Sys.getenv("AW_CLIENT_ID"), "") &&
                     !identical(Sys.getenv("AW_CLIENT_SECRET"), "") &&
                     !identical(Sys.getenv("AW_COMPANY_ID"), "")

  return(has_credentials)
}

#' Skip test if credentials are not available
skip_if_no_auth <- function() {
  if (!can_run_live_tests()) {
    testthat::skip("API credentials not available")
  }
}

#' Create a mock token for testing without real authentication
#'
#' This creates a fake token structure that matches what the package expects
#' but doesn't actually authenticate with Adobe
mock_s2s_token <- function() {
  # Create a mock S2S token structure
  list(
    access = "MOCK_ACCESS_TOKEN_FOR_TESTING",
    token_type = "bearer",
    expires_in = 86400,
    expires_at = as.numeric(Sys.time()) + 86400
  )
}

#' Create a mock environment with fake credentials
#'
#' Use this in tests with withr::local_envvar()
mock_credentials <- function() {
  list(
    AW_CLIENT_ID = "mock_client_id_12345",
    AW_CLIENT_SECRET = "mock_client_secret_67890",
    AW_COMPANY_ID = "mockcompany123",
    AW_AUTH_FILE = ""  # Prevent loading real auth file
  )
}
