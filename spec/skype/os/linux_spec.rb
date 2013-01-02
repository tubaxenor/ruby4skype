require 'skype/os/linux.rb'

require 'skype.rb'

Thread.abort_on_exception = true

# describe Skype do
#   it 'os should be instance of Linux' do
#     Skype.init
#     Skype.os.should be_instance_of Skype::OS::Linux
#   end
# end

# describe Skype::OS::Linux do

#   it "should attach and close" do
#     @linux = Skype::OS::Linux.new
#     @linux.start_messageloop
#     @linux.attach_wait('hoge')
#     @linux.invoke('GET SKYPEVERSION').should match /SKYPEVERSION \d+\.\d+.\d+/
#     @linux.close
#   end

  describe 'attached' do
    before :each do
      @linux = Skype::OS::Linux.new
      @linux.start_messageloop
      @linux.attach_wait('hogehoge')
    sleep 1
    end

    after do
      @linux.close
    end

    def send_chat msg
      @linux.invoke('CHAT CREATE echo123') =~ /CHAT (.+?) /
      chat_id = $1
      @linux.invoke("CHATMESSAGE #{chat_id} #{msg}")
    end
    
    it "should send chat" do
      i = 0
      @linux.set_notify_selector do |res|
        p res
        if res =~ /CHATMESSAGE RECEIVED/
          #send_chat 'linux test'
          i+=1
        end
      end
      send_chat 'linux test'
      sleep 0.1 while i < 0
    end
        
    
  end

#end

