# Recording Test Fixtures - Step-by-Step Guide

## Prerequisites

You need **real Adobe Analytics credentials** to record fixtures. The package supports both OAuth and S2S authentication.

### Option A: OAuth Authentication (Interactive - Recommended for Development)

OAuth requires interactive browser login and is best for local development.

```r
# Edit .Renviron file
usethis::edit_r_environ()

# Add these lines:
AW_CLIENT_ID=your_client_id_here
AW_CLIENT_SECRET=your_client_secret_here
AW_COMPANY_ID=your_company_id_here

# Save and restart R
.rs.restartR()
```

**Note:** OAuth will open a browser for you to sign in. After authorization, a token is cached locally.

### Option B: S2S (Server-to-Server) Authentication (Non-Interactive)

S2S uses a JSON credential file and doesn't require browser interaction.

```r
# Edit .Renviron file
usethis::edit_r_environ()

# Add these lines:
AW_AUTH_FILE=/full/path/to/your/credentials.json
AW_COMPANY_ID=your_company_id_here

# Save and restart R
.rs.restartR()
```

**Note:** S2S JSON file should contain `CLIENT_ID`, `CLIENT_SECRETS`, and `SCOPES`.

### Checking Your Setup

```r
# Verify credentials are set
Sys.getenv("AW_CLIENT_ID")        # For OAuth
Sys.getenv("AW_CLIENT_SECRET")    # For OAuth
Sys.getenv("AW_AUTH_FILE")        # For S2S
Sys.getenv("AW_COMPANY_ID")       # Required for both

# Test authentication
library(adobeanalyticsr)

# For OAuth:
aw_auth_with('oauth')
aw_auth()  # Browser will open

# For S2S:
aw_auth_with('s2s')
aw_auth()  # No browser needed
```

## Recording Fixtures

### Step 1: Load the package and httptest2

```r
library(adobeanalyticsr)
library(httptest2)
library(testthat)
```

### Step 2: Set recording directory

```r
# Set the test directory
setwd("tests/testthat")

# Or from package root:
# setwd(".")  # then httptest2 will find tests/testthat automatically
```

### Step 3: Record fixtures for get_me()

```r
# Start recording - this will create fixtures in tests/testthat/get_me/
with_mock_dir("get_me", {
  # Authenticate with real credentials
  aw_auth_with('s2s')
  aw_auth()

  # Make the API call - response will be recorded
  result <- get_me()

  # Verify it worked
  print(result)
})
```

### Step 4: Verify fixtures were created

```r
# Check that fixtures exist
list.files("tests/testthat/get_me", recursive = TRUE)
```

You should see files like:
```
tests/testthat/get_me/
  └── analytics.adobe.io/
      └── discovery/
          └── me.R
```

### Step 5: Check fixture for sensitive data

```r
# Read the fixture file
fixture_content <- readLines("tests/testthat/get_me/analytics.adobe.io/discovery/me.R")

# Look for REDACTED values
grep("REDACTED", fixture_content, value = TRUE)

# Should see:
# - "REDACTED_TOKEN" instead of real tokens
# - "REDACTED_API_KEY" instead of real API keys
```

## Recording All Test Fixtures

Here's a script to record all fixtures at once:

```r
library(adobeanalyticsr)
library(httptest2)

# Authenticate once
aw_auth_with('s2s')
aw_auth()

# Record get_me fixtures
with_mock_dir("get_me", {
  result <- get_me()
  print(paste("Recorded get_me:", nrow(result), "companies"))
})

# Add more endpoints as needed:
# with_mock_dir("get_segments", {
#   segments <- aw_get_segments(limit = 10)
#   print(paste("Recorded segments:", nrow(segments)))
# })

# with_mock_dir("get_calculatedmetrics", {
#   metrics <- aw_get_calculatedmetrics(limit = 10)
#   print(paste("Recorded metrics:", nrow(metrics)))
# })

print("✅ All fixtures recorded!")
```

## Troubleshooting

### Problem: "Cannot find mock file"

**Solution:** You haven't recorded fixtures yet. Run the recording script above.

### Problem: Fixtures contain real credentials

**Solution:** Check `setup-httptest2.R` redaction rules:

```r
# Add custom redaction if needed
set_redactor(function(response) {
  response <- gsub_response(response, "Bearer [A-Za-z0-9._-]+", "REDACTED_TOKEN")
  response <- gsub_response(response, '"your-company-id"', '"REDACTED_COMPANY"')
  # Add more patterns as needed
  return(response)
})
```

Then delete old fixtures and re-record:
```r
unlink("tests/testthat/get_me", recursive = TRUE)
# Re-record using the script above
```

### Problem: Tests still fail after recording

**Solution:** Check that tests are using the correct mock directory name:

```r
# In test file, make sure directory name matches
httptest2::with_mock_dir("get_me", {  # Must match recorded directory
  result <- get_me()
})
```

### Problem: Authentication fails during recording

**Solution:** Test authentication separately first:

```r
# Test S2S auth
aw_auth_with('s2s')
token <- aw_auth()

# Verify credentials
env_vars <- get_env_vars()
print(env_vars$client_id)  # Should not be empty

# Try manual API call
result <- get_me()
print(result)
```

## After Recording

### 1. Verify fixtures are complete
```bash
ls -R tests/testthat/get_me/
```

### 2. Run tests to confirm they work
```r
devtools::test()
# or
testthat::test_file("tests/testthat/test-api-get_me.R")
```

### 3. Commit fixtures to git
```bash
git add tests/testthat/get_me/
git commit -m "Add test fixtures for get_me()"
```

## Next Steps

Once fixtures are recorded:
1. ✅ Tests run without credentials
2. ✅ Tests work in CI/CD
3. ✅ Other developers can run tests
4. ✅ Fast, offline, deterministic tests

Happy testing! 🎉
