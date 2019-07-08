$:.push(File.dirname(__FILE__))

require './config/environment'
require './app/auth_manager'
require './app/organisation_manager'
require './app/support_manager'
require './app/billing_manager'
require './app/data_manager'
require './app/status'

require 'rack/cors'
require 'rack-timeout'
require 'request_store'
require 'rack-request-id'
require 'rack/protection'
require 'grape_logging'
require 'rack/ssl-enforcer'

require 'boot'
Bundler.require :default, ENV['RACK_ENV']

use Rack::SslEnforcer, :except_environments => ['development', 'test']
use Rack::Timeout, service_timeout: 15
use Rack::Attack
use Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: :any,
      expose: ['ETag', 'X-RateLimit-Limit', 'X-RateLimit-Remaining', 'X-RateLimit-Reset', 'X-Request-Id', 'X-Total-Count'],
      methods: [:get, :post, :options, :patch, :put, :delete]
  end
end
use RequestStore::Middleware
use Rack::RequestId, storage: RequestStore
use Rack::Protection, :except => [:session_hijacking, :remote_token], origin_whitelist: ["http://localhost:3000"]

Grape::API.logger.formatter = GrapeLogging::Formatters::Default.new
use GrapeLogging::Middleware::RequestLogger,
  logger: Grape::API.logger,
  include: [ GrapeLogging::Loggers::Response.new,
             GrapeLogging::Loggers::FilterParameters.new([:password, :token, :credit_card]),
             GrapeLogging::Loggers::ClientEnv.new,
             GrapeLogging::Loggers::RequestHeaders.new ]

initializers_path = File.join(File.dirname(__FILE__), './config/initializers')
Dir["#{initializers_path}/**/*.rb"].each {|file| require file }

run Rack::Cascade.new([App::AuthManager, App::OrganisationManager, App::SupportManager, App::BillingManager, App::DataManager, App::Status])
