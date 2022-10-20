# frozen_string_literal: true

class ESign::Eg014CollectPaymentService
  attr_reader :args

  include ApiCreator

  def initialize(args)
    @args = args
  end

  # ***DS.snippet.0.start
  def worker
    envelope_definition = make_envelope(args[:envelope_args])
    # 2. Create and send the envelope
    # Exceptions will be caught by the calling function
    envelope_api = create_envelope_api(args)
    results = envelope_api.create_envelope args[:account_id], envelope_definition
    envelope_id = results.envelope_id
    { envelope_id: envelope_id }
  end

  private

  def make_envelope(args)
    # This function creates the envelope definition for the order form
    # document 1 (html) has multiple tags:
    # /l1q/ and /l2q/ -- quantities: drop down
    # /l1e/ and /l2e/ -- extended: payment lines
    # /l3t/ -- total -- formula
    #
    # The envelope has two recipients:
    # recipient 1 - signer
    # recipient 2 - cc
    # The envelope will be sent first to the signer
    # After it is signed, a copy is sent to the cc person
    #
    #    #################################################################
    #    #
    #    # NOTA BENE: This method programmatically constructs the
    #    #            order form. For many use cases, it would be
    #    #            better to create the order form as a template
    #    #            using the DocuSign web tool as WYSIWYG
    #    #            form designer.
    #    #
    #    #################################################################
    #

    # Order form constants
    l1_name = 'Harmonica'
    l1_price = 5
    l1_description = "#{l1_price} each"
    l2_name = 'Xylophone'
    l2_price = 150
    l2_description = "#{l2_price} each"
    currency_multiplier = 100

    # Read the HTML file from a local directory
    # The read could raise an exception if the file is not available!
    doc1_file = 'order_form.html'
    doc1_html_v1 = File.binread(File.join('data', doc1_file))
    # Substitute values into the HTML
    # Substitute for: {signerName}, {signerEmail}, {ccName}, {ccEmail}
    doc1_html_v2 = doc1_html_v1.gsub('{signerName}', args[:signer_name]) \
                               .gsub('{signerEmail}', args[:signer_email]) \
                               .gsub('{ccName}', args[:cc_name]) \
                               .gsub('{ccEmail}', args[:cc_email])

    # Create the envelope definition
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new(
      emailSubject: 'Please complete your order',
      status: 'sent'
    )

    # Add the document
    doc1_b64 = Base64.encode64(doc1_html_v2)
    doc1 = DocuSign_eSign::Document.new(
      documentBase64: doc1_b64,
      name: 'Order form', # Can be different from actual file name
      fileExtension: 'html', # Source data format
      documentId: '1' # A label used to reference the doc
    )
    envelope_definition.documents = [doc1]

    # Create a signer recipient to sign the document
    signer1 = DocuSign_eSign::Signer.new(
      email: args[:signer_email], name: args[:signer_name],
      recipientId: '1', routingOrder: '1'
    )
    # Create a cc recipient to receive a copy of the documents
    cc1 = DocuSign_eSign::CarbonCopy.new(
      email: args[:cc_email], name: args[:cc_name],
      routingOrder: '2', recipientId: '2'
    )

    # Create signHere fields (also known as tabs) on the documents,
    # We're using anchor (autoPlace) positioning
    sign_here1 = DocuSign_eSign::SignHere.new(
      anchorString: '/sn1/', anchorUnits: 'pixels',
      anchorYOffset: '10', anchorXOffset: '20'
    )
    list_item0 = DocuSign_eSign::ListItem.new(text: 'none', value: '0')
    list_item1 = DocuSign_eSign::ListItem.new(text: '1', value: '1')
    list_item2 = DocuSign_eSign::ListItem.new(text: '2', value: '2')
    list_item3 = DocuSign_eSign::ListItem.new(text: '3', value: '3')
    list_item4 = DocuSign_eSign::ListItem.new(text: '4', value: '4')
    list_item5 = DocuSign_eSign::ListItem.new(text: '5', value: '5')
    list_item6 = DocuSign_eSign::ListItem.new(text: '6', value: '6')
    list_item7 = DocuSign_eSign::ListItem.new(text: '7', value: '7')
    list_item8 = DocuSign_eSign::ListItem.new(text: '8', value: '8')
    list_item9 = DocuSign_eSign::ListItem.new(text: '9', value: '9')
    list_item10 = DocuSign_eSign::ListItem.new(text: '10', value: '10')

    listl1q = DocuSign_eSign::List.new(
      font: 'helvetica', fontSize: 'size11',
      anchorString: '/l1q/', anchorUnits: 'pixels',
      anchorYOffset: '-10', anchorXOffset: '0',
      listItems: [list_item0, list_item1, list_item2,
                  list_item3, list_item4, list_item5, list_item6,
                  list_item7, list_item8, list_item9, list_item10],
      required: 'true', tabLabel: 'l1q'
    )
    listl2q = DocuSign_eSign::List.new(
      font: 'helvetica', fontSize: 'size11',
      anchorString: '/l2q/', anchorUnits: 'pixels',
      anchorYOffset: '-10', anchorXOffset: '0',
      listItems: [list_item0, list_item1, list_item2,
                  list_item3, list_item4, list_item5, list_item6,
                  list_item7, list_item8, list_item9, list_item10],
      required: 'true', tabLabel: 'l2q'
    )

    # Create two formula tabs for the extended price on the line items
    formulal1e = DocuSign_eSign::FormulaTab.new(
      font: 'helvetica', fontSize: 'size11',
      anchorString: '/l1e/', anchorUnits: 'pixels',
      anchorYOffset: '-8', anchorXOffset: '105',
      tabLabel: 'l1e', formula: "[l1q] * #{l1_price}",
      roundDecimalPlaces: '0', required: 'true',
      locked: 'true', disableAutoSize: 'false'
    )
    formulal2e = DocuSign_eSign::FormulaTab.new(
      font: 'helvetica', fontSize: 'size11',
      anchorString: '/l2e/', anchorUnits: 'pixels',
      anchorYOffset: '-8', anchorXOffset: '105',
      tabLabel: 'l2e', formula: "[l2q] * #{l2_price}",
      roundDecimalPlaces: '0', required: 'true',
      locked: 'true', disableAutoSize: 'false'
    )

    # Formula for the total
    formulal3t = DocuSign_eSign::FormulaTab.new(
      font: 'helvetica', fontSize: 'size11',
      anchorString: '/l3t/', anchorUnits: 'pixels',
      anchorYOffset: '-8', anchorXOffset: '50',
      tabLabel: 'l3t', formula: '[l1e] + [l2e]',
      roundDecimalPlaces: '0', required: 'true',
      locked: 'true', disableAutoSize: 'false'
    )

    # Payment line items
    payment_line_iteml1 = DocuSign_eSign::PaymentLineItem.new(
      name: l1_name, description: l1_description,
      amountReference: 'l1e'
    )
    payment_line_iteml2 = DocuSign_eSign::PaymentLineItem.new(
      name: l2_name, description: l2_description,
      amountReference: 'l2e'
    )
    payment_details = DocuSign_eSign::PaymentDetails.new(
      gatewayAccountId: args[:gateway_account_id],
      currencyCode: 'USD',
      gatewayName: args[:gateway_name],
      lineItems: [payment_line_iteml1, payment_line_iteml2]
    )
    # Hidden formula for the payment itself
    formula_payment = DocuSign_eSign::FormulaTab.new(
      tabLabel: 'payment',
      formula: "([l1e] + [l2e]) * #{currency_multiplier}",
      roundDecimalPlaces: '0',
      paymentDetails: payment_details,
      hidden: 'true', required: 'true', locked: 'true',
      documentId: '1', pageNumber: '1',
      xPosition: '0', yPosition: '0'
    )

    # Tabs are set per recipient / signer
    signer1_tabs = DocuSign_eSign::Tabs.new(
      signHereTabs: [sign_here1],
      listTabs: [listl1q, listl2q],
      formulaTabs: [formulal1e, formulal2e,
                    formulal3t, formula_payment]
    )
    signer1.tabs = signer1_tabs

    # Add the recipients to the envelope object
    recipients = DocuSign_eSign::Recipients.new(
      signers: [signer1], carbonCopies: [cc1]
    )
    envelope_definition.recipients = recipients
    envelope_definition
  end
  # ***DS.snippet.0.end
end
