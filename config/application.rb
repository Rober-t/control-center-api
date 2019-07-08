$:.push(File.join(File.dirname(__FILE__), 'api/'))
$:.push(File.join(File.dirname(__FILE__), 'app/'))
$:.push(File.join(File.dirname(__FILE__), 'lib/'))
$:.push(File.join(File.dirname(__FILE__)))

require 'figaro'
require 'pry'

class GrapeFigaro < Figaro::Application
  def default_path
    './config/application.yml'
  end
end

Figaro.adapter = GrapeFigaro;
Figaro.load;
Figaro.require_keys(
	'jwt_secret',
	'segment_write_key',
	'redis_url',
	'app_url',
)