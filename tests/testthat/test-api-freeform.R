# Tests for freeform table function

test_that("aw_freeform_table() returns report data", {
  skip_if_not_installed("httptest2")

  fixture_dir <- testthat::test_path("aw-freeform-table")
  if (!dir.exists(fixture_dir)) {
    skip("Fixtures not recorded. Run: source('tests/testthat/record_all_fixtures.R')")
  }

  httptest2::with_mock_dir("aw-freeform-table", {
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

    result <- aw_freeform_table(
      rsid = "mock_rsid",
      date_range = c(Sys.Date() - 7, Sys.Date() - 1),
      metrics = "visits",
      dimensions = "daterangeday",
      top = 7,
      company_id = "mockcompany123"
    )

    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
    expect_true("daterangeday" %in% names(result))
    expect_true("visits" %in% names(result))
  })
})
