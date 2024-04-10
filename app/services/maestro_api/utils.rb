# frozen_string_literal: true

require 'securerandom'

class MaestroApi::Utils
  def create_workflow(args)
    signer_id = SecureRandom.uuid
    cc_id = SecureRandom.uuid
    trigger_id = 'wfTrigger'

    participants = {
      signer_id => {
        'participantRole' => 'Signer'
      },
      cc_id => {
        'participantRole' => 'CC'
      }
    }

    dac_id_field = "dacId_#{trigger_id}"
    id_field = "id_#{trigger_id}"
    signer_name_field = "signerName_#{trigger_id}"
    signer_email_field = "signerEmail_#{trigger_id}"
    cc_name_field = "ccName_#{trigger_id}"
    cc_email_field = "ccEmail_#{trigger_id}"

    trigger = DocuSign_Maestro::DSWorkflowTrigger.new({
                                                        name: 'Get_URL',
                                                        type: 'Http',
                                                        httpType: 'Get',
                                                        id: trigger_id,
                                                        input: {
                                                          metadata: {
                                                            customAttributes: {}
                                                          },
                                                          payload: {
                                                            "#{dac_id_field}": {
                                                              source: 'step',
                                                              propertyName: 'dacId',
                                                              stepId: trigger_id
                                                            },
                                                            "#{id_field}": {
                                                              source: 'step',
                                                              propertyName: 'id',
                                                              stepId: trigger_id
                                                            },
                                                            "#{signer_name_field}": {
                                                              source: 'step',
                                                              propertyName: 'signerName',
                                                              stepId: trigger_id
                                                            },
                                                            "#{signer_email_field}": {
                                                              source: 'step',
                                                              propertyName: 'signerEmail',
                                                              stepId: trigger_id
                                                            },
                                                            "#{cc_name_field}": {
                                                              source: 'step',
                                                              propertyName: 'ccName',
                                                              stepId: trigger_id
                                                            },
                                                            "#{cc_email_field}": {
                                                              source: 'step',
                                                              propertyName: 'ccEmail',
                                                              stepId: trigger_id
                                                            }
                                                          },
                                                          participants: {}
                                                        },
                                                        output: {
                                                          "#{dac_id_field}": {
                                                            source: 'step',
                                                            propertyName: 'dacId',
                                                            stepId: trigger_id
                                                          }
                                                        }
                                                      })

    variables = {
      "#{dac_id_field}": DocuSign_Maestro::DSWorkflowVariableFromVariable.new({
                                                                                source: 'step',
                                                                                propertyName: 'dacId',
                                                                                stepId: trigger_id
                                                                              }),
      "#{id_field}": DocuSign_Maestro::DSWorkflowVariableFromVariable.new({
                                                                            source: 'step',
                                                                            propertyName: 'id',
                                                                            stepId: trigger_id
                                                                          }),
      "#{signer_name_field}": DocuSign_Maestro::DSWorkflowVariableFromVariable.new({
                                                                                     source: 'step',
                                                                                     propertyName: 'signerName',
                                                                                     stepId: trigger_id
                                                                                   }),
      "#{signer_email_field}": DocuSign_Maestro::DSWorkflowVariableFromVariable.new({
                                                                                      source: 'step',
                                                                                      propertyName: 'signerEmail',
                                                                                      stepId: trigger_id
                                                                                    }),
      "#{cc_name_field}": DocuSign_Maestro::DSWorkflowVariableFromVariable.new({
                                                                                 source: 'step',
                                                                                 propertyName: 'ccName',
                                                                                 stepId: trigger_id
                                                                               }),
      "#{cc_email_field}": DocuSign_Maestro::DSWorkflowVariableFromVariable.new({
                                                                                  source: 'step',
                                                                                  propertyName: 'ccEmail',
                                                                                  stepId: trigger_id
                                                                                }),
      'envelopeId_step2': {
        'source': 'step',
        'propertyName': 'envelopeId',
        'stepId': 'step2',
        'type': 'String'
      },
      'combinedDocumentsBase64_step2': {
        'source': 'step',
        'propertyName': 'combinedDocumentsBase64',
        'stepId': 'step2',
        'type': 'File'
      },
      'fields.signer.text.value_step2': {
        'source': 'step',
        'propertyName': 'fields.signer.text.value',
        'stepId': 'step2',
        'type': 'String'
      }
    }

    step1 = {
      'id': 'step1',
      'name': 'Set Up Invite',
      'moduleName': 'Notification-SendEmail',
      'configurationProgress': 'Completed',
      'type': 'DS-EmailNotification',
      'config': {
        'templateType': 'WorkflowParticipantNotification',
        'templateVersion': 1,
        'language': 'en',
        'sender_name': 'DocuSign Orchestration',
        'sender_alias': 'Orchestration',
        'participantId': signer_id
      },
      'input': {
        'recipients': [
          {
            'name': {
              'source': 'step',
              'propertyName': 'signerName',
              'stepId': trigger_id
            },
            'email': {
              'source': 'step',
              'propertyName': 'signerEmail',
              'stepId': trigger_id
            }
          }
        ],
        'mergeValues': {
          'CustomMessage': 'Follow this link to access and complete the workflow.',
          'ParticipantFullName': {
            'source': 'step',
            'propertyName': 'signerName',
            'stepId': trigger_id
          }
        }
      },
      'output': {}
    }

    step2 = {
      "id": 'step2',
      "name": 'Get Signatures',
      "moduleName": 'ESign',
      "configurationProgress": 'Completed',
      "type": 'DS-Sign',
      "config": {
        "participantId": signer_id
      },
      "input": {
        "isEmbeddedSign": true,
        "documents": [
          {
            "type": 'FromDSTemplate',
            "eSignTemplateId": args[:template_id]
          }
        ],
        "emailSubject": 'Please sign this document',
        "emailBlurb": '',
        "recipients": {
          "signers": [
            {
              "defaultRecipient": 'false',
              "tabs": {
                "signHereTabs": [
                  {
                    "stampType": 'signature',
                    "name": 'SignHere',
                    "tabLabel": 'Sign Here',
                    "scaleValue": '1',
                    "optional": 'false',
                    "documentId": '1',
                    "recipientId": '1',
                    "pageNumber": '1',
                    "xPosition": '191',
                    "yPosition": '148',
                    "tabId": '1',
                    "tabType": 'signhere'
                  }
                ],
                'textTabs': [
                  {
                    "requireAll": 'false',
                    "value": '',
                    "required": 'false',
                    "locked": 'false',
                    "concealValueOnDocument": 'false',
                    "disableAutoSize": 'false',
                    "tabLabel": 'text',
                    "font": 'helvetica',
                    "fontSize": 'size14',
                    "localePolicy": {},
                    "documentId": '1',
                    "recipientId": '1',
                    "pageNumber": '1',
                    "xPosition": '153',
                    "yPosition": '230',
                    "width": '84',
                    "height": '23',
                    "tabId": '2',
                    "tabType": 'text'
                  }
                ],
                "checkboxTabs": [
                  {
                    "name": '',
                    "tabLabel": 'ckAuthorization',
                    "selected": 'false',
                    "selectedOriginal": 'false',
                    "requireInitialOnSharedChange": 'false',
                    "required": 'true',
                    "locked": 'false',
                    "documentId": '1',
                    "recipientId": '1',
                    "pageNumber": '1',
                    "xPosition": '75',
                    "yPosition": '417',
                    "width": '0',
                    "height": '0',
                    "tabId": '3',
                    "tabType": 'checkbox'
                  },
                  {
                    "name": '',
                    "tabLabel": 'ckAuthentication',
                    "selected": 'false',
                    "selectedOriginal": 'false',
                    "requireInitialOnSharedChange": 'false',
                    "required": 'true',
                    "locked": 'false',
                    "documentId": '1',
                    "recipientId": '1',
                    "pageNumber": '1',
                    "xPosition": '75',
                    "yPosition": '447',
                    "width": '0',
                    "height": '0',
                    "tabId": '4',
                    "tabType": 'checkbox'
                  },
                  {
                    "name": '',
                    "tabLabel": 'ckAgreement',
                    "selected": 'false',
                    "selectedOriginal": 'false',
                    "requireInitialOnSharedChange": 'false',
                    "required": 'true',
                    "locked": 'false',
                    "documentId": '1',
                    "recipientId": '1',
                    "pageNumber": '1',
                    "xPosition": '75',
                    "yPosition": '478',
                    "width": '0',
                    "height": '0',
                    "tabId": '5',
                    "tabType": 'checkbox'
                  },
                  {
                    "name": '',
                    "tabLabel": 'ckAcknowledgement',
                    "selected": 'false',
                    "selectedOriginal": 'false',
                    "requireInitialOnSharedChange": 'false',
                    "required": 'true',
                    "locked": 'false',
                    "documentId": '1',
                    "recipientId": '1',
                    "pageNumber": '1',
                    "xPosition": '75',
                    "yPosition": '508',
                    "width": '0',
                    "height": '0',
                    "tabId": '6',
                    "tabType": 'checkbox'
                  }
                ],
                "radioGroupTabs": [
                  {
                    "documentId": '1',
                    "recipientId": '1',
                    "groupName": 'radio1',
                    "radios": [
                      {
                        "pageNumber": '1',
                        "xPosition": '142',
                        "yPosition": '384',
                        "value": 'white',
                        "selected": 'false',
                        "tabId": '7',
                        "required": 'false',
                        "locked": 'false',
                        "bold": 'false',
                        "italic": 'false',
                        "underline": 'false',
                        "fontColor": 'black',
                        "fontSize": 'size7'
                      },
                      {
                        "pageNumber": '1',
                        "xPosition": '74',
                        "yPosition": '384',
                        "value": 'red',
                        "selected": 'false',
                        "tabId": '8',
                        "required": 'false',
                        "locked": 'false',
                        "bold": 'false',
                        "italic": 'false',
                        "underline": 'false',
                        "fontColor": 'black',
                        "fontSize": 'size7'
                      },
                      {
                        "pageNumber": '1',
                        "xPosition": '220',
                        "yPosition": '384',
                        "value": 'blue',
                        "selected": 'false',
                        "tabId": '9',
                        "required": 'false',
                        "locked": 'false',
                        "bold": 'false',
                        "italic": 'false',
                        "underline": 'false',
                        "fontColor": 'black',
                        "fontSize": 'size7'
                      }
                    ],
                    "shared": 'false',
                    "requireInitialOnSharedChange": 'false',
                    "requireAll": 'false',
                    "tabType": 'radiogroup',
                    "value": '',
                    "originalValue": ''
                  }
                ],
                "listTabs": [
                  {
                    "listItems": [
                      {
                        "text": 'Red',
                        "value": 'red',
                        "selected": 'false'
                      },
                      {
                        "text": 'Orange',
                        "value": 'orange',
                        "selected": 'false'
                      },
                      {
                        "text": 'Yellow',
                        "value": 'yellow',
                        "selected": 'false'
                      },
                      {
                        "text": 'Green',
                        "value": 'green',
                        "selected": 'false'
                      },
                      {
                        "text": 'Blue',
                        "value": 'blue',
                        "selected": 'false'
                      },
                      {
                        "text": 'Indigo',
                        "value": 'indigo',
                        "selected": 'false'
                      },
                      {
                        "text": 'Violet',
                        "value": 'violet',
                        "selected": 'false'
                      }
                    ],
                    "value": '',
                    "originalValue": '',
                    "required": 'false',
                    "locked": 'false',
                    "requireAll": 'false',
                    "tabLabel": 'list',
                    "font": 'helvetica',
                    "fontSize": 'size14',
                    "localePolicy": {},
                    "documentId": '1',
                    "recipientId": '1',
                    "pageNumber": '1',
                    "xPosition": '142',
                    "yPosition": '291',
                    "width": '78',
                    "height": '0',
                    "tabId": '10',
                    "tabType": 'list'
                  }
                ],
                "numericalTabs": [
                  {
                    "validationType": 'currency',
                    "value": '',
                    "required": 'false',
                    "locked": 'false',
                    "concealValueOnDocument": 'false',
                    "disableAutoSize": 'false',
                    "tabLabel": 'numericalCurrency',
                    "font": 'helvetica',
                    "fontSize": 'size14',
                    "localePolicy": {
                      "cultureName": 'en-US',
                      "currencyPositiveFormat":
                                    'csym_1_comma_234_comma_567_period_89',
                      "currencyNegativeFormat":
                                    'opar_csym_1_comma_234_comma_567_period_89_cpar',
                      "currencyCode": 'usd'
                    },
                    "documentId": '1',
                    "recipientId": '1',
                    "pageNumber": '1',
                    "xPosition": '163',
                    "yPosition": '260',
                    "width": '84',
                    "height": '0',
                    "tabId": '11',
                    "tabType": 'numerical'
                  }
                ]
              },
              "signInEachLocation": 'false',
              "agentCanEditEmail": 'false',
              "agentCanEditName": 'false',
              "requireUploadSignature": 'false',
              "name": {
                "source": 'step',
                "propertyName": 'signerName',
                "stepId": trigger_id
              },
              "email": {
                "source": 'step',
                "propertyName": 'signerEmail',
                "stepId": trigger_id
              },
              "recipientId": '1',
              "recipientIdGuid": '00000000-0000-0000-0000-000000000000',
              "accessCode": '',
              "requireIdLookup": 'false',
              "routingOrder": '1',
              "note": '',
              "roleName": 'signer',
              "completedCount": '0',
              "deliveryMethod": 'email',
              "templateLocked": 'false',
              "templateRequired": 'false',
              "inheritEmailNotificationConfiguration": 'false',
              "recipientType": 'signer'
            }
          ],
          "carbonCopies": [
            {
              "agentCanEditEmail": 'false',
              "agentCanEditName": 'false',
              "name": {
                "source": 'step',
                "propertyName": 'ccName',
                "stepId": trigger_id
              },
              "email": {
                "source": 'step',
                "propertyName": 'ccEmail',
                "stepId": trigger_id
              },
              "recipientId": '2',
              "recipientIdGuid": '00000000-0000-0000-0000-000000000000',
              "accessCode": '',
              "requireIdLookup": 'false',
              "routingOrder": '2',
              "note": '',
              "roleName": 'cc',
              "completedCount": '0',
              "deliveryMethod": 'email',
              "templateLocked": 'false',
              "templateRequired": 'false',
              "inheritEmailNotificationConfiguration": 'false',
              "recipientType": 'carboncopy'
            }
          ],
          "certifiedDeliveries": []
        }
      },
      "output": {
        "envelopeId_step2": {
          "source": 'step',
          "propertyName": 'envelopeId',
          "stepId": 'step2',
          "type": 'String'
        },
        "combinedDocumentsBase64_step2": {
          "source": 'step',
          "propertyName": 'combinedDocumentsBase64',
          "stepId": 'step2',
          "type": 'File'
        },
        'fields.signer.text.value_step2': {
          "source": 'step',
          "propertyName": 'fields.signer.text.value',
          "stepId": 'step2',
          "type": 'String'
        }
      }
    }

    step3 = {
      "id": 'step3',
      "name": 'Show a Confirmation Screen',
      "moduleName": 'ShowConfirmationScreen',
      "configurationProgress": 'Completed',
      "type": 'DS-ShowScreenStep',
      "config": {
        "participantId": signer_id
      },
      "input": {
        "httpType": 'Post',
        "payload": {
          "participantId": signer_id,
          "confirmationMessage": {
            "title": 'Tasks complete',
            "description": 'You have completed all your workflow tasks.'
          }
        }
      },
      "output": {}
    }

    workflow_definition = DocuSign_Maestro::WorkflowDefinition.new({
                                                                     workflowName: 'Example workflow - send invite to signer',
                                                                     workflowDescription: '',
                                                                     documentVersion: '1.0.0',
                                                                     schemaVersion: '1.0.0',
                                                                     accountId: args[:account_id],
                                                                     participants: participants,
                                                                     trigger: trigger,
                                                                     variables: variables,
                                                                     steps: [step1, step2, step3]
                                                                   })

    configuration = DocuSign_Maestro::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Maestro::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    workflow_management_api = DocuSign_Maestro::WorkflowManagementApi.new(api_client)
    workflow_management_api.create_workflow_definition(
      args[:account_id],
      { "workflowDefinition": workflow_definition }
    ).workflow_definition_id
  end

  def publish_workflow(args, workflow_id)
    configuration = DocuSign_Maestro::Configuration.new
    configuration.host = args[:base_path]

    api_client = DocuSign_Maestro::ApiClient.new(configuration)
    api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")

    workflow_management_api = DocuSign_Maestro::WorkflowManagementApi.new(api_client)

    deploy_request = DocuSign_Maestro::DeployRequest.new({
                                                           deploymentStatus: DocuSign_Maestro::DeployStatus::PUBLISH
                                                         })
    begin
      workflow_management_api.publish_or_un_publish_workflow_definition(
        args[:account_id],
        workflow_id,
        deploy_request
      )

      # return false if workflow does not require a consent to be published
      false
    rescue Exception => e
      return raise e unless e.respond_to?(:response_body)

      response_body = JSON.parse(e.response_body)
      return raise e unless response_body.key?('responseType')

      is_consent_required = response_body['responseType'] == 'NeedConsent'
      return response_body['consentUrl'] if is_consent_required

      raise e
    end
  end
end
