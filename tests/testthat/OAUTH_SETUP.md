# OAuth Setup Guide for Testing

## Quick Start - OAuth Credentials

OAuth authentication requires interactive browser login and is the easiest way to record test fixtures during development.

### Step 1: Set Up .Renviron

```r
# Open .Renviron
usethis::edit_r_environ()

# Add these three lines (replace with your actual values):
AW_CLIENT_ID=your_client_id_from_adobe_console
AW_CLIENT_SECRET=your_client_secret_from_adobe_console
AW_COMPANY_ID=your_adobe_company_id

# Save the file and restart R
.rs.restartR()
```

### Step 2: Test Authentication

```r
library(adobeanalyticsr)

# Set auth method
aw_auth_with('oauth')

# Authenticate (browser will open)
aw_auth()

# Test with a simple API call
companies <- get_me()
print(companies)
```

### Step 3: Record Fixtures

Once authenticated, recording fixtures is automatic:

```r
# Navigate to test directory
setwd("tests/testthat")

# Run recording script
source("record_all_fixtures.R")

# Or record individually
source("record_fixtures.R")
```

## How OAuth Works

1. **First Time:**
   - Browser opens automatically
   - Sign in with your Adobe ID
   - Authorize the application
   - Token is cached locally in `aa.oauth` file

2. **Subsequent Times:**
   - Uses cached token (no browser needed)
   - Token auto-refreshes when expired
   - Re-authenticate only if token is invalid

## Getting Your Credentials

### From Adobe Developer Console

1. Go to https://developer.adobe.com/console/
2. Select your project (or create one)
3. Add "Adobe Analytics API"
4. Choose "OAuth Server-to-Server" OR "OAuth Web"
5. Copy your:
   - **Client ID** → `AW_CLIENT_ID`
   - **Client Secret** → `AW_CLIENT_SECRET`
   - **Company ID** → Get from `get_me()` or Analytics UI

### Finding Your Company ID

If you don't know your company ID:

```r
# Option 1: Use the Adobe Analytics UI
# Login → Admin → Company Settings → Company ID

# Option 2: Authenticate first without company_id, then:
library(adobeanalyticsr)
aw_auth_with('oauth')
aw_auth()
companies <- get_me()
print(companies)
# Copy the globalCompanyKey you want to use
```

## .Renviron Example

Your `.Renviron` should look like this:

```bash
# Adobe Analytics OAuth Credentials
AW_CLIENT_ID=abcd1234567890abcdef1234567890ab
AW_CLIENT_SECRET=p-aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890AB
AW_COMPANY_ID=mycompany123

# Optional: Set default auth method
# (This prevents needing to call aw_auth_with('oauth') every time)
# AW_AUTH_TYPE=oauth
```

## Troubleshooting OAuth

### "Could not open browser"

**Solution:** Set `use_oob = TRUE` for manual code entry:

```r
aw_auth_with('oauth')
auth_oauth(use_oob = TRUE)

# Copy the URL shown, paste in browser
# Copy the authorization code back to R console
```

### "OAuth token not found"

**Solution:** Delete cached token and re-authenticate:

```r
# Delete cached token
file.remove("aa.oauth")

# Re-authenticate
aw_auth_with('oauth')
aw_auth()
```

### "Invalid client credentials"

**Solution:** Verify your credentials are correct:

```r
# Check what R sees
Sys.getenv("AW_CLIENT_ID")
Sys.getenv("AW_CLIENT_SECRET")

# Make sure they match your Adobe Console credentials
# No extra spaces, quotes, or special characters
```

### Browser opens but authentication fails

**Solution:** Check redirect URI in Adobe Console:

1. Go to Adobe Developer Console
2. Your Project → Credentials → OAuth
3. Redirect URIs should include:
   - `http://localhost:1410/`
   - `https://adobeanalyticsr.com/token_result.html`

## Recording with OAuth

The recording scripts automatically detect OAuth credentials:

```r
# Single endpoint
source("tests/testthat/record_fixtures.R")
# Output: ✅ Using OAuth authentication
#         📱 OAuth Flow: A browser window will open...

# All endpoints
source("tests/testthat/record_all_fixtures.R")
# Output: ✅ Using OAuth authentication
#         📱 OAuth Flow: A browser window will open...
```

## OAuth vs S2S

| Feature | OAuth | S2S |
|---------|-------|-----|
| **Browser Required** | Yes (first time) | No |
| **Best For** | Development, Testing | Production, CI/CD |
| **Setup** | Client ID + Secret | JSON file |
| **Token Storage** | Local file (aa.oauth) | Generated on-demand |
| **Expires** | Yes (auto-refreshes) | Yes (generates new) |

## After Recording

Once you've recorded fixtures with OAuth:

1. **Commit the fixtures** (not the OAuth token):
   ```bash
   # Commit fixtures
   git add tests/testthat/*/

   # DO NOT commit your token
   echo "aa.oauth" >> .gitignore

   git commit -m "Add test fixtures"
   ```

2. **Tests work for everyone:**
   - Fixtures replay without authentication
   - No OAuth needed for running tests
   - Works in CI/CD automatically

## Security Notes

✅ **Safe to commit:**
- Fixture files (credentials are redacted)
- Test files
- Recording scripts

❌ **Never commit:**
- `aa.oauth` (OAuth token file)
- `.Renviron` (contains credentials)
- Any file with real credentials

The httptest2 redaction automatically removes tokens from fixtures!

## Questions?

- Package docs: `?aw_auth`
- OAuth docs: `?auth_oauth`
- Test docs: `tests/README.md`
