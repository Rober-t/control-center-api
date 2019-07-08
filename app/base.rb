require 'grape'
require 'grape-entity'
require 'kaminari/core'
require './lib/default_error_handlers'
require './lib/pretty_json'
require './lib/middleware_auth'
require './lib/errors'
require './app/models/organisation_manager/user'

Grape::Middleware::Auth::Strategies.add(:core_api_auth, MiddlewareAuth, ->(options) { [options[:realm]] } )

module App
  module DefaultErrorFormatter
    def self.call(message, backtrace, options, env, other=nil)
      { error: { message: message[:error] } }.to_json
    end
  end

  module Base
    def self.included(base)
      base.version '20170101', using: :header, vendor: 'control_center_api', cascade: false
      base.format :json
      base.default_format :json
      base.formatter :json, PrettyJSON

      base.include DefaultErrorHandlers
      base.error_formatter :json, DefaultErrorFormatter

      base.auth :core_api_auth, realm: 'CoreAPI' do |authorization_header|
        user = ::OrganisationManager::User.find_by_token(authorization_header)
        { user: user }
      end

      base.helpers do
        attr_accessor :current_user
        attr_accessor :current_organisation
      end

      base.helpers do
        def declared_params
          declared(params, include_missing: false)
        end
      end
      
    end
  end
end
