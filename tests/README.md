# Testing Guide for adobeanalyticsr

This package uses [httptest2](https://enpiar.com/httptest2/) to test API calls without requiring live authentication.

## Overview

**httptest2** allows us to:
- ✅ Record real API responses once, then replay them in tests
- ✅ Run tests offline without network connection
- ✅ Automatically redact sensitive credentials
- ✅ Fast, deterministic tests with no API rate limits

## Test Structure

```
tests/
├── testthat/
│   ├── setup-httptest2.R         # httptest2 configuration
│   ├── helper-auth.R              # Authentication helpers
│   ├── test-*.R                   # Test files
│   └── [test-name]/               # Mock fixtures directory
│       └── [request-pattern].R    # Recorded API responses
└── README.md                      # This file
```

## Running Tests

### Run All Tests (Uses Mock Fixtures)
```r
devtools::test()
# Or
testthat::test_local()
```

Tests will use recorded fixtures and **do not require authentication**.

### Run Tests on CI/CD
Tests work automatically in GitHub Actions, Travis CI, etc. No credentials needed!

## Recording New Fixtures

When adding tests for new API endpoints, you need to record fixtures once with real credentials:

### Step 1: Set Up Credentials
```r
# In .Renviron or environment
Sys.setenv(
  AW_CLIENT_ID = "your_client_id",
  AW_CLIENT_SECRET = "your_client_secret",
  AW_COMPANY_ID = "your_company_id"
)
```

### Step 2: Record Fixtures
```r
library(httptest2)

# Record a single test
httptest2::capture_requests({
  # Authenticate
  aw_auth_with('s2s')
  aw_auth()

  # Make API call - response will be recorded
  result <- get_me()
})
```

Fixtures are saved to `tests/testthat/{test-name}/{request-pattern}.R`

### Step 3: Verify Redaction
Check the recorded fixture files to ensure sensitive data is redacted:
- ✅ Authorization tokens → `REDACTED_TOKEN`
- ✅ API keys → `REDACTED_API_KEY`
- ✅ Client secrets → `REDACTED_CLIENT_SECRET`

Redaction rules are in `setup-httptest2.R`.

### Step 4: Commit Fixtures
```bash
git add tests/testthat/{test-name}/
git commit -m "Add test fixtures for {test-name}"
```

## Writing Tests

### Example: Testing an API Function

```r
test_that("function_name() works correctly", {
  skip_if_not_installed("httptest2")

  httptest2::with_mock_dir("function_name", {
    # Set mock credentials
    withr::local_envvar(mock_credentials())

    # Mock authentication
    local_mocked_bindings(
      retrieve_aw_token = function(...) {
        structure(
          list(token = mock_s2s_token()),
          class = "AdobeS2SToken"
        )
      },
      .package = "adobeanalyticsr"
    )

    # Call function - will use recorded fixture
    result <- function_name()

    # Assertions
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
  })
})
```

### Example: Testing Error Handling

```r
test_that("function handles 404 errors", {
  skip_if_not_installed("httptest2")

  httptest2::with_mock_dir("function_error_404", {
    withr::local_envvar(mock_credentials())

    # Record a fixture that returns 404
    expect_error(
      function_name(id = "nonexistent"),
      class = "httr2_http_404"
    )
  })
})
```

## Helper Functions

### `skip_if_no_auth()`
Skip test if real credentials are not available:
```r
test_that("RECORD: get_me fixtures", {
  skip_if_no_auth()
  # This only runs when you have credentials
})
```

### `mock_credentials()`
Returns fake credentials for testing:
```r
withr::local_envvar(mock_credentials())
```

### `mock_s2s_token()`
Returns a fake S2S token structure:
```r
token <- mock_s2s_token()
```

## Best Practices

1. **Separate recording from testing**: Use `skip_if_no_auth()` for recording tests
2. **One fixture per test**: Keep test fixtures isolated
3. **Verify redaction**: Always check fixtures before committing
4. **Test error cases**: Record fixtures for error responses too
5. **Mock authentication**: Don't require real auth in regular tests

## CI/CD Setup

### GitHub Actions Example
```yaml
name: R-CMD-check

on: [push, pull_request]

jobs:
  R-CMD-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: r-lib/actions/setup-r@v2
      - name: Install dependencies
        run: |
          install.packages('devtools')
          devtools::install_deps(dependencies = TRUE)
      - name: Run tests
        run: devtools::test()
```

**No credentials needed!** Tests use recorded fixtures automatically.

## Troubleshooting

### "Cannot find mock file" error
- You need to record fixtures first
- Run tests with `httptest2::capture_requests()` and real credentials
- Verify fixtures exist in `tests/testthat/{test-name}/`

### Fixtures contain sensitive data
- Check `setup-httptest2.R` redaction rules
- Add custom redaction for your specific use case
- Delete and re-record fixtures after updating redaction

### Tests work locally but fail on CI
- Ensure fixtures are committed to git
- Verify httptest2 is in DESCRIPTION Suggests
- Check that tests don't accidentally require real auth

## Resources

- [httptest2 Documentation](https://enpiar.com/httptest2/)
- [HTTP Testing in R Book](https://books.ropensci.org/http-testing/)
- [testthat Documentation](https://testthat.r-lib.org/)

## Questions?

See `?httptest2::with_mock_dir` or `?httptest2::capture_requests` for more details.
