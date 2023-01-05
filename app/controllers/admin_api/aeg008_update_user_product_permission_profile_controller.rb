class AdminApi::Aeg008UpdateUserProductPermissionProfileController < EgController
  before_action -> { check_auth('Admin') }
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 8, 'Admin') }

  def create
    clm_email = session[:clm_email]
    get_data_service = AdminApi::GetDataService.new(session)

    unless clm_email && get_data_service.check_user_exists_by_email(clm_email)
      @email_ok = false
      return
    end

    begin
      product_permission_profiles = get_data_service.get_product_permission_profiles
      product_id = params[:product_id]
      permission_profile_id = nil

      product_permission_profiles.each do |profile|
        next unless product_id == profile['product_id']

        permission_profile_id = if profile['product_name'] == 'CLM'
                                  params[:clm_permission_profile_id]
                                else
                                  params[:esign_permission_profile_id]
                                end
      end

      args = {
        email: clm_email,
        permission_profile_id: permission_profile_id,
        product_id: product_id,
        account_id: session[:ds_account_id],
        organization_id: session['organization_id'],
        base_path: session[:ds_base_path],
        access_token: session[:ds_access_token]
      }

      results = AdminApi::Eg008UpdateUserProductPermissionProfileService.new(args).worker

      @title = @example['ExampleName']
      @message = @example['ResultsPageText']
      @json = results.to_json.to_json

      render 'ds_common/example_done'
    rescue DocuSign_Admin::ApiError => e
      handle_error(e)
    end
  end

  def get
    super
    get_data_service = AdminApi::GetDataService.new(session)

    session[:organization_id] = get_data_service.get_organization_id if session[:organization_id].nil?

    clm_email = session[:clm_email]

    unless clm_email && get_data_service.check_user_exists_by_email(clm_email)
      @email_ok = false
      return
    end

    product_permission_profiles = get_data_service.get_product_permission_profiles

    product_permission_profiles.each do |product_permission_profile|
      if product_permission_profile['product_name'] == 'CLM'
        @clm_permission_profiles = product_permission_profile['permission_profiles']
        @clm_product_id = product_permission_profile['product_id']
      else
        @esign_permission_profiles = product_permission_profile['permission_profiles']
        @esign_product_id = product_permission_profile['product_id']
      end
    end
    product_list = []
    product_list.push({ 'product_id' => @clm_product_id, 'product_name' => 'CLM' })
    product_list.push({ 'product_id' => @esign_product_id, 'product_name' => 'eSignature' })
    @product_list = product_list
    @email_ok = true
    @email = clm_email
  end
end
