require 'thread'

class BlockQueue < Queue #:nodoc: all
  def push_block block=Proc.new
    push block
  end
end

module Skype
  module OS
    class WindowsEventQueue
      def initialize windows
        @windows = windows
        @pause_count = 0
        @pause_mutex = Mutex.new
      end

      attr_reader :windows

      def queue
        @queue ||= BlockQueue.new
      end

      def length
        @queue.length
      end

      def received_count
        @received_count ||= 0
      end
      attr_writer :received_count
      private :received_count=

      def callback
        @callback ||= Hash.new
      end

      def set_notify_selector block=Proc.new
        @notify_selector = block
      end

      attr_reader :notify_selector

      def hook
        @hook ||= Hash.new do |h,k|
          h[k] = Array.new
        end
      end

      private :queue, :hook, :windows

      def add_hook sym, block=Proc.new
        hook[sym].push block
      end

      def del_hook sym, block=nil
        unless block
          hook[sym] = Array.new
        else
          hook[sym].delete block
        end
      end

      def exist_hook? sym
        if hook[sym].length > 0
          return true
        else
          return false
        end
      end

      def get_hook sym
        hook[sym] ? true : false
      end

      def push response
        self.received_count += 1
        response = response.chop
        push_received_hook(response)

        cmd_num, res = response_match(response)
        if cmd_num
          @windows.wmHandler.del_send_buffer cmd_num.to_i
          set_cmd_response(cmd_num, res)
        else
          when_detached if response_detached?(res)
          push_notify res
        end
      end

      def push_hook sym, *args
        queue.push_block{ call_hook(sym, *args) }
      end

      def push_block block=Proc.new
        queue.push block
      end

      def start_messageloop
        Thread.new{messageloop}
      end

      def messageloop
        while callback = queue.shift
          break unless message_process callback
        end
      end

      def messagepolling
        return message_process(queue.shift) unless queue.empty?
        return true
      end

      def message_process callback
        sleep 0.001 while paused?
        return false  if callback == :exit
        callback.call
        return true
      end
      private :message_process

      def close
        queue.clear
        queue.push :exit
      end

      def paused?
        @pause_count > 0
      end

      def pause &block
        if block
          _pause
          block.call
          play
        else
          _pause
        end
      end

      def _pause
        @pause_mutex.synchronized{@pause_count += 1}
      end

      def play
        @pause_mutex.synchronized{@pause_count -=1}
      end

      def push_detached_hook
        #windows.attached = false
        queue.push_block{ call_hook(:detached) }
        #Skype.attach
      end

      private

      def push_received_hook(response)
        queue.push_block{ call_hook(:received, response) }
      end

      def response_match(res)
        res =~ /^(#(\d+?) )?(.+?)$/m
        return [$2, $3]
      end

      def when_detached
        windows.attached = false
        queue.push_block{ call_hook(:detached) }
        Skype.attach
      end

      def set_cmd_response(cmd_num, res)
        cmd_num = cmd_num.to_i
        if callback[cmd_num]
          cb = callback[cmd_num]
          callback.delete(cmd_num)
          #@windows.invoke_callback_mutex.synchronize do
            cb.call(res)
            @windows.cv.broadcast
          #end
        end
      end

      def response_detached? res
        res == 'CONNSTATUS LOGGEDOUT'
      end

      def push_notify res
        queue.push_block{notify_selector.call res} if notify_selector
      end

      def call_hook sym, *args
        hook[sym].each{ |h| h.call *args }
      end

    end
  end
end