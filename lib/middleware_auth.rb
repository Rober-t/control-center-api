require 'uri'
require 'rack/request'
require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/membership'
require './app/models/organisation_manager/user'
require './app/models/auth_manager/authorization'


class MiddlewareAuth < Rack::Auth::AbstractHandler

  def call(env)
    dup._call(env)
  end

  def _call(env)
    @env = env

    @auth_request = nil
    @auth = nil
    @authenticator_result = nil

    return @app.call(@env) unless auth_request.required?
    return unauthorized unless auth_request.provided?
    return bad_request unless auth_request.jwt?

    if valid?
      on_valid
    else
      unauthorized
    end
  rescue Errors::Unauthorized
    unauthorized
  end

  private

  def valid?
    auth.authentic? && authenticator_result
  end

  def on_valid
    endpoint.send(:'current_user=', user)
    endpoint.send(:'current_organisation=', user.organisation)
    @app.call(@env)
  end

  def auth
    @auth ||= AuthManager::Authorization.new(request.request_method,
                                             auth_request.headers.merge('Content-Type' => request.content_type),
                                             URI(request.url),
                                             auth_request.body)
  end

  def auth_request
    @auth_request ||= MiddlewareAuth::AuthRequest.new(@env)
  end

  def request
    auth_request.request
  end

  def authenticator_result
    @authenticator_result ||= @authenticator.call(auth.authorization_header)
  end

  def user
    authenticator_result[:user]
  end

  def unauthorized(www_authenticate = challenge)
    endpoint.error!( { error: 'Unauthorized' }, 401,  'WWW-Authenticate' => www_authenticate.to_s)
  end

  def bad_request
    endpoint.error!( { error: 'Bad Request' }, 400)
  end

  def endpoint
    @env['api.endpoint']
  end

  def challenge
    'Bearer token_type="JWT" realm="%s"' % realm
  end

  class AuthRequest < Rack::Auth::AbstractRequest

    def required?
      case request.url
      when /\/authentications/
        request.post? ? false : true
      when /\/status/
        false
      when /\/passwords/
        false
      when /\/confirmations/
        request.url.include?("actions") ? true : false
      when /\/organisations/
        request.post? ? false : true
      else
        true
      end
    end

    def jwt?
      'bearer' == scheme.downcase
    end

    def headers
      @headers ||= @env.each_with_object({}) do |(key, value), result_hash|
        key = key.upcase
        next unless key.to_s.start_with?('HTTP_') && (key.to_s != 'HTTP_VERSION')

        key = key[5..-1].gsub('_', '-').downcase.gsub(/^.|[-_\s]./) { |x| x.upcase }
        result_hash[key] = value
      end
    end

    def body
      @body ||= request.body.read.tap { request.body.rewind }
    end

  end

end
