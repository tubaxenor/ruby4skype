require 'skype/os/etc.rb'
require 'dbus'
require "thread"

module Skype
  module OS
    class Linux < Abstruct
      class Notify < DBus::Object
        dbus_interface "com.Skype.API.Client" do
          dbus_method :Notify, "in data:s" do |res|
            @os.push_queue res
          end
        end
      end

      def initialize app_name, service_name="org.ruby.service"
        super(app_name)

        @app_name = app_name
        @queue = Queue.new

        @bus = DBus.session_bus
        notify = Notify.new("/com/Skype/Client")
        notify.instance_variable_set(:@os, self)
        ex_service = @bus.request_service(service_name)
        ex_service.export(notify)
        service = @bus.service 'com.Skype.API'
        @invoker = service.object '/com/Skype'
        @invoker.default_iface = 'com.Skype.API'
        @invoker.introspect
      end

      attr_reader :queue
      private :queue

      def set_notify_selector block=Proc.new
        @notify_selector = block
      end
      attr_reader :notify_selector
      private :notify_selector

      def attach
        invoke "NAME #{@app_name}"
        invoke "PROTOCOL 9999"
        if @first_attached
          #@queue.push proc{do_hook :attached}
        else
          #@queue.push proc{do_hook :reattached}
        end
        Thread.new do
          l = DBus::Main.new
          l << @bus
          l.run
        end
      end

      alias attach_wait attach

      def invoke_prototype(cmd)
        #@queue.push proc{do_hook :sent, cmd}
        res = @invoker.Invoke(cmd)[0]
        #@queue.push proc{do_hook :received, res}
        return res
      end

      alias invoke_block invoke_prototype

      def invoke_callback *args
        raise Skype::Error::NotImprement
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
        #sleep 0.001 while paused?
        return false  if callback == :exit
        callback.call
        return true
      end
      private :message_process

      def push_queue res
        p res
        #queue.push(proc{do_hook(:received, res)})

        if res == 'CONNSTATUS LOGGEDOUT'
          @attached = false
          #queue.push(proc{do_hook(:detached)})
          #Skype.attach
        end

        queue.push(proc{notify_selector.call res}) if notify_selector
      end

      def close
        queue.push :exit

      end

    end
  end
end
