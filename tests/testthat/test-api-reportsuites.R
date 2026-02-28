# Tests for report suite functions

test_that("aw_get_reportsuites() returns report suite data", {
  skip_if_not_installed("httptest2")

  fixture_dir <- testthat::test_path("aw-get-reportsuites")
  if (!dir.exists(fixture_dir)) {
    skip("Fixtures not recorded. Run: source('tests/testthat/record_all_fixtures.R')")
  }

  httptest2::with_mock_dir("aw-get-reportsuites", {
    withr::local_envvar(mock_credentials())

    local_mocked_bindings(
      retrieve_aw_token = function(...) {
        structure(list(token = mock_s2s_token()), class = "AdobeS2SToken")
      },
      get_token_config = function(...) {
        list(Authorization = "Bearer MOCK_TOKEN")
      },
      .package = "adobeanalyticsr"
    )

    result <- aw_get_reportsuites(
      company_id = "mockcompany123",
      limit = 10
    )

    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
    expect_true("rsid" %in% names(result))
    expect_true("name" %in% names(result))
  })
})
