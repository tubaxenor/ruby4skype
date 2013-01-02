module Skype
  class MenuItem < AbstractObject
    OBJECT_NAME = 'MENU_ITEM'

    class << self
      def create h, block=Proc.new
        raise ArgumentError unless h[:id] and h[:context] and h[:caption]
        #id, context, caption, hint=nil, icon=nil, enabled=nil, enableMultipleContacts=nil, &block
        res = Skype.invoke "CREATE MENU_ITEM #{h[:id]} CONTEXT #{h[:context]} CAPTION #{h[:caption]}#{h[:hint].nil? ? '' : " HINT #{h[:hint]}"}#{h[:icon].nil? ? '' : " ICON #{h[:icon]}"}#{h[:enable].nil? ? '' : " ENABLED #{h[:enabled]}"}#{h[:enableMultipleContacts].nil? ? '' : " ENABLE_MULTIPLE_CONTACTS #{h[:enableMultipleContacts]}"}"
        res == "MENU_ITEM #{h[:id]} CREATED"
        instance = new h[:id]
        instance.setNotify block if block
        instance
      end

      def set_notify sym=nil, block=Proc.new
        @notify[sym] = block
      end

      def notified msg
        if msg =~ /^([^ ]+) CLICKED( ([^ ]+))? CONTEXT ([^ ]+)( CONTEXT_ID (.+))?$/m
          id = $1; context = $4; userID = $3; contextID = $6
          user = userID ? Skype.user(userID) : nil
          instance = new $1
          @notify[nil].call instance, context, user, contextID if @notify[nil]
          @notify[id].call instance, context, user, contextID if @notify[id]
          @@instance[self][id].notified instance, context, user, contextID if @@instance[self][id]
        end
      end

      def delete id
        new(id).delete
      end

    end

    def notified instance, context, user, contextID
      @notify.call instance, context, user, contextID if @notify
    end

    def set_notify block=Proc.new
      @notify = block
    end
    alias setNotify set_notify

    def delete
      res = Skype.invoke "DELETE MENU_ITEM #{@id}"
      res == "DELETE MENU_ITEM #{@id}"
    end

    def set_caption caption
      res = invoke "SET MENU_ITEM #{@id} CAPTION #{caption}"
      res == "MENU_ITEM #{@id} CAPTION \"#{caption}\""
    end
    alias setCaption set_caption

    def set_hint hint
      res = invoke "SET MENU_ITEM #{@id} HINT #{hint}"
      res == "MENU_ITEM #{@id} HINT \"#{hint}\""
    end
    alias setHint set_hint

    def set_enabled flag
      res = invoke "SET MENU_ITEM #{@id} ENABLED #{flag._str}"
      res == "MENU_ITEM #{@id} ENABLED #{flag._str}"
    end
    alias setEnabled set_enabled

  end
end
