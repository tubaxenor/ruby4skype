require 'skype/error'

module Skype
  module OS
    class Abstruct
      
      def initialize app_name
        @send_count = 0
        @hook = Hash.new do |h,k|
          h[k] = Array.new
        end
        @attached = false
        @first_attached = true
        @raise_when_detached = false
      end

      def add_hook sym, block=Proc.new
        @hook[sym].push block
        block
      end

      def del_hook sym, block=nil
        unless block
          @hook[sym] = Array.new
        else
          @hook[sym].delete block
        end
      end

      def exist_hook? sym
        if @hook[sym].length > 0
          return true
        else
          return false
        end
      end

      def get_hook sym
        @hook[sym]
      end

      def call_hook sym,*args
        @hook[sym].each{ |h| h.call *args }
      end
      private :call_hook

      def invoke cmd
        begin
          check_response(invoke_block(cmd), cmd)
        rescue Skype::Error::API => e
          e.backtrace.shift
          e.backtrace.shift
          raise e
        end
      end

      def invoke_callback cmd, callback = Proc.new
      end
      
      def invoke_block cmd
      end
      
      def check_response res, cmd
        case res
        when /^ERROR /m
          raise Skype::Error::API.new("#{cmd} => #{res}")
        when /^((APPLICATION)|(CALL)|(CHAT)|(CHATMESSAGE)|(FILETRANSTER)|(GROUP)|(MENU_ITEM)|(MESSAGE)|(PROFILE)|(SMS)|(USER)|(VOICEMAIL)) [^ ]+? (ERROR .+)$/m
          res = $14
          raise Skype::Error::API.new("#{cmd} => #{res}")
        when ''
          raise Skype::Error::API.new("#{cmd} => no implement or ,,,")
        when /^(((APPLICATION)|(CALL)|(CHAT)|(CHATMESSAGE)|(FILETRANSTER)|(GROUP)|(MENU_ITEM)|(MESSAGE)|(PROFILE)|(SMS)|(USER)|(VOICEMAIL)) [^ ]+? [^ ]+? )\(null\)$/m
          res = $1
          return res
        else
          return res
        end
      end
      private :check_response

      def attach
      end
            
      def attach_wait
      end

      def set_notify_selector block=Proc.new
        
      end

      def start_messageloop

      end

      def messageloop

      end

      def message_polling

      end

      def close
        
      end      
    end
  end
end
