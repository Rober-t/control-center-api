class AuthManager
  class Authorization

    def initialize(request_method, headers, uri, body)
      @request_method = request_method.upcase
      @headers = headers.each_with_object({}) { |(key, value), result_hash| result_hash[key.downcase] = value }
      @body = body
      @auth_header = {}
      @uri = uri
    end

    def auth_header?
      @headers['authorization'].present?
    end

    def authentic?
      auth_header?
    end

    def authorization_header
      @headers['authorization'].split('Bearer ').last
    end

  end
end
