require 'active_record'
require 'jwt'

module DefaultErrorHandlers

  def self.included(base)
    base.rescue_from Errors::BadRequest do |e|
      Grape::API.logger.error e
      error!({ message: 'Invalid request.', debug_info: e.message, request_id: headers['x-request-id']}, 400)
    end

    base.rescue_from Errors::Unauthorized do |e|
      Grape::API.logger.error e
      error!({ message: 'Unauthorized. Missing or invalid credentials.', debug_info: e.message, request_id: headers['x-request-id']}, 401)
    end

    base.rescue_from Errors::RequestFailed do |e|
      Grape::API.logger.error e
      error!({ message: 'Parameters were valid but request failed.', debug_info: e.message, request_id: headers['x-request-id']}, 402)
    end

    base.rescue_from Errors::Forbidden do |e|
      Grape::API.logger.error e
      error!({ message: 'Forbidden. Missing or invalid permissions.', debug_info: e.message, request_id: headers['x-request-id']}, 403)
    end

    base.rescue_from Errors::NotFound do |e|
      Grape::API.logger.error e
      error!({ message: 'Not Found. The requested item doesn’t exist.', debug_info: e.message, request_id: headers['x-request-id']}, 404)
    end

    base.rescue_from Errors::UnprocessableEntity do |e|
      Grape::API.logger.error e
      error!({ message: 'Parameters were invalid/validation failed.', debug_info: e.message, request_id: headers['x-request-id']}, 422)
    end

    base.rescue_from Errors::ServerError do |e|
      Grape::API.logger.error e
      error!({ message: 'Sorry, but something has gone wrong. Please try again later or contact support.', debug_info: e.message, request_id: headers['x-request-id']}, 500)
    end

    base.rescue_from ActiveRecord::RecordNotFound do |e|
      Grape::API.logger.error e
      error!({ message: 'Not Found. The requested item doesn’t exist.', debug_info: e.message, request_id: headers['x-request-id']}, 404)
    end

    base.rescue_from ActiveRecord::RecordInvalid do |e|
      Grape::API.logger.error e
      error!({ message: 'Parameters were invalid/validation failed.', debug_info: e.message, request_id: headers['x-request-id']}, 422)
    end

    base.rescue_from Grape::Exceptions::ValidationErrors do |e|
      Grape::API.logger.error e
      error!({ message: 'Parameters were invalid/validation failed.', debug_info: e.message, request_id: headers['x-request-id']}, 422)
    end

    base.rescue_from JWT::ExpiredSignature do |e|
      Grape::API.logger.error e
      error!({ message: 'Unauthorized. Missing or invalid credentials.', debug_info: e.message, request_id: headers['x-request-id']}, 401)
    end

    base.rescue_from :all do |e|
      Grape::API.logger.error e
      error!({ message: 'Sorry, but something has gone wrong. Please try again later or contact support.', debug_info: e.message, request_id: headers['x-request-id']}, 500)
    end

  end

end
