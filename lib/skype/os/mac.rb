require 'osx/cocoa'
require 'thread'
Dir.chdir '../../' if __FILE__ == $0
require 'skype/os/etc.rb'

OSX.require_framework 'Skype'

module Skype
  module OS
    class Mac < Skype::OS::Abstruct
      
      class MessageHandler < OSX::NSObject
        
        def _init os, name
          @os = os
          @clientApplicationName = name
        end
        
        def clientApplicationName
          @clientApplicationName
        end
        
        addRubyMethod_withType 'skypeAttachResponse:', 'v@:i'
        def skypeAttachResponse status
          if status == 1
            @os.attached = true
            OSX::SkypeAPI.sendSkypeCommand('PROTOCOL 9999')
          else
            @os.attached = false
          end
        end
        
        def skypeBecameAvilable
        end
        
        def skypeBecameUnavilable
        end
        
        #addRubyMethod_withType 'skypeNotificationReceived:', 'v@:i'
        def skypeNotificationReceived notification_string
          p "[#{notification_string.to_s}]" if @os.debug
          
          if notification_string.to_s =~ /^#(\d+) (.+)$/m
            send_count = $1.to_i; res = $2
            @os.response[send_count] = notification_string.to_s
          else
            @os.push_queue notification_string.to_s
          end
        end
      end
      
      def initialize client_application_name='ruby4skype'
        @queue = Queue.new
        @attached = false
        @debug = false
        
        @send_count = 0
        @send_count_mutex = Mutex.new
        @response = Hash.new
        
        @msg = MessageHandler.alloc.init
        @msg._init self, client_application_name
        OSX::SkypeAPI.setSkypeDelegate @msg
        
        app = OSX::NSApplication.sharedApplication
        unless app.isRunning
          @t =Thread.new do
            sleep 1
            app.run 
          end
        end
        #OSX::NSRunLoop.currentRunLoop.run 
      end      
      attr_reader :queue, :name, :attached, :response, :debug
      attr_writer :attached
      private :queue

      def set_notify_selector block=Proc.new
        @notify_selector = block
      end
      attr_reader :notify_selector      
      
      def attach
        unless attached?
          OSX::SkypeAPI.connect
        end
      end
      
      def attach_wait
        attach
        sleep 0.123 until attached?
        OSX::SkypeAPI.sendSkypeCommand('PROTOCOL 9999')
      end
      
      def attached?
        @attached
      end
      
      def dettach
        self.attached = false
        OSX::SkypeAPI.disconnect
      end
      
      def skype_runnging?
        OSX::SkypeAPI.isSkypeRunnging
      end
      
      def invoke_prototype cmd
        send_count = send_count_increment
        cmd = "##{send_count} #{cmd}"
        
        #@queue.push(proc{do_event(:sent, cmd)}) if exist_event? :sent
        p ">#{cmd}" if @debug
        
        res = OSX::SkypeAPI.sendSkypeCommand(cmd).to_s
        if res.empty?
          begin
            timeout(5){sleep 0.123 until response[send_count]}
          rescue TimeoutError
            raise Skype::Error::API.new("#{cmd} => no response. it may be skype bug")
          end
          res = response[send_count]
          response.delete send_count
        end
        
        p "<#{res}" if @debug
        #@queue.push(proc{do_event(:received, res)}) if exist_event? :received
        
        res = $1 if res =~ /^#\d+ (.+)$/m
        
        return res
      end
      
      def send_count_increment
        send_count = nil
        @send_count_mutex.synchronize do
          send_count = @send_count
          @send_count+=1
        end
        send_count
      end
      private :send_count_increment
      
      def invoke_callback cmd,cb=Proc.new
        res = invoke_block cmd
        cb.call res
      end
      
      alias invoke_block invoke_prototype

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
        #sleep 0.001 while paused?
        return false  if callback == :exit
        callback.call
        return true
      end
      private :message_process

      def push_queue res
        queue.push(proc{notify_selector.call res}) if notify_selector
      end

      def close
        dettach if attached?
        OSX::SkypeAPI.removeSkypeDelegate
        #OSX::NSApplication.sharedApplication.stop(@msg)
        #OSX::NSApplication.sharedApplication.terminate(@msg)
        #@msg.dealloc
        #@t.kill
        queue.push :exit
      end
      #def close()
      #  dettach if attached?
      #end
      
    end
  end
end


if __FILE__ == $0
  Thread.abort_on_exception = true

  os = Skype::OS::Mac.new 'hogehogehogea'
  os.set_notify_selector{|res| p res}
  os.start_messageloop
  p :hoge
  os.attach_wait
  p :hoge
  p tmp = os.invoke('CHAT CREATE echo123')
  tmp =~ /CHAT (.+) /
  p cid = $1
  os.invoke("CHATMESSAGE #{cid} hoge")

  begin
    p os.invoke("GET AGC")
  rescue
    p $!
  end
  sleep 10
  os.close
end