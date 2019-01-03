# Ruby: Authorization Code Grant Examples

### Github repo: eg-03-ruby-auth-code-grant
## Introduction
This repo is a Ruby on Rails application that demonstrates:

* **Authentication with DocuSign** via the
[Authorization Code Grant flow](https://developers.docusign.com/esign-rest-api/guides/authentication/oauth2-code-grant).
  When the token expires, the user is asked to re-authenticate.
  The **refresh token** is not used in this example.

  The [OmniAuth](https://github.com/omniauth/omniauth) library is used
  for authentication. This example includes a DocuSign OAuth2
  [strategy](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/lib/docusign.rb)
  for the OAuth package. The DocuSign strategy:
  
  * Uses the Authorization Code Grant flow to obtain an access token.
  * Calls the [OAuth::getUser](https://developers.docusign.com/esign-rest-api/guides/authentication/user-info-endpoints)
    API method.
  * Processes the OAuth::getUser results to obtain the user's name, email,
    account id, account name, and base path.

  In this example, OmniAuth is called from 
  [session_controller.rb](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/session_controller.rb). Omniauth is additionally configured and referenced in other files, search the project for "omni" for a complete list.

### Example Workflows
This launcher includes code examples for the following workflows:

1. **Embedded Signing Ceremony.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg001_embedded_signing_controller.rb)
   This example sends an envelope, and then uses an embedded signing ceremony for the first signer.
   With embedded signing, the DocuSign signing ceremony is initiated from your website.
1. **Send an envelope with a remote (email) signer and cc recipient.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg002_signing_via_email_controller.rb)
   The envelope includes a pdf, Word, and HTML document.
   Anchor text ([AutoPlace](https://support.docusign.com/en/guides/AutoPlace-New-DocuSign-Experience)) is used to position the signing fields in the documents.
1. **List envelopes in the user's account.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg003_list_envelopes_controller.rb)
   The envelopes' current status is included.
1. **Get an envelope's basic information.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg004_envelope_info_controller.rb)
   The example lists the basic information about an envelope, including its overall status.
1. **List an envelope's recipients**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg005_envelope_recipients_controller.rb)
   Includes current recipient status.
1. **List an envelope's documents.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg006_envelope_docs_controller.rb)
1. **Download an envelope's documents.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg007_envelope_get_doc_controller.rb)
   The example can download individual
   documents, the documents concatenated together, or a zip file of the documents.
1. **Programmatically create a template.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg008_create_template_controller.rb)
1. **Send an envelope using a template.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg009_use_template_controller.rb)
1. **Send an envelope and upload its documents with multpart binary transfer.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg010_send_binary_docs_controller.rb)
   Binary transfer is 33% more efficient than using Base64 encoding.
1. **Embedded sending.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg011_embedded_sending_controller.rb)
   Embeds the DocuSign web tool (NDSE) in your web app to finalize or update
   the envelope and documents before they are sent.
1. **Embedded DocuSign web tool (NDSE).**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg012_embedded_console_controller.rb)
1. **Embedded Signing Ceremony from a template with an added document.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg013_add_doc_to_template_controller.rb)
   This example sends an envelope based on a template.
   In addition to the template's document(s), the example adds an
   additional document to the envelope by using the
   [Composite Templates](https://developers.docusign.com/esign-rest-api/guides/features/templates#composite-templates)
   feature.
1. **Payments example: an order form, with online payment by credit card.**
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/eg014_collect_payment_controller.rb)

<!--
1. **Get the envelope tab data.**
   Retrieve the tab (field) values for all of the envelope's recipients.
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/EG015EnvelopeTabData_controller.rb)
1. **Set envelope tab values.**
   The example creates an envelope and sets the initial values for its tabs (fields). Some of the tabs
   are set to be read-only, others can be updated by the recipient. The example also stores
   metadata with the envelope.
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/EG016SetTabValues_controller.rb)
1. **Set template tab values.**
   The example creates an envelope using a template and sets the initial values for its tabs (fields).
   The example also stores metadata with the envelope.
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/EG017SetTemplateTabValues_controller.rb)
1. **Get the envelope custom field data (metadata).**
   The example retrieves the custom metadata (custom data fields) stored with the envelope.
   [Source.](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/app/controllers/EG018EnvelopeCustomFieldData_controller.rb)
-->

## Installation

### Prerequisites
1. A DocuSign Developer Sandbox account (email and password) on [demo.docusign.net](https://demo.docusign.net).
   Create a [free account](https://go.docusign.com/o/sandbox/).
1. A DocuSign Integration Key (a client ID) that is configured to use the
   OAuth Authorization Code flow.
   You will need the **Integration Key** itself, and its **secret**.

   The Integration key must include a **Redirect URI** of

   `{base_url}/auth/docusign/callback`

   Where `{base_url}` is the url for the web app.

   By default, the rails app starts on url `http://localhost:3000`
   
   So the default Redirect URI for your Integration Key is

   `http://localhost:3000/auth/docusign/callback`

1. Ruby version 2.5.3 or later. Or you can update the Gemfile to use other versions of Ruby.
1. A name and email for a signer, and a name and email for a cc recipient.

### Installation steps
1. Download or clone this repository to your workstation to directory **eg-03-ruby-auth-code-grant**
1. **cd eg-03-ruby-auth-code-grant**
1. Install the needed gems listed in the Gemfile:

   Run **bundler install**
1. Update the file **config/application.rb**
     with the Integration Key and other settings.
     Note: The terms "client_id" and "Integration key" are synonyms. They refer to the same thing.

1. Update your Integration Key's settings to include a **Redirect URI** for
   your installation of the example. See Prerequisites item #2, above for more information.

#### Run the application
1. To start the development web server and application:

   Run **rails s** 
1. Open a browser to the example's base url to view the index page.

#### Payments code example
To use the payments example, create a
test payments gateway for your developer sandbox account.

See the
[PAYMENTS_INSTALLATION.md](https://github.com/docusign/eg-03-ruby-auth-code-grant/blob/master/PAYMENTS_INSTALLATION.md)
file for instructions.

Then add the payment gateway account id to the **config/application.rb** file.

## Using the examples with other authentication flows

The examples in this repository can also be used with the
JWT OAuth flow.
See the [Authentication guide](https://developers.docusign.com/esign-rest-api/guides/authentication)
for information on choosing the right authentication flow for your application.

## License and additional information

### License
This repository uses the MIT License. See the LICENSE file for more information.

### Pull Requests
Pull requests are welcomed. Pull requests will only be considered if their content
uses the MIT License.
