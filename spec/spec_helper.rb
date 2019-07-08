$:.push(File.join(File.dirname(__FILE__), 'api/'))
$:.push(File.join(File.dirname(__FILE__), 'app/'))
$:.push(File.join(File.dirname(__FILE__), 'lib/'))
$:.push(File.join(File.dirname(__FILE__)))

ENV['RACK_ENV'] = 'test'

require './config/environment'

require 'grape'
require 'rack/test'
require 'active_record'
require 'database_cleaner'
require 'json-schema'
require 'shoulda/matchers'
require 'stripe_mock'
require 'mail'
require 'statesman'

require 'support/api_helpers'
require 'support/stripe_helpers'
require 'support/api_matchers'

ActiveSupport.on_load(:active_record) do
  env = 'test'
  db_config = YAML.load(ERB.new(File.read("db/config.yml")).result)[env]
  ActiveRecord::Base.default_timezone = :utc
  ActiveRecord::Base.establish_connection(db_config)
end

Mail.defaults do
  delivery_method :test
end

Statesman.configure do
  storage_adapter(Statesman::Adapters::ActiveRecord)
end

RSpec.configure do |c|
  c.include Rack::Test::Methods
  c.include Shoulda::Matchers::ActiveRecord, type: :model
  c.include ApiHelpers
  c.include StripeHelpers

  c.mock_with :rspec
  c.expect_with :rspec
  c.raise_errors_for_deprecations!

  c.order = :random
  # c.warnings = true

  c.before(:each) do
    StripeMock.start
    stripe_helper.create_plan(:id => 'pro', :amount => 100)
    stripe_helper.create_plan(:id => 'enterprise', :amount => 200)
  end

  c.after(:each) do
    StripeMock.stop
  end

  c.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  c.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  c.after(:all) do
    connected = ActiveRecord::Base.connection_pool.with_connection { |con| con.active? }  rescue false
    ActiveRecord::Base.connection_pool.disconnect! if connected
  end

end

Shoulda::Matchers.configure do |c|
  c.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
  end
end