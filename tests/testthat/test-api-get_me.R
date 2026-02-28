# Tests for get_me() function using httptest2

test_that("get_me() returns company information with mocked API", {
  skip_if_not_installed("httptest2")

  # Skip if fixtures haven't been recorded yet
  fixture_dir <- testthat::test_path("get_me")
  if (!dir.exists(fixture_dir)) {
    skip(paste(
      "Fixtures not recorded yet.",
      "Run tests/testthat/record_fixtures.R with credentials to record.",
      "See tests/testthat/RECORDING_GUIDE.md for details."
    ))
  }

  # Use httptest2 to mock the API response
  httptest2::with_mock_dir("get_me", {
    # Set mock credentials
    withr::local_envvar(mock_credentials())

    # Mock the token retrieval to avoid real authentication
    local_mocked_bindings(
      retrieve_aw_token = function(...) {
        # Return a mock S2S token structure
        structure(
          list(token = mock_s2s_token()),
          class = "AdobeS2SToken"
        )
      },
      get_token_config = function(...) {
        # Return mock authorization header
        list(Authorization = "Bearer MOCK_TOKEN")
      },
      .package = "adobeanalyticsr"
    )

    # This will look for a recorded response in tests/testthat/get_me/
    # On first run with real credentials, use httptest2::capture_requests() to record
    result <- get_me()

    # Verify the result structure
    expect_s3_class(result, "data.frame")
    expect_true("globalCompanyKey" %in% names(result) ||
                length(names(result)) >= 2)
  })
})

test_that("get_me() handles API errors gracefully", {
  skip_if_not_installed("httptest2")

  # Skip if error fixtures haven't been recorded yet
  fixture_dir <- testthat::test_path("get_me_error")
  if (!dir.exists(fixture_dir)) {
    skip("Error fixtures not recorded yet. This test is optional.")
  }

  httptest2::with_mock_dir("get_me_error", {
    withr::local_envvar(mock_credentials())

    local_mocked_bindings(
      retrieve_aw_token = function(...) {
        structure(
          list(token = mock_s2s_token()),
          class = "AdobeS2SToken"
        )
      },
      get_token_config = function(...) {
        list(Authorization = "Bearer MOCK_TOKEN")
      },
      .package = "adobeanalyticsr"
    )

    # This test expects an error response fixture
    # You would record this by making a request that returns an error
    expect_error(
      get_me(),
      class = "httr2_http_4"  # httr2 error class
    )
  })
})

# Example: How to record fixtures for the first time
# To record real API responses (do this once with real credentials):
#
# test_that("RECORD fixtures for get_me", {
#   skip_if_no_auth()  # Only run if you have real credentials
#   skip_on_cran()
#   skip_on_ci()
#
#   httptest2::capture_requests({
#     # Make real API call - this will be recorded
#     result <- get_me()
#     expect_s3_class(result, "data.frame")
#   })
# })
