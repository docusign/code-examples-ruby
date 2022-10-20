class AdminApi::Eg009DeleteUserProductPermissionProfileController < EgController
  before_action :check_auth
  before_action -> { @example = Utils::ManifestUtils.new.get_example(@manifest, 9) }

  def create
    clm_email = session[:clm_email]
    get_data_service = AdminApi::GetDataService.new(session)

    unless clm_email && get_data_service.check_user_exists_by_email(clm_email)
      @email_ok = false
      return
    end

    begin
      args = {
        email: clm_email,
        product_id: params[:product_id],
        account_id: session[:ds_account_id],
        organization_id: session['organization_id'],
        access_token: session[:ds_access_token]
      }

      results = AdminApi::Eg009DeleteUserProductPermissionProfileService.new(args).worker

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

    args = {
      email: clm_email,
      account_id: session[:ds_account_id],
      organization_id: session['organization_id'],
      access_token: session[:ds_access_token]
    }

    product_permission_profiles = AdminApi::Eg009DeleteUserProductPermissionProfileService.new(args).get_permission_profiles_by_email
    permission_profile_list = []
    clm_product_id = nil
    clm_permission_profile_name = nil
    esign_product_id = nil
    esign_permission_profile_name = nil

    product_permission_profiles.each do |product_permission_profile|
      permission_profiles = product_permission_profile['permission_profiles']
      permission_profiles.each do |permission_profile|
        if product_permission_profile['product_name'] == 'CLM'
          clm_permission_profile_name = permission_profile['permission_profile_name']
          clm_product_id = product_permission_profile['product_id']
        else
          esign_permission_profile_name = permission_profile['permission_profile_name']
          esign_product_id = product_permission_profile['product_id']
        end
      end
    end

    permission_profile_list.push({ 'product_id' => clm_product_id, 'permission_name' => "CLM - #{clm_permission_profile_name}" }) if clm_product_id

    permission_profile_list.push({ 'product_id' => esign_product_id, 'permission_name' => "eSignature - #{esign_permission_profile_name}" }) if esign_product_id

    @permission_profile_list = permission_profile_list
    @email_ok = true
    @email = clm_email
  end
end
