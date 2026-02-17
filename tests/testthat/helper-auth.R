# Helper functions for authentication in tests

#' Check if we can run live API tests
#'
#' Tests will only run live if credentials are available
can_run_live_tests <- function() {
  # Check for OAuth credentials
  has_oauth <- !identical(Sys.getenv("AW_CLIENT_ID"), "") &&
               !identical(Sys.getenv("AW_CLIENT_SECRET"), "")

  # Check for S2S credentials
  has_s2s <- !identical(Sys.getenv("AW_AUTH_FILE"), "") &&
             file.exists(Sys.getenv("AW_AUTH_FILE"))

  # Check for company ID
  has_company <- !identical(Sys.getenv("AW_COMPANY_ID"), "")

  return((has_oauth || has_s2s) && has_company)
}

#' Detect which auth method to use
#'
#' Returns 'oauth' or 's2s' based on available credentials
detect_auth_method <- function() {
  has_oauth <- !identical(Sys.getenv("AW_CLIENT_ID"), "") &&
               !identical(Sys.getenv("AW_CLIENT_SECRET"), "")

  has_s2s <- !identical(Sys.getenv("AW_AUTH_FILE"), "") &&
             file.exists(Sys.getenv("AW_AUTH_FILE"))

  if (has_oauth && !has_s2s) {
    return("oauth")
  } else if (has_s2s && !has_oauth) {
    return("s2s")
  } else if (has_oauth && has_s2s) {
    # Prefer OAuth if both available
    message("Both OAuth and S2S credentials found, using OAuth")
    return("oauth")
  } else {
    stop("No valid credentials found. Set either OAuth (AW_CLIENT_ID, AW_CLIENT_SECRET) or S2S (AW_AUTH_FILE)")
  }
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

#' Create a mock OAuth token for testing
#'
#' This creates a fake OAuth Token2.0 object
mock_oauth_token <- function() {
  structure(
    list(
      credentials = list(
        access_token = "MOCK_OAUTH_ACCESS_TOKEN",
        token_type = "bearer",
        expires_in = 86400
      )
    ),
    class = "Token2.0"
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
