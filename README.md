# adobeanalyticsr

This is intended as a POC on how a AAv2 package could work, including OAuth2.

## Current Setup Requirements

It requires setting the following environment arguments:

* `AA_COMPANY_ID`
* `AA_CLIENT_ID`
* `AA_CLIENT_SECRET`
* `AA_REPORTSUITE_ID`

## Getting Auth to Work

There are three ways to add the four variables to to your environment.  
<<<<<<< HEAD
1. The first way is the easist.  Make sure to have each one of them readily available and then call the "aa_creds()" function. It will ask you for each one and save it to the system environment.
=======
1. The first way is the easist.  Make sure to have each one of them readily available and then call the `aa_creds()` function. It will ask you for each one and save it to the system environment.
>>>>>>> 5a988e05b1bf37ba16c57dcb585122146d4d30a6
2. The second way is more manual but you essentially do the same thing the function does but simply add it yoruself. Make sure to use the exact environment argument name that is listed above and save it to the system environment using "Sys.setenv('ARGUMENT_NAME' = 'VALUE')".  Do this for each of the for arguments and you will be all set.
3. When you call a function that requires the use of one of the variables, provide it in the function call. For example `aa_token(client_id, client_secret)`.


