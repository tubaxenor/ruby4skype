module Skype
  class Event  < AbstractObject
    OBJECT_NAME = "EVENT"

    class << self
      def create id, caption, hint, block=Proc.new
        res = Skype.invoke "CREATE EVENT #{id} CAPTION #{caption} HINT #{hint}"
        res == "EVENT #{id} CREATED"
        instance = new id
        instance.setNotify block if block
        instance
      end

      def set_notify id=nil, block=Proc.new
        @notify[id] = block
      end
      alias setNotify set_notify

      def notified msg
        if msg =~ /^([^ ]+) CLICKED$/m
          id = $1
          instance = new $1
          @notify[nil].call instance if @notify[nil]
          @notify[id].call instance if @notify[id]
          @@instance[self][id].notified if @@instance[self][id]
        end
      end

      def delete id
        new(id).delete
      end

    end

    def notified
      @notify.call self if @notify
    end

    def set_notify block=Proc.new
      @notify = block
    end
    alias setNotify set_notify

    def delete
      res = invoke "DELETE EVENT #{@id}"
      res == "DELETE EVENT #{@id}"
    end
  end
end
