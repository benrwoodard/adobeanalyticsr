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

# Check credentials and detect auth method
check_credentials <- function() {
  has_oauth <- !identical(Sys.getenv("AW_CLIENT_ID"), "") &&
               !identical(Sys.getenv("AW_CLIENT_SECRET"), "")

  has_s2s <- !identical(Sys.getenv("AW_AUTH_FILE"), "") &&
             file.exists(Sys.getenv("AW_AUTH_FILE"))

  has_company <- !identical(Sys.getenv("AW_COMPANY_ID"), "")

  if (!has_company) {
    stop(
      "❌ AW_COMPANY_ID not set!\n\n",
      "Please set AW_COMPANY_ID in .Renviron"
    )
  }

  if (!has_oauth && !has_s2s) {
    stop(
      "❌ No credentials found!\n\n",
      "For OAuth, set:\n",
      "  - AW_CLIENT_ID\n",
      "  - AW_CLIENT_SECRET\n",
      "  - AW_COMPANY_ID\n\n",
      "For S2S, set:\n",
      "  - AW_AUTH_FILE (path to JSON file)\n",
      "  - AW_COMPANY_ID\n\n",
      "See RECORDING_GUIDE.md for details."
    )
  }

  if (has_oauth) {
    cat("✅ OAuth credentials found\n")
    cat("   Client ID:", substr(Sys.getenv("AW_CLIENT_ID"), 1, 20), "...\n")
    return("oauth")
  } else if (has_s2s) {
    cat("✅ S2S credentials found\n")
    cat("   Auth File:", Sys.getenv("AW_AUTH_FILE"), "\n")
    return("s2s")
  }
}

auth_method <- check_credentials()
cat("   Company ID:", Sys.getenv("AW_COMPANY_ID"), "\n")
cat("   Auth Method:", toupper(auth_method), "\n\n")

# Authenticate
cat("🔐 Authenticating with Adobe Analytics...\n")
aw_auth_with(auth_method)

if (auth_method == "oauth") {
  cat("📱 OAuth Flow: A browser window will open for authentication...\n")
  cat("   Please sign in and authorize the application.\n")
}

aw_auth()
cat("✅ Authentication successful\n\n")

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
