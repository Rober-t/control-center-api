module ServiceHelpers

  def service(service_name, params, api_name)
    require "./services/#{api_name}_services/#{service_name}"

    api_path = "#{api_name.to_s.split('_').collect(&:capitalize).join}Services"

    service_path = "#{service_name.to_s.split('_').collect(&:capitalize).join}Service"

    class_name = "#{api_path}::#{service_path}"

    Kernel.const_get(class_name).new(params, current_organisation, current_user).run
  end

  def sanatized_params(*keys)
    params.slice(*keys)
  end

end
