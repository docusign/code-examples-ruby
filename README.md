# Ruby Launcher Code Examples

### Github repo: code-examples-ruby
## Introduction
This repo is a Ruby on Rails application that demonstrates:


### Example Workflows
This launcher includes code examples for the following workflows:

1. **Embedded Signing Ceremony.**
   [Source.](./app/services/e_sign/eg001_service.rb)
   This example sends an envelope, and then uses an embedded signing ceremony for the first signer.
   With embedded signing, the DocuSign signing ceremony is initiated from your website.
1. **Send an envelope with a remote (email) signer and cc recipient.**
   [Source.](./app/services/e_sign/eg002_service.rb)
   The envelope includes a pdf, Word, and HTML document.
   Anchor text ([AutoPlace](https://support.docusign.com/en/guides/AutoPlace-New-DocuSign-Experience)) is used to position the signing fields in the documents.
1. **List envelopes in the user's account.**
   [Source.](./app/services/e_sign/eg003_service.rb)
   The envelopes' current status is included.
1. **Get an envelope's basic information.**
   [Source.](./app/services/e_sign/eg004_service.rb)
   The example lists the basic information about an envelope, including its overall status.
1. **List an envelope's recipients**
   [Source.](./app/controllers/eg005_envelope_recipients_controller.rb)
   Includes current recipient status.
1. **List an envelope's documents.**
   [Source.](./app/services/e_sign/eg006_service.rb)
1. **Download an envelope's documents.**
   [Source.](./app/services/e_sign/eg007_service.rb)
   The example can download individual
   documents, the documents concatenated together, or a zip file of the documents.
1. **Programmatically create a template.**
   [Source.](./app/services/e_sign/eg008_service.rb)
1. **Send an envelope using a template.**
   The example creates an envelope using a template and sets the initial values for some of its tabs (fields).
   [Source.](./app/services/eg009_service.rb)
1. **Send an envelope and upload its documents with multpart binary transfer.**
   [Source.](./app/services/e_sign/eg010_service.rb)
   Binary transfer is 33% more efficient than using Base64 encoding.
1. **Embedded sending.**
   [Source.](./app/services/e_sign/eg011_service.rb)
   Embeds the DocuSign web tool (NDSE) in your web app to finalize or update
   the envelope and documents before they are sent.
1. **Embedded DocuSign web tool (NDSE).**
   [Source.](./app/services/e_sign/eg012_service.rb)
1. **Embedded Signing Ceremony from a template with an added document.**
   [Source.](./app/services/e_sign/eg013_service.rb)
   This example sends an envelope based on a template.
   In addition to the template's document(s), the example adds an
   additional document to the envelope by using the
   [Composite Templates](https://developers.docusign.com/esign-rest-api/guides/features/templates#composite-templates)
   feature.
1. **Payments example: an order form, with online payment by credit card.**
   [Source.](./app/services/e_sign/eg014_service.rb)


1. **Get the envelope tab data.**
   Retrieve the tab (field) values for all of the envelope's recipients.
   [Source.](./app/services/e_sign/eg015_service.rb)
1. **Set envelope tab values.**
   The example creates an envelope and sets the initial values for its tabs (fields). Some of the tabs
   are set to be read-only, others can be updated by the recipient. The example also stores
   metadata with the envelope.
   [Source.](./app/services/e_sign/eg016_service.rb)
1. **Set template tab values.**
   The example creates an envelope using a template and sets the initial values for its tabs (fields).
   The example also stores metadata with the envelope.
   [Source.](./app/services/e_sign/eg017_service.rb)
1. **Get the envelope custom field data (metadata).**
   The example retrieves the custom metadata (custom data fields) stored with the envelope.
   [Source.](./app/services/e_sign/eg018_service.rb)
1. **Requiring an Access Code for a Recipient**
   [Source.](./app/services/e_sign/eg019_service.rb)
   This example sends an envelope that requires an access-code for the purpose of multi-factor authentication.
1. **Requiring SMS authentication for a recipient**
   [Source.](./app/services/e_sign/eg020_service.rb)
   This example sends an envelope that requires entering in a six digit code from an text message for the purpose of multi-factor authentication.
1. **Requiring Phone authentication for a recipient**
   [Source.](./app/services/e_sign/eg021_service.rb)
   This example sends an envelope that requires entering in a voice-based response code for the purpose of multi-factor authentication.
1. **Requiring Knowledge-Based Authentication (KBA) for a Recipient**
   [Source.](./app/services/e_sign/eg022_service.rb)
   This example sends an envelope that requires passing a Public records check to validate identity for the purpose of multi-factor authentication.
1. **Requiring ID Verification (IDV) for a recipient**
   [Source.](./app/services/e_sign/eg023_service.rb)
   This example sends an envelope that requires the recipient to upload a government issued id. 

1. **Creating a permission profile**
   [Source.](./app/services/e_sign/eg024_service.rb)
   This code example demonstrates how to create a user group's permission profile using the [Create Profile](https://developers.docusign.com/esign-rest-api/reference/UserGroups/Groups/create) method. 
1. **Setting a permission profile**
   [Source.](./app/services/e_sign/eg025_service.rb)
   This code example demonstrates how to set a user group's permission profile using the [Update Group](https://developers.docusign.com/esign-rest-api/reference/UserGroups/Groups/update) method. 
   You must have already created permissions profile and group of users.
1. **Updating individual permission settings** 
   [Source.](./app/services/e_sign/eg026_service.rb)
   This code example demonstrates how to update individual settings for a specific permission profile using the [Update Permission Profile](https://developers.docusign.com/esign-rest-api/reference/Accounts/AccountPermissionProfiles/update) method.
   You must have already created permissions profile and group of users.
1. **Deleting a permission profile**
   [Source.](./app/services/e_sign/eg027_service.rb)
   This code example demonstrates how to an account's permission profile using the [Delete AccountPermissionProfiles](https://developers.docusign.com/esign-rest-api/reference/Accounts/AccountPermissionProfiles/delete) method. 
   You cannot delete the Everyone nor the Administrator profile types as those are defaults.

1. **Creating a brand**
   [Source.](./app/services/e_sign/eg028_service.rb)
   This example creates brand profile for an account using the [Create Brand](https://developers.docusign.com/esign-rest-api/reference/Accounts/AccountBrands/create) method.
1. **Applying a brand to an envelope**
   [Source.](./app/services/e_sign/eg029_service.rb)
   This code example demonstrates how to apply a brand you've created to an envelope using the [Create Envelope](https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/create) method. 
   First, creates the envelope and then applies brand to it.
   
1. **Applying a brand to a template**
   [Source.](./app/services/e_sign/eg030_service.rb)
   This code example demonstrates how to apply a brand you've created to a template using using the [Create Envelope](https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/create) method. 
   You must have at least one created template and brand.
   
1. **Bulk sending envelopes to multiple recipients**
   [Source.](./app/services/e_sign/eg031_service.rb)
   This example creates and sends a bulk envelope by generating a bulk recipient list and initiating a bulk send.


## Included OAuth grant types:

* Authentication with Docusign via [Authorization Code Grant flow](https://developers.docusign.com/esign-rest-api/guides/authentication/oauth2-code-grant) .
When the token expires, the user is asked to re-authenticate.
The **refresh token** is not used in this example.

* Authentication with DocuSign via the [JSON Web Token (JWT) Grant](https://developers.docusign.com/esign-rest-api/guides/authentication/oauth2-jsonwebtoken).
When the token expires, it updates automatically.


## Installation

### Prerequisites
1. A DocuSign Developer Sandbox account (email and password) on [demo.docusign.net](https://demo.docusign.net).
   Create a [free account](https://go.docusign.com/sandbox/productshot/?elqCampaignId=16536).
1. A DocuSign Integration Key and secret key (a client ID). To use JSON Web token, you will need the Integration Key itself, the RSA Secret Key and an API user ID for the user you are impersonating.
   
   You will need the **Integration Key** itself, and its **secret**.

   The Integration key must include a **Redirect URI** of

   `{base_url}/auth/docusign/callback`

   Where `{base_url}` is the url for the web app.

   By default, the rails app starts on url `http://localhost:3000`
   
   So the default Redirect URI for your Integration Key is

   `http://localhost:3000/auth/docusign/callback`

1. Ruby version 2.7.1 or later. Or you can update the Gemfile to use other versions of Ruby.
1. A name and email for a signer, and a name and email for a cc recipient.

### Installation steps
1. Download or clone this repository to your workstation to directory **code-examples-ruby**
1. **cd code-examples-ruby**
1. Install the needed gems listed in the Gemfile:

   Run **bundler install**
1. Copy the file **config/appsettings.example.yml** into a new file named **config/appsettings.yml**
1. Update the file **config/appsettings.yml** with the Integration Key and other settings.
     Note: The terms "client_id" and "Integration key" are synonyms. They refer to the same thing.

1. Update your Integration Key's settings to include a **Redirect URI** for
   your installation of the example. See Prerequisites item #2, above for more information.

#### Run the application
1. To start the development web server and application:

   Run **rails s** 
   *Note that on Windows additional actions might be necessary:*
   - *Install sqlite3: **gem install sqlite3 --platform=ruby***
   - *Download curllib.dll (https://curl.haxx.se/windows/)*
   - *libcurl-x64.dll should be copied as libcurl.dll*
   - *Place curllib.dll into Ruby `C:\\<Ruby installation>\bin`*
1. Open a browser to the example's base url to view the index page.


### Configuring JWT

1. Create a developer sandbox account on developers.docusign.com if you don't already have one.
2. Create a new API key in the Admin panel: https://admindemo.docusign.com/api-integrator-key
  - Take note of the _Integration Key_.
  - Generate a _RSA Keypair_ and copy the private key to a secure location.
  - Set a _Redirect URI_ of `http://localhost:3000/auth/docusign/callback` as mentioned in the installation steps above.
3. Create a new file in the config folder named **docusign_private_key.txt**, and paste in that copied RSA private key, then save it.
4. Update the file **config/appsettings.yml** and include the settings from step 2.

[Obtaining consent](https://developers.docusign.com/esign-rest-api/guides/authentication/obtaining-consent#individual-consent) does not need to be configured, as it is already being done in the code at [JwtAuth::JwtCreator#update_token](./app/services/jwt_auth/jwt_creator.rb#L35)

From there you should be able to run the launcher using `bundle exec rails server` then selecting **JSON Web Token** when authenticaing your account.


#### Payments code example
To use the payments example, create a
test payments gateway for your developer sandbox account.

See the
[PAYMENTS_INSTALLATION.md](./PAYMENTS_INSTALLATION.md)
file for instructions.

Then add the payment gateway account id to the **config/application.rb** file.

## Using the examples with other authentication flows

The examples in this repository can also be used with the
Implicit grant OAuth flow.
See the [Authentication guide](https://developers.docusign.com/esign-rest-api/guides/authentication)
for information on choosing the right authentication flow for your application.

## License and additional information

### License
This repository uses the MIT License. See the LICENSE file for more information.

### Pull Requests
Pull requests are welcomed. Pull requests will only be considered if their content
uses the MIT License.

### Additional Resources
* [DocuSign Developer Center](https://developers.docusign.com)
* [DocuSign API on Twitter](https://twitter.com/docusignapi)
* [DocuSign For Developers on LinkedIn](https://www.linkedin.com/showcase/docusign-for-developers/)
* [DocuSign For Developers on YouTube](https://www.youtube.com/channel/UCJSJ2kMs_qeQotmw4-lX2NQ)
