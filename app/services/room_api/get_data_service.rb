# frozen_string_literal: true

class RoomApi::GetDataService
  attr_reader :args

  def initialize(session, options = {})
    @args = {
      account_id: session[:ds_account_id],
      base_path: session[:ds_base_path],
      access_token: session[:ds_access_token],
      room_id: options
    }
  end

  def get_offices
    worker

    #ds-snippet-start:Rooms8Step3
    offices_api = DocuSign_Rooms::OfficesApi.new(@api_client)
    offices, _status, headers = offices_api.get_offices_with_http_info(args[:account_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    offices.as_json['officeSummaries']
    #ds-snippet-end:Rooms8Step3
  end

  def get_default_admin_role_id
    worker

    roles_api = DocuSign_Rooms::RolesApi.new(@api_client)
    roles, _status, headers = roles_api.get_roles_with_http_info(args[:account_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    default_admin_role = roles.as_json['roles'].find { |role| role['name'] == 'Default Admin' }
    default_admin_role['roleId']
  end

  def get_rooms
    worker

    rooms_api = DocuSign_Rooms::RoomsApi.new(@api_client)
    rooms, _status, headers = rooms_api.get_rooms_with_http_info(args[:account_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    rooms.as_json['rooms']
  end

  def get_templates
    worker

    templates_api = DocuSign_Rooms::RoomTemplatesApi.new(@api_client)
    templates, _status, headers = templates_api.get_room_templates_with_http_info(args[:account_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    templates.as_json['roomTemplates']
  end

  def get_form_libraries
    worker

    form_libraries_api = DocuSign_Rooms::FormLibrariesApi.new(@api_client)
    begin
      form_libraries, _status, headers = form_libraries_api.get_form_libraries_with_http_info(args[:account_id])

      remaining = headers['X-RateLimit-Remaining']
      reset = headers['X-RateLimit-Reset']

      if remaining && reset
        reset_date = Time.at(reset.to_i).utc
        puts "API calls remaining: #{remaining}"
        puts "Next Reset: #{reset_date}"
      end
    rescue Exception
      return
    end

    form_libraries_id = form_libraries.as_json['formsLibrarySummaries'].find { |lib| lib['formCount'].positive? }['formsLibraryId']

    forms_api = DocuSign_Rooms::FormLibrariesApi.new(@api_client)
    forms, _status, headers = forms_api.get_form_library_forms_with_http_info(form_libraries_id, args[:account_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    forms.as_json['forms']
  end

  def get_forms_from_room
    worker

    room_forms_api = DocuSign_Rooms::RoomsApi.new(@api_client)
    forms, _status, headers = room_forms_api.get_documents_with_http_info(args[:room_id], args[:account_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    forms.as_json['documents']
  end

  def get_form_groups
    worker

    #ds-snippet-start:Rooms8Step4
    form_groups_api = DocuSign_Rooms::FormGroupsApi.new(@api_client)
    form_groups, _status, headers = form_groups_api.get_form_groups_with_http_info(args[:account_id])

    remaining = headers['X-RateLimit-Remaining']
    reset = headers['X-RateLimit-Reset']

    if remaining && reset
      reset_date = Time.at(reset.to_i).utc
      puts "API calls remaining: #{remaining}"
      puts "Next Reset: #{reset_date}"
    end

    form_groups.as_json['formGroups']
    #ds-snippet-end:Rooms8Step4
  end

  private

  def worker
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = 'https://demo.rooms.docusign.com/restapi'
    @api_client = DocuSign_Rooms::ApiClient.new(configuration)
    @api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
  end
end
