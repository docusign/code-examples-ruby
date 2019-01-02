class EgController < ApplicationController
  def get
    @messages = ""

    #to have the user authenticate or re-authenticate.
    @tokenOk = check_token
    @config = Rails.application.config
    if @tokenOk
      # addSpecialAttributes(model)
      @envelope_ok = !session[:envelope_id].nil?
      @documents_ok = !session[:envelope_documents].nil?
      @document_options = session[:envelope_documents].nil?? nil: session[:envelope_documents]['documents']
      @gateway_ok = @config.gateway_account_id && @config.gateway_account_id.length > 25
      @template_ok = !session[:template_id].nil?
      @source_file = "#{get_file_name}"
      @source_url = "#{@config.github_example_url}#{@source_file}"
      @documentation = "#{@config.documentation}#{eg_name}" #= Config.documentation + EgName
      @show_doc = @config.documentation
    else
      # RequestItemsService.EgName = EgName
      redirect_to "/ds/mustAuthenticate"
    end
  end


  private

  def check_token(minBuffer = 60)
    expires_at = session[:ds_expires_at]
    if expires_at.nil?
      false
    else
      (DateTime.now.to_i + minBuffer * 60 < expires_at)
    end
  end

  def create_source_path
    # code here
  end
end
