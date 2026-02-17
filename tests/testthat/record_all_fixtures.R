#!/usr/bin/env Rscript
# Comprehensive Fixture Recording Script
# Records fixtures for all major API endpoints

library(adobeanalyticsr)
library(httptest2)

cat("🎬 Recording fixtures for all endpoints...\n\n")

# Check credentials
has_creds <- !identical(Sys.getenv("AW_CLIENT_ID"), "") &&
             !identical(Sys.getenv("AW_CLIENT_SECRET"), "") &&
             !identical(Sys.getenv("AW_COMPANY_ID"), "")

if (!has_creds) {
  stop("❌ Credentials not found! Set AW_CLIENT_ID, AW_CLIENT_SECRET, AW_COMPANY_ID")
}

company_id <- Sys.getenv("AW_COMPANY_ID")
cat("✅ Using Company ID:", company_id, "\n\n")

# Authenticate
cat("🔐 Authenticating...\n")
aw_auth_with('s2s')
aw_auth()
cat("✅ Authenticated\n\n")

# Change to test directory
if (!grepl("tests/testthat$", getwd())) {
  if (dir.exists("tests/testthat")) {
    setwd("tests/testthat")
  }
}

# Counter for successful recordings
success_count <- 0
total_count <- 0

record_endpoint <- function(name, code) {
  total_count <<- total_count + 1
  cat("📝", name, "...\n")
  tryCatch({
    with_mock_dir(gsub("[()]", "", gsub("_", "-", tolower(name))), code)
    cat("   ✅ Success\n")
    success_count <<- success_count + 1
  }, error = function(e) {
    cat("   ⚠️  Error:", conditionMessage(e), "\n")
  })
  cat("\n")
}

# 1. get_me() - Company information
record_endpoint("get_me", {
  result <- get_me()
  cat("   Recorded", nrow(result), "companies\n")
})

# 2. aw_get_reportsuites() - Report suites
record_endpoint("aw_get_reportsuites", {
  result <- aw_get_reportsuites(company_id = company_id, limit = 10)
  cat("   Recorded", nrow(result), "report suites\n")
})

# 3. aw_get_segments() - Segments
record_endpoint("aw_get_segments", {
  result <- aw_get_segments(company_id = company_id, limit = 10)
  cat("   Recorded", nrow(result), "segments\n")
})

# 4. aw_get_calculatedmetrics() - Calculated Metrics
record_endpoint("aw_get_calculatedmetrics", {
  result <- aw_get_calculatedmetrics(company_id = company_id, limit = 10)
  cat("   Recorded", nrow(result), "calculated metrics\n")
})

# 5. aw_get_dimensions() - Dimensions
record_endpoint("aw_get_dimensions", {
  # Get a report suite ID first
  rsids <- aw_get_reportsuites(company_id = company_id, limit = 1)
  if (nrow(rsids) > 0) {
    rsid <- rsids$rsid[1]
    result <- aw_get_dimensions(rsid = rsid, company_id = company_id)
    cat("   Recorded", nrow(result), "dimensions\n")
  } else {
    stop("No report suites available")
  }
})

# 6. aw_get_metrics() - Metrics
record_endpoint("aw_get_metrics", {
  # Get a report suite ID first
  rsids <- aw_get_reportsuites(company_id = company_id, limit = 1)
  if (nrow(rsids) > 0) {
    rsid <- rsids$rsid[1]
    result <- aw_get_metrics(rsid = rsid, company_id = company_id)
    cat("   Recorded", nrow(result), "metrics\n")
  } else {
    stop("No report suites available")
  }
})

# 7. aw_get_projects() - Workspace Projects
record_endpoint("aw_get_projects", {
  result <- aw_get_projects(company_id = company_id, limit = 10)
  cat("   Recorded", nrow(result), "projects\n")
})

# 8. aw_get_tags() - Tags
record_endpoint("aw_get_tags", {
  result <- aw_get_tags(company_id = company_id)
  if (is.data.frame(result) && nrow(result) > 0) {
    cat("   Recorded", nrow(result), "tags\n")
  } else {
    cat("   Recorded tags (empty or no tags)\n")
  }
})

# 9. aw_freeform_table() - Simple report
record_endpoint("aw_freeform_table", {
  rsids <- aw_get_reportsuites(company_id = company_id, limit = 1)
  if (nrow(rsids) > 0) {
    rsid <- rsids$rsid[1]
    result <- aw_freeform_table(
      rsid = rsid,
      date_range = c(Sys.Date() - 7, Sys.Date() - 1),
      metrics = "visits",
      dimensions = "daterangeday",
      top = 7,
      company_id = company_id
    )
    cat("   Recorded", nrow(result), "rows of data\n")
  } else {
    stop("No report suites available")
  }
})

# 10. Error scenarios - 404 Not Found
record_endpoint("error_404_segment", {
  # Try to get a non-existent segment
  tryCatch({
    aw_get_segments(
      company_id = company_id,
      segmentFilter = "id==nonexistent_segment_12345",
      limit = 1
    )
  }, error = function(e) {
    cat("   Recorded error response\n")
  })
})

# Summary
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
cat("🎉 Recording complete!\n\n")
cat("📊 Summary:", success_count, "/", total_count, "endpoints recorded\n\n")

cat("📋 Recorded fixtures:\n")
dirs <- list.dirs(".", recursive = FALSE)
dirs <- dirs[!grepl("^\\.(git|Rproj)", basename(dirs))]
for (dir in dirs) {
  files <- list.files(dir, recursive = TRUE, pattern = "\\.R$")
  if (length(files) > 0) {
    cat("  ✅", basename(dir), "-", length(files), "file(s)\n")
  }
}

cat("\n📝 Next steps:\n")
cat("1. Verify fixtures:\n")
cat("   list.files('.', recursive = TRUE, pattern = '\\\\.R$')\n\n")
cat("2. Check redaction:\n")
cat("   grep -r 'REDACTED' . | head -20\n\n")
cat("3. Run tests:\n")
cat("   devtools::test()\n\n")
cat("4. Commit:\n")
cat("   git add tests/testthat/*/\n")
cat("   git commit -m 'Add test fixtures for all endpoints'\n")
