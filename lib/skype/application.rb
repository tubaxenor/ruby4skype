module Skype
  class Application < AbstractObject
    class Stream
      def initialize app, streamString
        @app = app
        @id = streamString
        @user = Skype.user(@id.split(':')[0])
      end

      def to_s
        @id
      end

      def user
        @user
      end

      def write msg
        @app.write self, cmd
      end

      def datagram msg, &block
        @app.datagram self, cmd
      end

      def read
        @app.read self
      end

      def disconnect
        @app.disconnect self
      end
    end

    OBJECT_NAME = "APPLICATION"

    def get_connectable() parse :connectable, invoke_get("CONNECTABLE") end
    def_parser(:connectable){|str| str.split(' ').collect{|i| Skype.user(i)}}
    alias getConnectable get_connectable

    def get_connecting() parse :connecting, invoke_get("CONNECTING") end
    def_parser(:connecting){|str| str.split(' ').collect{|i| Skype.user(i)}}
    alias getConnecting get_connecting

    def get_streams() parse :streams, invoke_get("STREAMS") end
    def_parser(:streams){|str| str.split(' ').collect{|stream_id| Stream.new(self, stream_id)}}
    alias getStreams get_streams

    def get_received() parse :received, invoke_get("RECEIVED") end
    def_parser(:received){|str|
      str.split(' ').collect{|i|
        streamID, byte = i.split('=')
        {:stream => Stream.new(self, streamID), :bytes => byte.to_i}
      }
    }
    alias getReceived get_received

    def get_sending() parse :sending, invoke_get("SENDING") end
    def_parser(:sending){|str|
      str.split(' ').collect{ |i|
        streamID, byte = i.split('=')
        {:stream => Stream.new(self, streamID),:bytes => byte.to_i}
      }
    }
    alias getSending get_sending

    def_parser(:datagram){|str|
      user,data = str.split(' ',2)
      [Skype.user(user), data]
    }

    def self.create appName
      app = new appName
      app.create
      app
    end

    def create
      invoke_echo "CREATE APPLICATION #{@id}"
    end

    def connect user
      invoke_echo "ALTER APPLICATION #{@id} CONNECT #{user}"
    end

    def write stream, msg
      invoke_alter "WRITE", "#{stream} #{msg}"
    end

    def datagram stream, msg
      invoke_alter "DATAGRAM", "#{stream} #{msg}"
    end

    def read stream
      res = invoke "ALTER APPLICATION #{@id} READ #{stream}"
      res =~ /^ALTER APPLICATION #{@id} READ #{stream} (.*)$/m
      $1
    end

    def disconnect stream
      invoke_echo "ALTER APPLICATION #{@id} DISCONNECT #{stream}"
    end

    def delete
      invoke_echo "DELETE APPLICATION #{@id}"
    end
  end
end
