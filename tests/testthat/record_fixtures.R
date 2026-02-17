#!/usr/bin/env Rscript
# Recording Script for Test Fixtures
# Run this once with real Adobe Analytics credentials to record API responses

# Check for required packages
if (!requireNamespace("httptest2", quietly = TRUE)) {
  stop("httptest2 package is required. Install with: install.packages('httptest2')")
}

if (!requireNamespace("adobeanalyticsr", quietly = TRUE)) {
  stop("adobeanalyticsr package is required. Install with: devtools::install()")
}

library(adobeanalyticsr)
library(httptest2)

cat("🎬 Starting fixture recording...\n\n")

# Check credentials
check_credentials <- function() {
  has_creds <- !identical(Sys.getenv("AW_CLIENT_ID"), "") &&
               !identical(Sys.getenv("AW_CLIENT_SECRET"), "") &&
               !identical(Sys.getenv("AW_COMPANY_ID"), "")

  if (!has_creds) {
    stop(
      "❌ Credentials not found!\n\n",
      "Please set these environment variables:\n",
      "  - AW_CLIENT_ID\n",
      "  - AW_CLIENT_SECRET\n",
      "  - AW_COMPANY_ID\n",
      "  - AW_AUTH_FILE (if using S2S)\n\n",
      "See RECORDING_GUIDE.md for details."
    )
  }

  cat("✅ Credentials found\n")
  cat("   Client ID:", substr(Sys.getenv("AW_CLIENT_ID"), 1, 20), "...\n")
  cat("   Company ID:", Sys.getenv("AW_COMPANY_ID"), "\n\n")
}

check_credentials()

# Authenticate
cat("🔐 Authenticating with Adobe Analytics...\n")
tryCatch({
  aw_auth_with('s2s')
  aw_auth()
  cat("✅ Authentication successful\n\n")
}, error = function(e) {
  # Try OAuth if S2S fails
  cat("⚠️  S2S auth failed, trying OAuth...\n")
  aw_auth_with('oauth')
  aw_auth()
  cat("✅ OAuth authentication successful\n\n")
})

# Set working directory to tests/testthat if not already there
if (!grepl("tests/testthat$", getwd())) {
  if (dir.exists("tests/testthat")) {
    setwd("tests/testthat")
  } else {
    stop("Cannot find tests/testthat directory. Run from package root.")
  }
}

cat("📂 Recording fixtures to:", getwd(), "\n\n")

# Record get_me() fixtures
cat("📝 Recording fixtures for get_me()...\n")
tryCatch({
  with_mock_dir("get_me", {
    result <- get_me()
    cat("   ✅ Recorded", nrow(result), "companies\n")
    print(head(result, 3))
  })
}, error = function(e) {
  cat("   ❌ Error:", conditionMessage(e), "\n")
})

cat("\n")

# You can add more endpoints here:

# cat("📝 Recording fixtures for aw_get_segments()...\n")
# tryCatch({
#   with_mock_dir("get_segments", {
#     segments <- aw_get_segments(
#       company_id = Sys.getenv("AW_COMPANY_ID"),
#       limit = 10
#     )
#     cat("   ✅ Recorded", nrow(segments), "segments\n")
#   })
# }, error = function(e) {
#   cat("   ❌ Error:", conditionMessage(e), "\n")
# })
#
# cat("\n")

# Summary
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("🎉 Recording complete!\n\n")

cat("📋 Next steps:\n")
cat("1. Verify fixtures were created:\n")
cat("   list.files('.', recursive = TRUE, pattern = '\\\\.R$')\n\n")

cat("2. Check for sensitive data:\n")
cat("   grep -r 'REDACTED' .\n\n")

cat("3. Run tests:\n")
cat("   devtools::test()\n\n")

cat("4. Commit fixtures:\n")
cat("   git add tests/testthat/*/\n")
cat("   git commit -m 'Add test fixtures'\n\n")

cat("See RECORDING_GUIDE.md for more details.\n")
