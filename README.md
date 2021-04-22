# Ruby Launcher Code Examples

### Github repo: https://github.com/docusign/code-examples-ruby

To switch between API code examples, modify the `examples_API` setting at the end of the configuration file. Set only one API type to `true` and set the remaining to `false`.

If none of the API types are set to `true`, the DocuSign eSignature REST API code examples will be shown. If multiple API types are set to `true`, only the first will be shown.

Before you can make any API calls using [JWT Grant](https://developers.docusign.com/platform/auth/jwt/), you must get your user’s consent for your app to impersonate them. To do this, the `impersonation` scope is added when requesting a JSON Web Token.


## Introduction
This repo is a Ruby on Rails application.


## eSignature API

For more information about the scopes used for obtaining authorization to use the eSignature API, see the [Required Scopes section](https://developers.docusign.com/docs/esign-rest-api/esign101/auth).

1. **Use embedded signing.**
   [Source.](app/services/e_sign/eg001_embedded_signing_service.rb)
   This example sends an envelope, and then uses embedded signing for the first signer.
   With embedded signing, the DocuSign signing is initiated from your website.
1. **Request a signature by email (Remote Signing).**
   [Source.](app/services/e_sign/eg002_signing_via_email_service.rb)
   The envelope includes a pdf, Word, and HTML document.
   Anchor text ([AutoPlace](https://support.docusign.com/en/guides/AutoPlace-New-DocuSign-Experience)) is used to position the signing fields in the documents.
1. **List envelopes in the user's account.**
   [Source.](app/services/e_sign/eg003_list_envelopes_service.rb)
   The envelopes' current status is included.
1. **Get an envelope's basic information.**
   [Source.](app/services/e_sign/eg004_envelope_info_service.rb)
   The example lists the basic information about an envelope, including its overall status.
1. **List an envelope's recipients**
   [Source.](./app/controllers/e_sign/eg005_envelope_recipients_controller.rb)
   Includes current recipient status.
1. **List an envelope's documents.**
   [Source.](app/services/e_sign/eg006_envelope_docs_service.rb)
1. **Download an envelope's documents.**
   [Source.](app/services/e_sign/eg007_envelope_get_doc_service.rb)
   The example can download individual
   documents, the documents concatenated together, or a zip file of the documents.
1. **Programmatically create a template.**
   [Source.](app/services/e_sign/eg008_create_template_service.rb)
1. **Request a signature by email using a template.**
   The example creates an envelope using a template and sets the initial values for some of its tabs (fields).
   [Source.](app/services/e_sign/eg009_use_template_service.rb)
1. **Send an envelope and upload its documents with multpart binary transfer.**
   [Source.](app/services/e_sign/eg010_send_binary_docs_service.rb)
   Binary transfer is 33% more efficient than using Base64 encoding.
1. **Use embedded sending.**
   [Source.](app/services/e_sign/eg011_embedded_sending_service.rb)
   Embeds the DocuSign web tool (NDSE) in your web app to finalize or update
   the envelope and documents before they are sent.
1. **Embedded DocuSign web tool (NDSE).**
   [Source.](app/services/e_sign/eg012_embedded_console_service.rb)
1. **Use embedded signing from a template with an added document.**
   [Source.](app/services/e_sign/eg013_add_doc_to_template_service.rb)
   This example sends an envelope based on a template.
   In addition to the template's document(s), the example adds an
   additional document to the envelope by using the
   [Composite Templates](https://developers.docusign.com/esign-rest-api/guides/features/templates#composite-templates)
   feature.
1. **Payments example: an order form, with online payment by credit card.**
   [Source.](app/services/e_sign/eg014_collect_payment_service.rb)

1. **Get the envelope tab data.**
   Retrieve the tab (field) values for all of the envelope's recipients.
   [Source.](app/services/e_sign/eg015_get_envelope_tab_data_service.rb)
1. **Set envelope tab values.**
   The example creates an envelope and sets the initial values for its tabs (fields). Some of the tabs
   are set to be read-only, others can be updated by the recipient. The example also stores
   metadata with the envelope.
   [Source.](app/services/e_sign/eg016_set_envelope_tab_data_service.rb)
1. **Set template tab values.**
   The example creates an envelope using a template and sets the initial values for its tabs (fields).
   The example also stores metadata with the envelope.
   [Source.](app/services/e_sign/eg017_set_template_tab_values_service.rb)
1. **Get the envelope custom field data (metadata).**
   The example retrieves the custom metadata (custom data fields) stored with the envelope.
   [Source.](app/services/e_sign/eg018_get_envelope_custom_field_data_service.rb)
1. **Requiring an Access Code for a Recipient**
   [Source.](app/services/e_sign/eg019_access_code_authentication_service.rb)
   This example sends an envelope that requires an access-code for the purpose of multi-factor authentication.
1. **Requiring SMS authentication for a recipient**
   [Source.](app/services/e_sign/eg020_sms_authentication_service.rb)
   This example sends an envelope that requires entering in a six digit code from an text message for the purpose of multi-factor authentication.
1. **Requiring Phone authentication for a recipient**
   [Source.](app/services/e_sign/eg021_phone_authentication_service.rb)
   This example sends an envelope that requires entering in a voice-based response code for the purpose of multi-factor authentication.
1. **Requiring Knowledge-Based Authentication (KBA) for a Recipient**
   [Source.](app/services/e_sign/eg022_kba_authentication_service.rb)
   This example sends an envelope that requires passing a Public records check to validate identity for the purpose of multi-factor authentication.
1. **Requiring ID Verification (IDV) for a recipient**
   [Source.](app/services/e_sign/eg023_idv_authentication_service.rb)
   This example sends an envelope that requires the recipient to upload a government issued id. 

1. **Creating a permission profile**
   [Source.](app/services/e_sign/eg024_permission_create_service.rb)
   This code example demonstrates how to create a user group's permission profile using the [Create Profile](https://developers.docusign.com/esign-rest-api/reference/UserGroups/Groups/create) method. 
1. **Setting a permission profile**
   [Source.](app/services/e_sign/eg025_permissions_set_user_group_service.rb)
   This code example demonstrates how to set a user group's permission profile using the [Update Group](https://developers.docusign.com/esign-rest-api/reference/UserGroups/Groups/update) method. 
   You must have already created permissions profile and group of users.
1. **Updating individual permission settings** 
   [Source.](app/services/e_sign/eg026_permissions_change_single_setting_service.rb)
   This code example demonstrates how to update individual settings for a specific permission profile using the [Update Permission Profile](https://developers.docusign.com/esign-rest-api/reference/Accounts/AccountPermissionProfiles/update) method.
   You must have already created permissions profile and group of users.
1. **Deleting a permission profile**
   [Source.](app/services/e_sign/eg027_permissions_delete_service.rb)
   This code example demonstrates how to an account's permission profile using the [Delete AccountPermissionProfiles](https://developers.docusign.com/esign-rest-api/reference/Accounts/AccountPermissionProfiles/delete) method. 
   You cannot delete the Everyone nor the Administrator profile types as those are defaults.

1. **Creating a brand**
   [Source.](app/services/e_sign/eg028_brands_creating_service.rb)
   This example creates brand profile for an account using the [Create Brand](https://developers.docusign.com/esign-rest-api/reference/Accounts/AccountBrands/create) method.
1. **Applying a brand to an envelope**
   [Source.](app/services/e_sign/eg029_brands_apply_to_envelope_service.rb)
   This code example demonstrates how to apply a brand you've created to an envelope using the [Create Envelope](https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/create) method. 
   First, creates the envelope and then applies brand to it.
   
1. **Applying a brand to a template**
   [Source.](app/services/e_sign/eg030_brands_apply_to_template_service.rb)
   This code example demonstrates how to apply a brand you've created to a template using using the [Create Envelope](https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/create) method. 
   You must have at least one created template and brand.
   
1. **Bulk sending envelopes to multiple recipients**
   [Source.](app/services/e_sign/eg031_bulk_sending_envelopes_service.rb)
   This example creates and sends a bulk envelope by generating a bulk recipient list and initiating a bulk send.
   
1. **Pausing a signature workflow**
   [Source.](app/services/e_sign/eg032_pauses_signature_workflow_service.rb)
   This example demonstrates how to create an envelope where the workflow is paused before the envelope is sent to a second recipient.
  
1. **Unpausing a signature workflow**
   [Source.](app/services/e_sign/eg033_unpauses_signature_workflow_service.rb)
   This example demonstrates how to resume an envelope workflow that has been paused.
     
1. **Using conditional recipients**
   [Source.](app/services/e_sign/eg034_use_conditional_recipients_service.rb)
   This example demonstrates how to create an envelope where the workflow is routed to different recipients based on the value of a transaction.

1. **Request a signature by SMS delivery**
   [Source.](app/services/e_sign/eg035_sms_delivery_service.rb)
   This code example demonstrates how to send a signature request via an SMS message using the [Envelopes: create](https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/create) method.


## Rooms API

**Note:** To use the Rooms API, you must also [create a Rooms developer account](https://developers.docusign.com/docs/rooms-api/rooms101/create-account).  
For more information about the scopes used for obtaining authorization to use the Rooms API, see the [Required Scopes section](https://developers.docusign.com/docs/rooms-api/rooms101/auth/).

1. **Create a room with data.**
   [Source.](./app/services/room_api/eg001_create_room_with_data_service.rb)
   This example creates a new room in your DocuSign Rooms account to be used for a transaction.
1. **Create a room from a template.**
   [Source.](./app/services/room_api/eg002_create_room_with_template_service.rb)
   This example creates a new room using a template.
1. **Export data from a room.**
   [Source.](./app/services/room_api/eg003_export_data_from_room_service.rb)
   This example exports all the available data from a specific room in your DocuSign Rooms account.
1. **Add forms to a room.**
   [Source.](./app/services/room_api/eg004_add_forms_to_room_service.rb)
   This example adds a standard real estate related form to a specific room in your DocuSign Rooms account.
1. **Search for rooms with filters.**
   [Source.](./app/services/room_api/eg005_get_rooms_with_filters_service.rb)
   This example searches for rooms in your DocuSign Rooms account using a specific filter.
1. **Get an external form fillable session.**
   [Source.](./app/services/room_api/eg006_create_an_external_form_fill_session_service.rb)
   This example creates an external form that can be filled using DocuSign for a specific room in your DocuSign Rooms account.
1. **Creating a form group.**
   [Source.](./app/services/room_api/eg007_create_form_group_service.rb)
   This example creates a new form group with the name given in the name property of the request body.
1. **Grant office access to a form group.**
   [Source.](./app/services/room_api/eg008_grant_office_access_to_form_group_service.rb)
   This example assigns an office to a form group for your DocuSign Rooms.
1. **Assign a form to a form group.**
   [Source.](./app/services/room_api/eg009_assign_form_to_form_group_service.rb)
   This example assigns a form to a form group for your DocuSign Rooms.


## Click API

For more information about the scopes used for obtaining authorization to use the Clickwrap API, see the [Required Scopes section](https://developers.docusign.com/docs/click-api/click101/auth).

1. **Creating a clickwrap.**
[Source.](./app/services/clickwrap/eg001_create_clickwrap_service.rb)
This example demonstrates how to use the Click API to create a clickwrap that you can embed in your website or app.
1. **Activate a clickwrap.**
[Source.](./app/services/clickwrap/eg002_activate_clickwrap_service.rb)
This example demonstrates how to use the Click API to activate a new clickwrap that you have already created.
1. **Creating a new clickwrap version.**
[Source.](./app/services/clickwrap/eg003_create_new_clickwrap_version_service.rb)
This example demonstrates how to use the Click API to create a new version of a clickwrap.
1. **Getting a list of clickwraps.**
[Source.](./app/services/clickwrap/eg004_list_clickwraps_service.rb)
This example demonstrates how to use the Click API to get a list of clickwraps associated with a specific DocuSign user.
1. **Getting clickwrap responses.**
[Source.](./app/services/clickwrap/eg005_clickwrap_responses_service.rb)
This example demonstrates how to use the Click API to get a list of clickwraps associated with a specific DocuSign user.


## Installation

### Prerequisites
**Note:** If you downloaded this code using [Quickstart](https://developers.docusign.com/docs/esign-rest-api/quickstart/) from the DocuSign Developer Center, skip items 1 and 2 as they were automatically performed for you.

1. A free [DocuSign developer account](https://go.docusign.com/o/sandbox/); create one if you don't already have one.
1. A DocuSign app and integration key that is configured to use either [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/) or [JWT Grant](https://developers.docusign.com/platform/auth/jwt/) authentication.

   This [video](https://www.youtube.com/watch?v=eiRI4fe5HgM) demonstrates how to obtain an integration key.  

   To use [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/), you will need an integration key and a secret key. See [Installation steps](#installation-steps) for details.  

   To use [JWT Grant](https://developers.docusign.com/platform/auth/jwt/), you will need an integration key, an RSA key pair, and the API Username GUID of the impersonated user. See [Installation steps for JWT Grant authentication](#installation-steps-for-jwt-grant-authentication) for details.  

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
**Note:** If you downloaded this code using [Quickstart](https://developers.docusign.com/docs/esign-rest-api/quickstart/) from the DocuSign Developer Center, skip step 4 as it was automatically performed for you.

1. Extract the Quickstart ZIP file or download or clone the code-examples-ruby repository.
1. In your command-line environment, switch to the folder:  
   `cd <Quickstart folder>` or `cd code-examples-ruby`
1. Install the dependencies: `bundler install`
1. To configure the launcher for [Authorization Code Grant](https://developers.docusign.com/platform/auth/authcode/) authentication, create a copy of the file config/appsettings.example.yml and save the copy as config/appsettings.yml.
   1. Add your integration key. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **Apps and Integration Keys**, choose the app to use, then select **Actions** > **Edit**. Under **General Info**, copy the **Integration Key** GUID and save it in appsettings.yml as your `integration_key`.
   1. Generate a secret key, if you don’t already have one. Under **Authentication**, select **+ ADD SECRET KEY**. Copy the secret key and save it in appsettings.yml as your `integration_secret`.
   1. Add the launcher’s redirect URI. Under **Additional settings**, select **+ ADD URI**, and set a redirect URI of http://localhost:3000/auth/docusign/callback. Select **SAVE**.   
   1. Set a name and email address for the signer. In appsettings.yml, save an email address as `signer_email` and a name as `signer_name`.  
**Note:** Protect your personal information. Please make sure that appsettings.yml will not be stored in your source code repository.
1. Run the launcher: `rails s`
1. Open a browser to http://localhost:3000


### Installation steps for JWT Grant authentication
**Note:** If you downloaded this code using [Quickstart](https://developers.docusign.com/docs/esign-rest-api/quickstart/) from the DocuSign Developer Center, skip step 4 as it was automatically performed for you.  
Also, in order to select JSON Web Token authentication in the launcher, in config/appsettings.yml, change `quickstart` to `false`.

1. Extract the Quickstart ZIP file or download or clone the code-examples-ruby repository.
1. In your command-line environment, switch to the folder:  
   `cd <Quickstart folder>` or `cd code-examples-ruby`
1. Install the dependencies: `bundler install`
1. To configure the launcher for [JWT Grant](https://developers.docusign.com/platform/auth/jwt/) authentication, create a copy of the file config/appsettings.example.yml and save the copy as config/appsettings.yml.
   1. Add your API Username. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **My Account Information**, copy the **API Username** GUID and save it in appsettings.yml as your `impersonated_user_guid`.
   1. Add your integration key. On the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=apiIntegratorKey) page, under **Apps and Integration Keys**, choose the app to use, then select **Actions** > **Edit**. Under **General Info**, copy the **Integration Key** GUID and save it in appsettings.yml as your `jwt_integration_key`.
   1. Generate an RSA key pair, if you don’t already have one. Under **Authentication**, select **+ GENERATE RSA**. Copy the private key and save it in a new file named config/docusign_private_key.txt.
   1. Add the launcher’s redirect URI. Under **Additional settings**, select **+ ADD URI**, and set a redirect URI of http://localhost:3000/auth/docusign/callback. Select **SAVE**.   
   1. Set a name and email address for the signer. In appsettings.yml, save an email address as `signer_email` and a name as `signer_name`.  
**Note:** Protect your personal information. Please make sure that appsettings.yml will not be stored in your source code repository.
1. Run the launcher: `rails s`
1. Open a browser to http://localhost:3000
1. If it is your first time using the app, grant consent by selecting **Accept**. On the black navigation bar, select **Logout**, then **Login**.
1. From the picklist, select **JSON Web Token (JWT) grant** > **Authenticate with DocuSign**.
1. Select your desired code example.


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

Find the relevant DocuSign Ruby SDK you are using. The name always starts with “docusign”; for instance, DocuSign Click SDK version 1.0.0:

C:\Ruby27-x64\lib\ruby\gems\2.7.0\gems\docusign_click-1.0.0\lib\docusign_click

Find the **configuration.rb** file in that folder.
Modify the following two lines in the **configuration.rb** file, replacing `true` with `false`:

      @verify_ssl = true
      @verify_ssl_host = true


Once this is complete, you can run your Ruby on Rails application again and you should be able to make API calls on your localhost.


## Payments code example
To use the payments code example, create a test payment gateway on the [**Payments**](https://admindemo.docusign.com/authenticate?goTo=payments) page in your developer account. See [Configure a payment gateway](./PAYMENTS_INSTALLATION.md) for details.

Once you've created a payment gateway, save the **Gateway Account ID** GUID to appsettings.yml.

## License and additional information

### License
This repository uses the MIT License. See [LICENSE](./LICENSE) for details.


### Pull Requests
Pull requests are welcomed. Pull requests will only be considered if their content
uses the MIT License.
