module Skype
  module OS
    class MessageHandler < SWin::Window

      def init skypeAPI, queue
        @skypeAPI = skypeAPI
        @queue = queue

        @dwDiscoverMsg = RegisterWindowMessage.call("SkypeControlAPIDiscover");
        raise Skype::Error::Attach.new("SkypeControlAPIDiscover nothing") unless @dwDiscoverMsg

        @dwAttachMsg = RegisterWindowMessage.call("SkypeControlAPIAttach")
        raise Skype::Error::Attach.new("SkypeControlAPIAttach nothing") unless @dwAttachMsg

        addEvent(WM_COPYDATA)
        addEvent(WM_USER_MSG)
        addEvent @dwAttachMsg

        create unless alive?
      end

      def attach
        unless PostMessage.call(HWND_BROADCAST, @dwDiscoverMsg, hWnd, 0)
          raise Skype::Error::Attach.new("SkypeControlAPIDiscover broadcast failure")
        end
        return true
      end

      def send_buffer
        @send_buffer ||= Hash.new
      end

      def del_send_buffer num
        @send_buffer.delete num
      end

      def invoke num, cmd
        unless @hSkypeWindowHandle
          raise Skype::Error::Attach.new("NullPointerException SendSkype!")
          return false
        end

        cmd = '#' + num.to_s + ' ' + cmd + "\0"
        pCopyData = application.arg2cstructStr("LLS",0,cmd.length+1,cmd)
        send_buffer[num] = cmd
        unless PostMessage.call(hWnd, WM_USER_MSG, @hSkypeWindowHandle, pCopyData)
          @hSkypeWindowHandle = nil
          raise Skype::Error::Attach.new("Skype not ready")
        end
        @queue.push_hook(:sent, cmd.chop) if @queue.exist_hook? :sent
        return true
      end

      def msghandler(sMsg)
        case sMsg.msg
        when @dwAttachMsg
          case sMsg.lParam
          when SKYPECONTROLAPI_ATTACH_SUCCESS
            @hSkypeWindowHandle = sMsg.wParam
            invoke_protocol
            @queue.push_hook(:attach,:success)

            unless @skypeAPI.attached
              if @skypeAPI.first_attached
                @queue.push_hook(:attached)
              else
                @queue.push_hook(:reattached)
              end
            end
            
            @skypeAPI.attached = true
            @skypeAPI.first_attached = false
          when SKYPECONTROLAPI_ATTACH_PENDING_AUTHORIZATION
            @queue.push_hook(:attach,:authorize)
            @queue.push_hook(:authorize)
          when SKYPECONTROLAPI_ATTACH_REFUSED
            @queue.push_hook(:attach,:refused)
            @queue.push_hook(:refused)
            @skypeAPI.attached = false
          when SKYPECONTROLAPI_ATTACH_NOT_AVAILABLE
            @queue.push_hook(:attach, :not_available)
            @queue.push_hook(:not_available)
            @skypeAPI.attached = false
          when SKYPECONTROLAPI_ATTACH_API_AVAILABLE
            @queue.push_hook(:attach, :available)
            @queue.push_hook(:available)
          else
            @queue.push_hook(:attach,:unkown)
            @queue.push_hook(:unkown)
          end
          sMsg.retval = 1
        when WM_COPYDATA
          if sMsg.wParam == @hSkypeWindowHandle
            retval = application.cstruct2array(sMsg.lParam,"LLL")
            cmd = application.pointer2string(retval[2],retval[1])
            @queue.push cmd
            sMsg.retval = 1
          end
        when WM_USER_MSG
          unless SendMessage.call(sMsg.wParam, WM_COPYDATA, sMsg.hWnd, sMsg.lParam)
            raise  Skype::Error::Attach.new("Skype not ready")
          end
          sMsg.retval = 1
        else
          super
        end
      end

      def invoke_protocol
        #@queue.push Proc.new{@skypeAPI.invoke_callback("PROTOCOL 9999"){}}
        #@queue.push_block{@skypeAPI.invoke_callback("PROTOCOL 9999"){}}
        @skypeAPI.__send__ :invoke_callback, "PROTOCOL 9999", Proc.new{}
        #@queue.push_block{@skypeAPI.invoke_block("PROTOCOL 9999")}
        #@skypeAPI.invoke_block("PROTOCOL 9999")
      end
      private :invoke_protocol
    end

  end
end
