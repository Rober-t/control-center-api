require 'erb'
require 'yaml'
require 'figaro'

workers Integer(Figaro.env.puma_web_concurrency || 4)
threads_count = Integer(Figaro.env.puma_max_threads || 5)
threads threads_count, threads_count

preload_app!

rackup      'config.ru'
port        ENV['PORT'] || 5000
environment ENV['RACK_ENV'] || 'development'

before_fork do
  connected = ActiveRecord::Base.connection_pool.with_connection { |con| con.active? }  rescue false
  ActiveRecord::Base.connection_pool.disconnect! if connected
end

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    env = ENV['RACK_ENV'] || 'development'
    db_config = YAML.load(ERB.new(File.read("db/config.yml")).result)[env]
    db_config['pool'] = Figaro.env.puma_max_threads || 5
    ActiveRecord::Base.default_timezone = :utc
    ActiveRecord::Base.establish_connection(db_config)
  end
end
