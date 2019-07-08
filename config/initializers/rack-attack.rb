require 'redis'
require 'rack/attack'

class Rack::Attack

  # Configure Rack::Attack Cache #
  
  redis_uri = URI.parse(Figaro.env.redis_url)
  Redis.current = Redis.new(host: redis_uri.host, port: redis_uri.port)
  Rack::Attack.cache.store = Rack::Attack::StoreProxy::RedisStoreProxy.new(Redis.current)

  # Safelist Certain Requests #

  # We are also able to safelist certain requests. Maybe everyone no matter
  # what can access a certain path, or requests made from a special internal
  # IP address are always allowed through.

  safelist('allow-localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Throttle Abusive Clients #

  # Key: "rack::attack:#{Time.now.utc.to_i/:period}:req/ip:#{req.ip}-#{req.path}"
  # To allow occasional bursts, we set the limit and period to a higher multiple.
  throttle('req/ip_path', :limit => 500, :period => Time.now.utc + 60) do |req|
    "#{req.ip}-#{req.path}"
  end

  # Throttle Logins Per IP #

  throttle("login_ip", limit: 10, period: Time.now.utc + 20) { |req|
    req.ip if req.post? && req.path == "/authentications"
  }

  # Custom Throttle Response #

  self.throttled_response = ->(env) {
    now = Time.now.utc
    match_data = env['rack.attack.match_data'] || {}

    headers = {
      'Content-Type' => 'application/json',
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
    }

    [ 429, headers, [{ error: "Throttled" }.to_json ]]
  }

end
