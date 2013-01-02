require 'swin'
require 'Win32API'
require 'timeout'
require 'skype/os/etc'
require 'skype/os/window_event_queue'
require 'skype/os/window_messagehandler'

module Skype
  module OS
    WAIT_CMD_LIMIT = 30.0 #sec
    PING_CYCLE = 10.0 #sec
    PING_LIMIT = 5.0 # < PING_CYCLE
    SLEEP_INTERVAL = 0.001

    HWND_BROADCAST = 0xFFFF
    WM_COPYDATA = 0x004A
    WM_CLOSE = 0x10
    WM_USER = 0x0400
    WM_USER_MSG = WM_USER + 1
    SKYPECONTROLAPI_ATTACH_SUCCESS=0
    SKYPECONTROLAPI_ATTACH_PENDING_AUTHORIZATION=1
    SKYPECONTROLAPI_ATTACH_REFUSED=2
    SKYPECONTROLAPI_ATTACH_NOT_AVAILABLE=3
    SKYPECONTROLAPI_ATTACH_API_AVAILABLE=0x8001

    RegisterWindowMessage = Win32API.new('user32','RegisterWindowMessageA', 'P', 'L')
    SendMessage = Win32API.new("user32", "SendMessageA", ['L']*4, 'L')
    PostMessage = Win32API.new("user32", "PostMessageA", 'LLLP', 'L')

    class Windows < Abstruct
      
      def initialize appname=nil
        @send_count = 0
        @queue = WindowsEventQueue.new(self)

        @attached = false
        @first_attached = true
        @raise_when_detached = false
        
        @invoke_mutex = Mutex.new
        @invoke_callback_mutex = Mutex.new
        @cv = ConditionVariable.new
        @detached_mutex = Mutex.new

        add_hook :available do
          Skype.attach
        end
        
        @wmHandler = SWin::LWFactory.new(SWin::Application.hInstance).newwindow nil, MessageHandler
        @wmHandler.init self, @queue
        
        #@queue.start_process_thread
        start_wmhandler_loop
        start_ping_thread
      end

      attr_reader :invoke_callback_mutex, :cv, :wmHandler
      attr_accessor :attached, :first_attached#,:received,:sent

      #引数にmethodかブロックを渡しておくとSkypeのNotification(コマンドのレスポンは除く)があった場合呼ばれる。
      #ブロックはNotificationの文字列を一つ与えられて呼ばれる。
      def set_notify_selector block=Proc.new
        @queue.set_notify_selector block
      end
      
      #主にAttachなど、Skypeとのコネクション関係のイベントの通知を受ける為のブロックを設定する。
      #引数 sym は :attach, :attached, :authorize, :refused, :not_available, :available, :unknown, :detachedを取る。
      #引数 sym が :attachの場合、ブロックは一つの引数(:success,:authorize,:refused,:not_available,:available,:unknownのどれか)を与えられて呼ばれる。
      def add_hook sym, block=Proc.new
        @queue.add_hook sym, block
      end

      def del_hook sym, block=nil
        @queue.del_hook sym, block
      end

      def exist_hook? sym
        @queue.exist_hook? sym
      end

      def get_hook sym
        @queue.get_hook sym
      end

      alias add_event add_hook
      alias del_event del_hook
      alias exist_event? exist_hook?
      alias get_event get_hook

      #SkypeにAttachする。ブロックはしないのでつながるまで待つならばadd_hookでイベントを追加するか,attach_waitを使う。
      def attach name = nil #,&block)
        @wmHandler.attach
      end

      def attach_wait name = nil
        attach name
        sleep SLEEP_INTERVAL until @attached
      end

      def detached?
        return true unless @attached
        old_received_count = @queue.received_count
        return false if _ping
        return false if @queue.received_count - old_received_count > 0
        return true
      end
      private :detached?

      #Skypeにコマンドを発行する。Skypeから返り値が戻ってくるまでブロックする。
      def invoke cmd
        super cmd
      end

      def invoke_callback cmd,cb=Proc.new
        send_count = nil
        @invoke_mutex.synchronize do
          send_count = @send_count
          @send_count += 1
        end
        
        @queue.callback[send_count] = cb
        begin
          @wmHandler.invoke send_count, cmd
        rescue => e
          @queue.callback.delete(send_count)
          raise e
        end
        return send_count
      end
      private :invoke_callback

      def invoke_block cmd, wait_limit = WAIT_CMD_LIMIT
        result = nil
        retry_flag = false
        send_count = invoke_callback(cmd){ |res| result = res }
        begin
          timeout(wait_limit){ @invoke_callback_mutex.synchronize{ @cv.wait @invoke_callback_mutex until result } }
        rescue Timeout::Error
          if detached?
            if @raise_when_detached
              raise Skype::Error::Timeout.new("timeout #{send_count} #{cmd}")
            else
              status2detache
              retry_flag = true
            end
          else
            retry
          end
        end
        return retry_flag ? invoke_block(cmd) : result
      end
      private :invoke_block

      def status2detache
        @detached_mutex.synchronize do
          if detached?
            @attached = false
            @queue.push_detached_hook
            attach_wait
          else
            #wait?
            #runtimeerro?
          end
        end
      end

      #notificationのメッセージループを新しいスレッドで回し始めます。
      def start_messageloop
        @queue.start_messageloop
      end

      #notificationのメッセージループをカレントスレッドで回しはじめます。すなわち帰ってきません。
      def messageloop
        @queue.messageloop
      end

      #notificationのメッセージループを一度だけ回します。
      def messagepolling
        @queue.messagepolling
      end
      
      alias polling messagepolling

      def start_wmhandler_loop
        @doevents_thread = Thread.new do
          @message_loop_in = true
          @wmHandler.application.messageloop do
            sleep 0.01
          end
          @message_loop_in = false
        end
      end
      private :start_wmhandler_loop


      def start_ping_thread
        Thread.new do
          loop do
            ping if @attached
            sleep PING_CYCLE
          end
        end
      end
      private :start_ping_thread

      #とりあえず、新しくインスタンスを作るとき、古いものはcloseしないといけない。
      def close
        break_messageloop
        #@wmHandler.close
        @queue.close
      end

      def break_messageloop
        PostMessage.call(@wmHandler.hWnd, WM_CLOSE, 0,0)
        sleep 0.123 while @message_loop_in
      end
      private :break_messageloop

      def ping
        invoke_block('PING',PING_LIMIT) == 'PONG'
      end

      def _ping
        result = nil
        invoke_callback('PING'){|res| result = res}
        sleep PING_LIMIT
        result == 'PONG'
      end
      private :ping

    end
  end
end
