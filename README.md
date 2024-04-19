# Ruby Launcher Code Examples

### GitHub repo: [code-examples-ruby](./README.md)

This GitHub repo includes code examples for the Docusign Admin API, Click API, eSignature REST API, Monitor API, and Rooms API. To switch between API code examples, modify the `examples_API` setting in the appsettings.yml file. Set only one API type to `true` and set the remaining to `false`.

If none of the API types are set to `true`, the Docusign eSignature REST API code examples will be shown. If multiple API types are set to `true`, only the first will be shown.

## Introduction
This repo is a Ruby on Rails application that supports the following authentication workflows:

* Authentication with Docusign via [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode).
When the token expires, the user is asked to re-authenticate. The refresh token is not used.

* Authentication with Docusign via [JSON Web Token (JWT) Grant](https://developers.docusign.com/platform/auth/jwt/).
When the token expires, it updates automatically.

## eSignature API

For more information about the scopes used for obtaining authorization to use the eSignature API, see [Required scopes](https://developers.docusign.com/docs/esign-rest-api/esign101/auth#required-scopes).

For a list of code examples that use the eSignature API, see the [How-to guides overview](https://developers.docusign.com/docs/esign-rest-api/how-to/) on the Docusign Developer Center.


## Rooms API

**Note:** To use the Rooms API, you must also [create your Rooms developer account](https://developers.docusign.com/docs/rooms-api/rooms101/create-account). Examples 4 and 6 require that you have the Docusign Forms feature enabled in your Rooms for Real Estate account.
For more information about the scopes used for obtaining authorization to use the Rooms API, see [Required scopes](https://developers.docusign.com/docs/rooms-api/rooms101/auth/).

For a list of code examples that use the Rooms API, see the [How-to guides overview](https://developers.docusign.com/docs/rooms-api/how-to/) on the Docusign Developer Center.


## Click API
For more information about the scopes used for obtaining authorization to use the Click API, see [Required scopes](https://developers.docusign.com/docs/click-api/click101/auth/#required-scopes)

For a list of code examples that use the Click API, see the [How-to guides overview](https://developers.docusign.com/docs/click-api/how-to/) on the Docusign Developer Center.


## Monitor API

**Note:** To use the Monitor API, you must also [enable Docusign Monitor for your organization](https://developers.docusign.com/docs/monitor-api/how-to/enable-monitor/).

For information about the scopes used for obtaining authorization to use the Monitor API, see the [scopes section](https://developers.docusign.com/docs/monitor-api/monitor101/auth/).

For a list of code examples that use the Monitor API, see the [How-to guides overview](https://developers.docusign.com/docs/monitor-api/how-to/) on the Docusign Developer Center.


## Admin API

**Note:** To use the Admin API, you must [create an organization](https://support.docusign.com/en/guides/org-admin-guide-create-org) in your Docusign developer account. Also, to run the Docusign CLM code example, [CLM must be enabled for your organization](https://support.docusign.com/en/articles/DocuSign-and-SpringCM).

For information about the scopes used for obtaining authorization to use the Admin API, see the [scopes section](https://developers.docusign.com/docs/admin-api/admin101/auth/).

For a list of code examples that use the Admin API, see the [How-to guides overview](https://developers.docusign.com/docs/admin-api/how-to/) on the Docusign Developer Center.

## Installation

### Prerequisites
**Note:** If you downloaded this code using [Quickstart](https://developers.docusign.com/docs/esign-rest-api/quickstart/) from the Docusign Developer Center, skip items 1 and 2 as they were automatically performed for you.

1. A free [Docusign developer account](https://go.docusign.com/o/sandbox/); create one if you don't already have one.
1. A Docusign app and integration key that is configured for authentication to use either [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/) or [JWT Grant](https://developers.docusign.com/platform/auth/jwt/).

   This [video](https://www.youtube.com/watch?v=eiRI4fe5HgM) demonstrates how to obtain an integration key.

   To use [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/), you will need an integration key and a secret key. See [Installation steps](#installation-steps) for details.

   To use [JWT Grant](https://developers.docusign.com/platform/auth/jwt/), you will need an integration key, an RSA key pair, and the User ID GUID of the impersonated user. See [Installation steps for JWT Grant authentication](#installation-steps-for-jwt-grant-authentication) for details.

   For both authentication flows:

   If you use this launcher on your own workstation, the integration key must include a redirect URI of

   http://localhost:3000/auth/docusign/callback

   If you host this launcher on a remote web server, set your redirect URI as

   {base_url}/auth/docusign/callback

   where {base_url} is the URL for the web app.

1. [Ruby version 2.7.2](https://www.ruby-lang.org/en/downloads/) or later
   1. Update the Gemfile to use later versions of Ruby.
   1. Windows x64 only:
      1. Ensure that your Ruby folder is appended with **-x64**, e.g. **Ruby27-x64**
      2. Install Curl for Ruby: [Download libcurl.dll](https://curl.haxx.se/windows/)
         Save **libcurl-x64.dll** as **libcurl.dll**
         Place **libcurl.dll** in your Ruby folder, e.g. **C:&#92;Ruby27-x64&#92;bin**


### Installation steps
**Note:** If you downloaded this code using [Quickstart](https://developers.docusign.com/docs/esign-rest-api/quickstart/) from the Docusign Developer Center, skip step 4 as it was automatically performed for you.

1. Extract the Quickstart ZIP file, or download or clone the code-examples-ruby repository.
1. In your command-line environment, switch to the folder:
   `cd <Quickstart folder>` or `cd code-examples-ruby`
1. To install dependencies, run: `bundler install`
1. To configure the launcher for [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/) authentication, create a copy of the file config/appsettings.example.yml and save the copy as config/appsettings.yml.
   1. Add your integration key. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **Apps and Integration Keys**, choose the app to use, then select **Actions** > **Edit**. Under **General Info**, copy the **Integration Key** GUID and save it in appsettings.yml as your `integration_key`.
   1. Generate a secret key, if you don’t already have one. Under **Authentication**, select **+ ADD SECRET KEY**. Copy the secret key and save it in appsettings.yml as your `integration_secret`.
   1. Add the launcher’s redirect URI. Under **Additional settings**, select **+ ADD URI**, and set a redirect URI of http://localhost:3000/auth/docusign/callback. Select **SAVE**.
   1. Set a name and email address for the signer. In appsettings.yml, save an email address as `signer_email` and a name as `signer_name`.
**Note:** Protect your personal information. Please make sure that appsettings.yml will not be stored in your source code repository.
1. Run the launcher: `rails s`
1. Open a browser to http://localhost:3000


### Installation steps for JWT Grant authentication
**Note:** If you downloaded this code using [Quickstart](https://developers.docusign.com/docs/esign-rest-api/quickstart/) from the Docusign Developer Center, skip step 4 as it was automatically performed for you.
Also, in order to select JSON Web Token authentication in the launcher, in config/appsettings.yml, change `quickstart` to `false`.

1. Extract the Quickstart ZIP file or download or clone the code-examples-ruby repository.
1. In your command-line environment, switch to the folder:
   `cd <Quickstart folder>` or `cd code-examples-ruby`
1. Install the dependencies: `bundler install`
1. To configure the launcher for [JWT Grant](https://developers.docusign.com/platform/auth/jwt/) authentication, create a copy of the file config/appsettings.example.yml and save the copy as config/appsettings.yml.
   1. Add your User ID. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **My Account Information**, copy the **User ID** GUID and save it in appsettings.yml as your `impersonated_user_guid`.
   1. Add your integration key. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **Apps and Integration Keys**, choose the app to use, then select **Actions** > **Edit**. Under **General Info**, copy the **Integration Key** GUID and save it in appsettings.yml as your `jwt_integration_key`.
   1. Generate an RSA key pair, if you don’t already have one. Under **Authentication**, select **+ GENERATE RSA**. Copy the private key and save it in a new file named config/docusign_private_key.txt.
   1. Add the launcher’s redirect URI. Under **Additional settings**, select **+ ADD URI**, and set a redirect URI of http://localhost:3000/auth/docusign/callback. Select **SAVE**.
   1. Set a name and email address for the signer. In appsettings.yml, save an email address as `signer_email` and a name as `signer_name`.
**Note:** Protect your personal information. Please make sure that appsettings.yml will not be stored in your source code repository.
1. Run the launcher: `rails s`
1. Open a browser to http://localhost:3000
1. If it is your first time using the app, grant consent by selecting **Accept**. On the black navigation bar, select **Logout**, then **Login**.
1. From the picklist, select **JSON Web Token (JWT) grant** > **Authenticate with Docusign**.
1. Select your desired code example.

## JWT grant remote signing and Authorization Code Grant embedded signing projects
See [Docusign Quickstart overview](https://developers.docusign.com/docs/esign-rest-api/quickstart/overview/) on the Docusign Developer Center for more information on how to run the JWT grant remote signing project and the Authorization Code Grant embedded signing project.


### Troubleshooting Windows SSL issue
When using the Ruby launcher on a Windows machine you may get the following error:

**SSL peer certificate or SSH remote key was not OK**

This error occurs because you’re attempting to use the Ruby launcher with a self-signed certificate or without SSL/HTTP security. The API calls from Ruby SDKs are using a built-in Curl tool that is enforcing the SSL requirement. You can disable this security check to run the launcher in an insecure manner on your developer machine.

```diff
- It is highly recommended that you don’t disable this security check
- in a production environment or in your integration.
- This method is offered here solely as a means to enable you to
- develop quickly by lowering the security bar on your local machine.
```
Find the root folder for your Ruby gems (in this case, a 64-bit version of Ruby 2.7.0):

C:\Ruby27-x64\lib\ruby\gems\2.7.0\gems\

Find the relevant Docusign Ruby SDK you are using. The name always starts with “docusign”; for instance, Docusign Click SDK version 1.0.0:

C:\Ruby27-x64\lib\ruby\gems\2.7.0\gems\docusign_click-1.0.0\lib\docusign_click

Find the **configuration.rb** file in that folder.
Modify the following two lines in the **configuration.rb** file, replacing `true` with `false`:

      @verify_ssl = true
      @verify_ssl_host = true


Once this is complete, you can run your Ruby on Rails application again and you should be able to make API calls on your localhost.

### Troubleshooting macOS SSL issue
When using the Ruby launcher on OSX you may get the following error:

```
Faraday::SSLError (SSL_connect returned=1 errno=0 state=error: certificate verify failed (self signed certificate in certificate chain))
```
Please update SSL certificates if rvm is your version manager. Or check [other steps for different scenarios](https://gemfury.com/help/could-not-verify-ssl-certificate/#updating-ssl-certificates).
```
$ rvm osx-ssl-certs status all
$ rvm osx-ssl-certs update all
```

## Payments code example
To use the payments code example, create a test payment gateway on the [**Payments**](https://admindemo.docusign.com/authenticate?goTo=payments) page in your developer account. See [Configure a payment gateway](./PAYMENTS_INSTALLATION.md) for details.

Once you've created a payment gateway, save the **Gateway Account ID** GUID to appsettings.yml.

## License and additional information

### License
This repository uses the MIT License. See [LICENSE](./LICENSE) for details.


### Pull Requests
Pull requests are welcomed. Pull requests will only be considered if their content
uses the MIT License.
