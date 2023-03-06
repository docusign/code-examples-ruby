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

    offices_api = DocuSign_Rooms::OfficesApi.new(@api_client)
    offices = offices_api.get_offices(args[:account_id])
    offices.as_json['officeSummaries']
  end

  def get_default_admin_role_id
    worker

    roles_api = DocuSign_Rooms::RolesApi.new(@api_client)
    roles = roles_api.get_roles(args[:account_id]).as_json['roles']
    default_admin_role = roles.find { |role| role['name'] == 'Default Admin' }
    default_admin_role['roleId']
  end

  def get_rooms
    worker

    rooms_api = DocuSign_Rooms::RoomsApi.new(@api_client)
    rooms = rooms_api.get_rooms(args[:account_id])
    rooms.as_json['rooms']
  end

  def get_templates
    worker

    templates_api = DocuSign_Rooms::RoomTemplatesApi.new(@api_client)
    templates = templates_api.get_room_templates(args[:account_id])
    templates.as_json['roomTemplates']
  end

  def get_form_libraries
    worker

    form_libraries_api = DocuSign_Rooms::FormLibrariesApi.new(@api_client)
    begin
      form_libraries = form_libraries_api.get_form_libraries(args[:account_id])
    rescue Exception
      return
    end

    form_libraries_id = form_libraries.as_json['formsLibrarySummaries'].first['formsLibraryId']

    forms_api = DocuSign_Rooms::FormLibrariesApi.new(@api_client)
    forms = forms_api.get_form_library_forms(form_libraries_id, args[:account_id])
    forms.as_json['forms']
  end

  def get_forms_from_room
    worker

    room_forms_api = DocuSign_Rooms::RoomsApi.new(@api_client)
    forms = room_forms_api.get_documents(args[:room_id], args[:account_id])
    forms.as_json['documents']
  end

  def get_form_groups
    worker

    form_groups_api = DocuSign_Rooms::FormGroupsApi.new(@api_client)
    form_groups = form_groups_api.get_form_groups(args[:account_id])
    form_groups.as_json['formGroups']
  end

  private

  def worker
    configuration = DocuSign_Rooms::Configuration.new
    configuration.host = 'https://demo.rooms.docusign.com/restapi'
    @api_client = DocuSign_Rooms::ApiClient.new(configuration)
    @api_client.set_default_header('Authorization', "Bearer #{args[:access_token]}")
  end
end
