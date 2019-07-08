class Errors

  class BadRequest < StandardError; end
  class Unauthorized < StandardError; end
  class RequestFailed < StandardError; end
  class Forbidden < StandardError; end
  class NotFound < StandardError; end
  class UnprocessableEntity < StandardError; end
  class ServerError < StandardError; end

end
