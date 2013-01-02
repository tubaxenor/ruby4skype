module Skype
  module OS
    class Notifier
      def notify
        @notify ||= Hash.new
      end

      def add reg, block=Proc.new
        notify[reg] = block
      end

      def del reg
        notify.delete reg
      end

      def fire res
        objects_notify_fire = false
        notify.each do |reg, action|
          if res =~ reg
            action.call($1)
            objects_notify_fire = true
          end
        end

        unless objects_notify_fire
          notify[nil].call(res) if notify[nil]
        end
      end
    end
  end
end