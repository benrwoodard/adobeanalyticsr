# adobeanalyticsr 0.5.0

* added OAuth Server-to-Server (S2S) authentication support
* minor changes to the documentation

# adobeanalyticsr 0.4.0

* added calculated metrics management functions
  - get_cm_functions
  - cm_function
  - cm_formula
  - cm_build
  - cm_delete
  - cm_update
  - cm_val
  - cm_copy
* added segment management functions
  - seg_copy
  - seg_delete
  - seg_update
* added project management functions
  - aw_get_project_config
  - aw_get_projects
  - proj_build
  - proj_update
* Updated supporting functions
  - aw_call_api now handles `Content-type` in the head of the api call
* Bug fix 
  - aw_get_calculatedmetrics function now recognizes filters due to an `includeType` argument bug fix
  - issue #49 regarding ownerId filter not being recognized was fixed
  - fixed issue #142 related to building sequential segments
* Enhancement
  - added 'internal' argument for calc metrics and segments that can be used to prevent
  segments and calc metrics from showing in the UI and causing confusion


# adobeanalyticsr 0.3.3

* Update to utilities make_timeframe function test

# adobeanalyticsr 0.3.2

* Refactored aw_call_data and aw_call_api into a single function
* added internal function handle_api_errors() which is a more useful error handler for 206 and 400 type errors
* Bug fix for 'get_usage_logs()` function

# adobeanalyticsr 0.3.1

* Bug fix for R <v4.0
* Initial set of unit tests

# adobeanalyticsr 0.3.0

* Changed from using a litany of environment variables to authorize with JWT to 
a simpler JSON file-based approach. Instead of listing out each variable in the 
.Renviron file a JSON file is used.
* There is now a second argument for Report Suite ID for `aw_segment_table`,
which allows the user to specify a vector of RSIDs for which to search for
the segment IDs when making pretty names.
* Added functions to build segments, validate, and create them in Adobe 
Analytics.
  * `seg_verbs`
  * `seg_rule()`
  * `seg_con()`
  * `seg_seq()`
  * `seg_then()`
  * `seg_build()`
  * `seg_val()`

# adobeanalyticsr 0.2.1

* Added support for JWT Authentication
* Changed authentication process with new functions 
  * `aw_auth()` 
  * `aw_auth_with()`
  * `aw_auth_name()`
  * `aw_auth_path()`
* Added support for `aw_token()` function with life-cycle warning
* Added new function called `aw_segment_table()` which returns one or multiple segments and their corresponding metrics
* Cleanup and edits to the `aw_freeform_table()` function
* Token support updates for all api call functions.
* Removed `client_id` and `client_secret` from functions that were not using those variables even if defined in the arguments.
* Fixed a few bugs around api calls that returned NA 
* Added argument to the `aw_freeform_table()` function that will prevent metric and dimension validation check to run at the start of every function call. This will save users a small amount of time but could be significant in the long run.
* Added progress bar to `aw_freeform_table()` and re-calibrated the estimated finish time.
* Enhanced authorization retention by saving client ID and client secret in the session environment
* Killed global counter on short requests
* Removed the search clause restriction to enable "CONTAINS" to be understood as the default for `aw_freeform_report()` search arguments.
* Added search argument to recursive call
* Updated date_range argument to handle datetimes better

# adobeanalyticsr 0.1.5

* Adjusted a few minor things in prep for CRAN submission

# adobeanalyticsr 0.1.4

* Fixed issue with non-numeric metrics returned. Specifically 'Infinite' is being returned for some calculated metrics

# adobeanalyticsr 0.1.3

* Changed function get_usage() --> get_usage_log() to better represent the endpoint
* Added Getting Started Vignette

# adobeanalyticsr 0.1.2

* New get_usage() function that returns the usage and access logs for a given date range within a 3 month period.

# adobeanalyticsr 0.1.1

* New get_users() function that retrieves a list of all users for the company designated by the auth token.
* Now includes catch for date_range end-date character value error

# adobeanalyticsr 0.1.0

* First public version
* Added a `NEWS.md` file to track changes to the package.
