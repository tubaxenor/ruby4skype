# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'skype/os/etc'
require 'skype/os/windows'

Thread.abort_on_exception = true

describe Skype::OS::Windows do
  describe 'before attach' do
    describe 'attach' do
      before(:each) do
        @message = Array.new
        @win = Skype::OS::Windows.new
        @win.set_notify_selector{ |msg| @message.push msg }
        @win.start_messageloop
      end

      after(:each) do
        @win.close
      end

      it "should notified 3 message" do
        @win.attach_wait
        sleep 1
        @message[0].should match(/^CONNSTATUS /)
        @message[1].should match(/^CURRENTUSERHANDLE /)
        @message[2].should match(/^USERSTATUS /)
      end

      it "should many attach and close" do
        @win.close
        10.times do |i|
          @win = Skype::OS::Windows.new
          @win.set_notify_selector{ |msg| @message.push msg }
          @win.start_messageloop
          @win.attach_wait
          @win.close
        end
        @win = Skype::OS::Windows.new
      end

      it "should call attached event" do
        flag = false
        @win.add_event(:attached){ flag=true }
        @win.attach
        sleep 3
        flag.should be_true
      end

    end

    describe "windows event queue process on main thread" do
      before(:each) do
        @win = Skype::OS::Windows.new
      end

      after(:each) do
        @win.close
      end

      it "should attach and close" do
        i = 0
        @win.set_notify_selector do |msg|
          i+=1
          @win.close if i >= 3
        end
        f = false
        #@win.add_event(:attached){f=true}
        @win.attach_wait
        timeout(10) do
          @win.messageloop
        end
      end



    end
  end

  describe "after attach" do

    def chat_send id, msg
      @win.invoke("CHAT CREATE #{id}") =~ /^CHAT (.+?) /
      chat_id = $1
      chat_id.should match /^#bopper-\/\$#{id};.+$/
      @win.invoke("CHATMESSAGE #{chat_id} #{msg}") =~ /CHATMESSAGE (\d+?) STATUS SENDING/
      chat_message_id = $1
      chat_message_id.should match /^\d+$/
      @win.invoke("GET CHATMESSAGE #{chat_message_id} BODY").should == "CHATMESSAGE #{chat_message_id} BODY #{msg}"
    end


    before :each do
      @win = Skype::OS::Windows.new
      @win.start_messageloop
      @win.attach_wait
    end

    after :each do
      @win.close
    end

    describe 'invoke' do

      def get_skype_version
        @win.invoke('GET SKYPEVERSION').should match(/^SKYPEVERSION \d+\.\d+\.\d+\.\d+$/)
      end

      it "invoke GET SKYPEVERSION should match SKYPEVERSION num.num.num.num" do
        get_skype_version
      end

      it "should invoke many times" do
        10.times do |i|
          get_skype_version
        end
      end

    end

    describe 'notify' do

      #it "sleeped notify thread by invoke should wake up" do
      it "" do
        i = 0
        @win.set_notify_selector do |msg|
          if msg =~ /^CHATMESSAGE \d+ STATUS SENDING/ and i < 10
            i+=1
          end
        end
        10.times{ chat_send('echo123', 'this is a notify test') }
        timeout(6) do
          sleep 1 until i >= 9
        end
      end

    end

    describe 'recovery timeout' do
      it '' do
        count = 0
        @win.add_hook :sent do |msg|
          p "#{Time.now.to_i}s>#{msg}"
          count += 1 if msg =~ /SEARCH USERS foobarsdfjweiorj/
        end
        @win.add_hook :received do |msg|
          p "#{Time.now.to_i}r>#{msg}"
        end
        @win.__send__(:invoke_block,"SEARCH USERS foobarsdfjweiorj",1).should be_instance_of String
        count.should == 1
      end
    end

    describe 'detach and reattach' do
      before do
        pending 'hogehoge'
      end

      describe 'Skype shutdonw' do
        before do
          pending 'hogehoge'
        end

      end
      describe 'Skype killed' do
        before do
          pending 'hogehoge'
        end

      end
    end

    describe 'multi threads' do

      describe "many create chats" do

        before :each do
          @log = Array.new
          @win.add_hook :sent do |msg|
            @log.push "#{Time.now.to_i}s>#{msg}"
          end
          @win.add_hook :received do |msg|
            @log.push "#{Time.now.to_i}r>#{msg}"
          end
        end

        it "should not error" do
          pending 'spend long time'
          a = 0
          3.times do |tn|
            Thread.new(tn) do |n|
              10000.times do |i|
                begin
                  @win.invoke("CHAT CREATE echo123").should match(/^CHAT .+? STATUS .+?$/)
                rescue TimeoutError => e
                  puts @log
                  raise e
                end
              end
              a += 1
            end
          end
          sleep 1 until a >= 3
        end
      end

      describe "notify thread" do
        before :each do
          @win.add_hook :sent do |msg|
            puts "#{Time.now.to_i}s>#{msg}"
          end
          @win.add_hook :received do |msg|
            puts "#{Time.now.to_i}r>#{msg}"
          end
        end

        it "should invoke in notify" do
          #pending
          i = 0
          @win.set_notify_selector do |msg|
            if msg =~ /CHATMESSAGE (\d+) STATUS RECEIVED/
              cid=$1
              if @win.invoke("GET CHATMESSAGE #{cid} FROM_HANDLE") == "CHATMESSAGE #{cid} FROM_HANDLE ehco123"
                i+=1
                chat_send 'echo123', 'send from notify thread'
              end
            end
          end

          chat_send 'echo123', 'send from main thread'

          sleep 1 until i < 30#00
        end

      end
    end

    describe 'when ctrl+c keydown' do
      it 'should raise interrupt' do
        pending 'how should I write this test?'
      end
    end

    describe 'endurance' do
      before(:each) do
        @win.add_hook :sent do |msg|
          puts "#{Time.now.to_i}s>#{msg}"
        end
        @win.add_hook :received do |msg|
          puts "#{Time.now.to_i}r>#{msg}"
        end
      end

      it 'should send tooo many chat messages by 3 threads' do
        pending 'buzy'
        @win.set_notify_selector{ |msg| }#p(msg) end

        result = Array.new(3,0)
        f = true
        3.times do |t_num|
          Thread.new(t_num) do |t_num|
            while f
              chat_send 'echo123', "this is a endurance test #{result[t_num]} by #{t_num} thread."
              p [result[t_num],t_num]
              result[t_num]+=1
            end
          end
        end
        #sleep 60*10
        i =0
        while true
          i+=10
          p [i,result]
          sleep 10
        end
        f = false
      end

      it 'should send too many chat messages while 3 days' do
        pending 'bore'
        i = 0
        #    @win.set_notify_selector do |msg|
        #      if msg =~ /^CHATMESSAGE \d+ STATUS SENDING/
        #        chat_send('echo123', "this is a endurance test #{i}")
        #        i+=1
        #        p i
        #      end
        #    end

        @win.set_notify_selector{|msg|}

        while true
          chat_send('echo123', "this is a first endurance test #{i}")
          i+=1
          p i
        end
        #start_time = Time.now
        #sleep 10 while Time.now - start_time < 60*30#60*60*24*3
      end
    end
  end
end


