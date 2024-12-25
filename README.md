# adobeanalyticsr
<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
<!-- badges: end -->

<img src="man/figures/logo.png" align="right" width = "200"/>

## R Client for Adobe Analytics API 2.0

Connect to the Adobe Analytics API v2.0, which powers Analysis Workspace. The package was developed with the analyst in mind and will continue to be developed with the guiding principles of iterative, repeatable, timely analysis. New features are actively being developed, and we value your feedback and contribution to the process. Please submit bugs, questions, and enhancement requests as [issues in this Github repository](https://github.com/benrwoodard/adobeanalyticsr/issues).

A special thanks to our company, [Further (formally Search Discovery)](https://www.gofurther.com/), for giving us the time, encouragement, and support to build out this package. There is no way this would have been possible without the opportunity to learn from and work with some of the most amazing people in the analytics industry.

### A Note about 2.0 vs. 1.4

The Adobe Analytics v1.4 API, while on its way out, still has some functionality that is not (yet?) available in the v2.0 API. As such, the [RSiteCatalyst](https://randyzwitch.com/rsitecatalyst/) package created by Randy Zwitch remains a useful package. While this is not a comprehensive list, some of the features that are available through RSiteCatalyst that are not available through the v2.0 API (and, by extension, are not available through this package) are:

* Data Warehouse queries
* Marketing Channel configuration and processing rules
* Some configuration details for variables (eVar, prop, events)
* Data Feed details

The v1.4 API also allows the user to pull data once they have web services access set up for their account and the client ID and client secret that comes along with that. In other words, it does _not_ require that an Adobe Console API project be created, which _is_ something that is required to use the v2.0 API. The benefit of getting an Adobe Console API project set up, though, is that the user then does _not_ need web services access set up on an account-by-account basis to pull data using the package if using the OAUTH authentication. If using the JWT authentication method with v2.0 API, then a project _does_ need to be created for each company account.

As a purely editorial side note, the creators and maintainers of this package would like to express their eternal gratitude to Randy for the work he put in to creating and maintaining `RSiteCatalyst`. His work brought the power of R combined with data pulled directly via the Adobe Analytics API to a global audience, and we can only hope (for ourselves and the analyst community writ large) that `adobeanalyticsr` can live up to the high standard he set with his work.
  
### Install the package (recommended)

```
# Install from CRAN
install.packages('adobeanalyticsr')

# Load the package
library(adobeanalyticsr) 
```

### Install the development version of the package

```
# Install devtools from CRAN
install.packages("devtools")

# Install adobeanayticsr from github
devtools::install_github('benrwoodard/adobeanalyticsr') 

# Load the package
library(adobeanalyticsr) 
```

### Current setup process overview

There are four setup steps required to start accessing your Adobe Analytics data. The following steps are each outlined in greater detail in the following sections:

  1. Create an Adobe Console API Project
  2. Create and add the OAuth or S2S arguments to your `.Renviron` file.
  3. Set the type of authorization being used by calling `aw_auth_with(type = "")`. The `type` value should be **S2S** or **oauth**
  4. Get your authorization token using `aw_auth()`. Once the authorization type has been set (the previous step), this will look for `.Renviron` variables and complete the authorization.
  5. Get your `company_id` by using the function `get_me()`.

#### 1. Create an Adobe Console API Project

If you are using the OAuth authorization, regardless of how many different Adobe 
Analytics accounts you will be accessing, you only need a single Adobe Console 
API project (you will still need to have working user credentials for each 
account you want to access, but the Adobe Console API project is just the way 
you then get access to authenticate using those user credentials; yes...confusing!) 
If you are using the S2S authorization then you will need an Adobe Console API 
project created for each organization you will be accessing.  The following 
steps will get you setup on either of the different authorizations:

  1. Navigate to the following URL: https://console.adobe.io/integrations.
  2. Click the **Create New Project** button and select **Empty Project**
  3. Click the **Add API** button.
  4. Select the Experience Cloud product icon and then choose **Adobe Analytics** and click **Next**.
  5. The next series of steps depends on your choice of authorization.
  *  *OAuth*
      1. Select the  OAuth option and then click **Next**.
      2. Select **Web** as the platform where you want the integration.
      3. Add Default redirect URI <code>https://adobeanalyticsr.com/token_result.html</code>*.
      4. Add Redirect URI pattern <code>https://adobeanalyticsr\.com/token_result\.html</code>*.
  * *S2S*
      1. Select the **Server-toServer** options and then click **Next**.
      2. Click on the **Full CJA Access** button.
      3. Click **Save configured API**.
  
\* This is simply a helper site we've set up in order to make it easier to generate a token. The site does not store any information.

**Creating an Adobe Console API Project in under 60 seconds**
<img src="man/figures/createoauthproject.gif" align="center" />

#### 2. Set up the .Renviron file

This file is essential to keeping your information secure. It also speeds up analysis by limiting the number of arguments you need to add to every function call.

  1. If you do not have an `.Renviron` file (if you have never heard of this file you almost certainly don't have one!), then create a new file and save it with the name `.Renviron`. You can do this from within the RStudio environment and save the file either in your `Home` directory (which is recommended; click on the **Home** button in the file navigator in RStudio and save it to that location) _or_ within your project's working directory.
  
  2. Get the following variables from the OAuth project and add them to the file* (see _Creating an Adobe Console API Project_ above):

      * (OAuth) `AW_CLIENT_ID` -- the client id found in the Adobe Developer Console
      * (OAuth) `AW_CLIENT_SECRET` -- the client secret key found in the Adobe Developer Console
      * (S2S) `AW_AUTH_FILE` -- The path of a JSON file containing fields with
        S2S authentication data. This file is downloaded by clicking Click on 
        "OAuth Server-to-Server" under "CREDENTIALS" in the left column. Locate 
        the "Download JSON" button on the top right and click it to download the 
        JSON file. Alternatively, you can manually create this file by copying 
        and pasting the Client ID, Client Secret (click “Retrieve client secret”), 
        Technical Account ID, and Organization ID into a `.json` file.  Reference 
        `?cja_auth` for more information on the variables needed. Using the 
        preconfigured JSON file is the easiest method.

  3. (Optional) Add `AW_COMPANY_ID` and `AW_REPORTSUITE_ID` variables once you know them (how to find available values for these two variables is described in step 4 below).
      
After adding these variables to the `.Renviron` file and saving it, restart your R session (**Session > Restart R** in RStudio) and reload `adobeanalyticsr` (`library(adobeanalyticsr)`). 

\* The format of variables in the `.Renviron` file is straightforward. If you add all four of the variables above, they would simply each be their own line in the file: 

```
## If using OAuth 
AW_CLIENT_ID = "[OAuth client ID]"
AW_CLIENT_SECRET = "[OAuth client secret]"
AW_COMPANY_ID = "[Company ID]"
AW_REPORTSUITE_ID = "[RSID]"

## If using S2S 
AW_AUTH_FILE = "[auth_file.json]"
AW_COMPANY_ID = "[Company ID]"
AW_REPORTSUITE_ID = "[RSID]"
```

An example authentication JSON file contains the following at a minimum:

```json
{
	"API_KEY":"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", #OAuth
	"Client_ID: "xxxxxxxxxxxxxx", #S2S Auth
	"CLIENT_SECRET":"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
	"SCOPES": ["xxx", "xxx"], #S2S Auth
	"ORG_ID":"xxxxxxxxxxxxxxxxxxxxxxxx@AdobeOrg",
	"TECHNICAL_ACCOUNT_ID":"xxxxxxxxxxxxxxxxxxxxxxxx@techacct.adobe.com" #OAuth
}
```

Other fields are simply ignored. **Note:** `API_KEY` means the same thing as
`CLIENT_ID`. 

#### 3. Get your authorization token

The token is actually a lonnnnng alphanumeric string that is the what ultimately enables you to access your data:

**OAuth process**
OAuth requires an interactive environment (see step 3 below), and the authentication token expires after 24 hours, which then requires repeating steps 2-9 below:

1. In the console, enter `aw_auth_with('oauth')` and press **Enter**.
2. Enter `aw_auth()` and press **Enter**.
3. A browser window should appear that prompts you to log in to your Adobe Marketing Cloud account.
4. Log in.
5. You will then be redirected to `adobeanalyticsr.com`* and a screen that displays your token.*
6. Copy the token (only).
7. Return to the R console. You should see a prompt to **Enter authorization code:**
8. Paste the token you copied and press **Enter**.
9. You should see the confirmation message: "Successfully authenticated with OAuth"

As noted above, this token will expire every 24 hours, so you will have to periodically repeat this step.

\* Again, this is simply a helper site I've set up in order to make it easier to generate a token. The site does not store any information.

**S2S process**
S2S does _not_ require an interactive environment and does not require a token refresh every 24 hours, but it does require a bit more work to set up initially (as described above). To authenticate using S2S:

1. In the console, enter `aw_auth_with('s2s')` and press _Enter_.
2. Enter `aw_auth()` and press **Enter**.
3. You should see the confirmation message: "Successfully authenticated with S2S: access token valid until..."

**JWT process** _deprecated as of January 27, 2025_
JWT does _not_ require an interactive environment and does not require a token refresh every 24 hours, but it does require a bit more work to set up initially (as described above). To authenticate using JWT:

1. In the console, enter `aw_auth_with('jwt')` and press _Enter_.
2. Enter `aw_auth()` and press **Enter**.
3. You should see the confirmation message: "Successfully authenticated with JWT: access token valid until..."

#### 4. Confirm the process worked and get available company_id and reports

The last step is to get your `company_id` (or, if you have access to multiple accounts, get the `company_id` you want to work with). This is also an excellent way to confirm that everything is set up correctly:

1. In the console, type `get_me()` and press _Enter_.
2. You should then see a list of all of the companies you have access to. The **globalCompanyId** value is what you will use to specify the company that you want to access. If you are working solely (or primarily) with one company, then consider adding the `company_id` as `AW_COMPANY_ID` in your `.Renviron` file as described in step 2 above. Otherwise, you can specify it within each function call that requires it.
3. If you will be working solely (or primarily) with a single report suite, then consider adding the report suite ID (RSID) as `AW_REPORTSUITE_ID` in your file as described in step 2 above. You can retrieve all of the report suite IDs for a given `company_id` using the function `aw_get_reportsuites(company_id = '[the company ID for account of interest]')`.

If you added any values to your `.Renviron` file (and then saved it!), then restart your R session (**Session > Restart R** in RStudio) and reload `adobeanalyticsr` (`library(adobeanalyticsr)`). 

#### 5. Pull some data!

You now should be set to start pulling data, typically starting with `aw_get_metrics()` and `aw_get_dimensions()` to get a list of available dimension and metric IDs, and then `aw_freeform_table()` to pull some data!
