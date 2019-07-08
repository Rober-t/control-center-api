$:.push(File.dirname(__FILE__))

require './config/environment'

app = File.join(File.dirname(__FILE__), 'app/')

Dir["#{app}/**/*.rb"].each {|file| require file }

ActiveSupport.on_load(:active_record) do
  env = ENV['RACK_ENV'] || 'development'
  db_config = YAML.load(ERB.new(File.read("db/config.yml")).result)[env]
  db_config['pool'] = Figaro.env.puma_max_threads || 5
  ActiveRecord::Base.default_timezone = :utc
  ActiveRecord::Base.establish_connection(db_config)
end