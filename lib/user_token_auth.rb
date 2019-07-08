require 'jwt'
require 'figaro'
require './lib/errors'

module UserTokenAuth

  def self.included(base)
    base.extend Finder
  end

  def generate_token
    token = JWT.encode(payload, Figaro.env.jwt_secret, 'HS256')
    if update!(jti: payload[:jti])
      token
    else
      raise Errors::Unauthorized
    end
  end

  def payload
    iat = Time.now.utc.to_i

    jti_raw = [Figaro.env.jwt_secret, iat].join(':').to_s
    jti = Digest::MD5.hexdigest(jti_raw)

    {
      exp: iat + (365*24*60*60), # 1 year
      iat: iat,
      iss: Figaro.env.jwt_issuer,
      uid: id.to_s,
      jti: jti
    }
  end

  module Finder

    def find_by_token(token)
      options = { algorithm: 'HS256', iss: Figaro.env.jwt_issuer }
      payload = JWT.decode(token, Figaro.env.jwt_secret, true, options).first

      user = self.find_by(id: payload['uid'])

      if user && user.jti == payload['jti']
        user
      else
        raise Errors::Unauthorized
      end
    rescue JWT::ExpiredSignature, JWT::DecodeError, JWT::InvalidIssuerError, JWT::InvalidIatError
      raise Errors::Unauthorized
    end

  end
end
