source 'https://rubygems.org'

gem 'mysql2'

gem 'puma'

gem 'rack-cors'
gem 'rack-timeout'
gem 'rack-request-id'
gem 'rack-protection'
gem 'rack-ssl-enforcer'
gem 'rack-attack'
gem 'rack-console'

gem 'request_store'

gem 'grape'
gem 'grape-entity'
gem 'grape_logging'

gem 'activerecord'

gem 'figaro'

gem 'jwt'
gem 'bcrypt'

gem 'stripe'
gem 'stripe_event'
gem 'statesman'

gem 'mail'

gem 'analytics-ruby', '~> 2.0.0', :require => 'segment/analytics'

gem 'redis'

gem 'kaminari-core'
gem 'kaminari-activerecord'

group :development do
  gem 'rake'
end

group :development, :test do
  gem 'pry'
  gem 'bundler-audit', require: false
  gem 'rubycritic', :require => false
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'json-schema'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'stripe-ruby-mock', '~> 2.3.1', :require => 'stripe_mock'
end
