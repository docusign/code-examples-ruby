# frozen_string_literal: true

class Eg008CreateTemplateController < EgController
  def create
    minimum_buffer_min = 3
    token_ok = check_token(minimum_buffer_min)

    if token_ok
      begin
        results = ::Eg008Service.new(session).call
        msg = if results.fetch(:created_new_template)
                'The template has been created!'
              else
                'Done. The template already existed in your account.'
              end
        @title = 'Template results'
        @h1 = 'Template results'
        @message = "#{msg}<br/>Template name: #{results[:template_name]},
                        ID #{results[:template_id]}."
        render 'ds_common/example_done'
      rescue  DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render 'ds_common/error'
      end
    end
  end
end
