module Skype
  class Error < StandardError
    class Attach < Error; end
    class API < Error; end
    class Timeout < Error; end
    class NotImprement < Error; end
  end
end
