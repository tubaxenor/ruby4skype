$LOAD_PATH << 'lib'
require 'skype'

Thread.abort_on_exception = true

describe Skype::Chat do
  before :all do
    Skype.init 'hogehogehoge'
    Skype.start_messageloop
    Skype.attach_wait
  end

  after(:all) do
    Skype.close
  end

  describe 'notify' do
    before do
      @f = false
      Skype::ChatMessage.set_notify :status, 'RECEIVED' do |c|
        @f = true
      end
      Skype::Chat.create('echo123').send_message('hoge')
    end

    it "should" do
      begin
        timeout(10){sleep 1  until @f}
      rescue Timeout::Error
        violated
      end
    end
  end

  describe '1on1' do
    before(:each) do
      @chat = Skype::Chat.create 'echo123'#, 'hogehoge_002'
    end

    after(:each) do
      #@chat.leave unless @chat.nil?
    end


    it "Skype::Chat.create(string) should be instance of Chat" do
      Skype::Chat.create('echo123').should be_instance_of Skype::Chat
    end

    it "Skype::Chat.create(Skype::User) should be instance of Chat" do
      Skype::Chat.create(Skype.user('echo123')).should be_instance_of Skype::Chat
    end
    
    it "Skype::Chat.findUsingBlob(@chat.get_blob) should raise error Skype::Error::API" do
      lambda{Skype::Chat.findUsingBlob(@chat.get_blob)}.should raise_error Skype::Error::API
      #ERROR 610 CHAT: FINDUSINGBLOB: No existing chat for given blob found or invalid blob
      #get_bolb = > ''
    end

    it "Skype::Chat.createUsingBlob(@chat.get_blob) should raise error Skype::Error::API" do
      lambda{Skype::Chat.createUsingBlob(@chat.get_blob)}.should raise_error Skype::Error::API
      #ERROR 611 CHAT: CREATEUSINGBLOB: Unable to create chat, invalid blob
      #get_bolb = > ''
    end

    it "get_name should be instance of String and not empty and == chat id" do
      @chat.get_name.should be_instance_of String
      @chat.get_name.should_not be_empty
      @chat.get_name.should == @chat.to_s
    end

    it 'get_timestamp should be_instance_of Time or nil?' do
      if @chat.getTimestamp.nil?
        pending 'i phave not time'
      else
        @chat.getTimestamp.should be_instance_of Time
      end
    end

    it 'get_adder should be instance of User.but self create chat should be nil' do
      @chat.get_adder.should be_nil
    end

    it "get_status should match /(LEGACY_DIALOG)|(DIALOG)|(MULTI_SUBSCRIBED)|(UNSUBSCRIBED)/" do
      @chat.get_status.should match /^(LEGACY_DIALOG)|(DIALOG)|(MULTI_SUBSCRIBED)|(UNSUBSCRIBED)$/
    end

    it "get_posters each should be instance of User" do
      @chat.sendMessage 'hoge'
      pending 'no posters' if @chat.get_posters.empty?
      @chat.get_posters.each do |user|
        user.should be_instance_of Skype::User
      end
    end

    it "get_members each should be instance of ChatMember" do
      pending 'no member'# if @chat.get_members.empty?
      @chat.getMembers.each do |chat_member|
        chat_member.should be_instance_of Skype::ChatMember
      end
    end

    it "get_topic should be instance of String and empty" do
      @chat.getTopic.should be_instance_of String
      @chat.getTopic.should be_empty
    end

    it "set_topic(string) should raise_error Skype::Error::API" do
      lambda{@chat.setTopic('TEST')}.should raise_error Skype::Error::API
    end

    it "get_topic_xml should be instance of String and empty" do
      @chat.getTopicXML.should be_instance_of String
      @chat.getTopicXML.should be_empty
    end

    it "set_topic_xml(string) should raise error Skype::Error::API" do
      lambda{@chat.setTopicXML('<BLINK>topic is blinking</BLINK>')}.should raise_error Skype::Error::API
    end

    it "get_chat_messages each should be instance of ChatMessage" do
      @chat.send_message 'hoge'
      @chat.getChatMessages.each do |chat_message|
        chat_message.should be_instance_of Skype::ChatMessage
      end
    end

    it "get_active_members each should be instance of ChatMember" do
      pending 'user or member'
      @chat.getActiveMembers.each do |member|
        member.should be_instance_of Skype::ChatMember
      end
    end

    it "get_friendly_name should be instance of String" do
      @chat.getFriendlyName.should be_instance_of String
    end

    it "get_recent_chat_messages each should be instance of Chat" do
      @chat.send_message 'hoge'
      @chat.getRecentChatMessages.each do |chat_message|
        chat_message.should be_instance_of Skype::ChatMessage
      end
    end

    it "bookmarked should be true and get_bookmarked should be true and unbookmarked should be true and get_bookmarked should be false" do
      @chat.bookmarked.should be_true
      @chat.getBookmarked.should be_true
      @chat.unbookmarked.should be_true
      @chat.getBookmarked.should be_false
    end

    it "get_member_objects each should be instance of ChatMember" do
      @chat.getMemberObjects.each do |chat_member|
        chat_member.should be_instance_of Skype::ChatMember
      end
    end

    it "get_password_hint should be instance of String and empty" do
      @chat.getPasswordHint.should be_instance_of String
      @chat.getPasswordHint.should be_empty
    end

    it "set_guid_lines(string) should be raise error Skype::Error::API" do
      lambda{@chat.setGuideLines('TEST')}.should raise_error Skype::Error::API
    end

    it "get_options should be_kind_of" do
      @chat.getOptions.should be_kind_of Integer
    end

    it "set_options(integer) should raise error Skype::Error::API" do
      lambda{@chat.setOptions(1)}.should raise_error Skype::Error::API
    end

    it "get_description should be instance of String" do
      @chat.getDescription.should be_instance_of String
    end

    it "get_dialog_partner should be instance of User or nil" do
      pending 'nil' if @chat.getDialogPartner.nil?
      @chat.getDialogPartner.should be_instance_of Skype::User
    end

    it "get_activity_timestamp should be instance of Time" do
      @chat.getActivityTimestamp.should be_instance_of Time
    end

    it "get_type should match /(LEGACY_DIALOG)|(DIALOG)|(MULTICHAT)|(SHAREDGROUP)|(LEGACY_UNSUBSCRIBED)/" do
      @chat.getType.should match /(LEGACY_DIALOG)|(DIALOG)|(MULTICHAT)|(SHAREDGROUP)|(LEGACY_UNSUBSCRIBED)/
    end

    it "get_my_status should match /(CONNECTING)|(WAITING_REMOTE_ACCEPT)|(ACCEPT_REQUIRED)|(PASSWORD_REQUIRED)|(SUBSCRIBED)|(UNSUBSCRIBED)|(CHAT_DISBANDED)|(QUEUED_BECAUSE_CHAT_IS_FULL)|(APPLICATION_DENIED)|(KICKED)|(BANNED)|(RETRY_CONNECTING)/" do
      @chat.getMyStatus.should match /(CONNECTING)|(WAITING_REMOTE_ACCEPT)|(ACCEPT_REQUIRED)|(PASSWORD_REQUIRED)|(SUBSCRIBED)|(UNSUBSCRIBED)|(CHAT_DISBANDED)|(QUEUED_BECAUSE_CHAT_IS_FULL)|(APPLICATION_DENIED)|(KICKED)|(BANNED)|(RETRY_CONNECTING)/
    end

    it "get_my_role should match /(CREATOR)|(MASTER)|(HELPER)|(USER)|(LISTENER)|(APPLICANT)/" do
      @chat.getMyRole.should match /(CREATOR)|(MASTER)|(HELPER)|(USER)|(LISTENER)|(APPLICANT)/
    end

    it "get_blob should be instance of String and empty" do
      blob = @chat.getBlob
      blob.should be_instance_of String
      blob.should be_empty
    end

    it "get_applicants each should be instance of User" do
      pending 'no,,,' if @chat.getApplicants.empty?
      @chat.getApplicants.each do |user|
        user.should be_instance_of Skype::User
      end
    end

    it "leave should raise Skype::Error::API" do
      lambda{@chat.leave}.should raise_error Skype::Error::API
    end

    it "join should raise error Skype::Error::API" do
      lambda{@chat.join}.should raise_error Skype::Error::API
    end

    it "clearRecentMessages should be true" do
      @chat.clearRecentMessages.should be_true
    end

    it "alert_string(string) should be true" do
      @chat.setAlertString('hoge').should be_true
    end

    it "acceptadd should should raise error Skype::Error::API" do
      lambda{@chat.acceptadd}.should raise_error Skype::Error::API
    end

    it "disband should should raise error Skype::Error::API" do
      lambda{@chat.disband}.should raise_error Skype::Error::API
    end

    it "set_password(string) should raise enrror Skype::Error::API" do
      lambda{@chat.setPassword('hogehoge')}.should raise_error Skype::Error::API
    end

    it "enter_password(string) should raise error Skype::Error::API" do
      lambda{@chat.enterPassword('hogehoge')}.should raise_error Skype::Error::API
    end

    it "kick(string) should raise error Skype::Error::API" do
      lambda{@chat.kick('echo123')}.should raise_error Skype::Error::API
    end

    it "kick(user) should raise error Skype::Error::API" do
      lambda{@chat.kick(Skype.user('echo123'))}.should raise_error Skype::Error::API
    end

    it "kick_ban(string) should raise error Skype::Error::API" do
      lambda{@chat.kickban('echo123')}.should raise_error Skype::Error::API
    end

    it "kick_ban(user) should raise error Skype::Error::API" do
      lambda{@chat.kickban(Skype.user('echo123'))}.should raise_error Skype::Error::API
    end

    it "send_message should be instance of" do
      @chat.sendMessage('test').should be_instance_of Skype::ChatMessage
    end
  end

  describe 'in 3 people' do
    before :each do
      #pending 'hoge'
      @chat = Skype::Chat.create 'echo123','hogehoge_001'
    end

    after :each do
      @chat.leave if @chat
    end

    it "Skype::Chat.findUsingBlob(@chat.get_blob) should raise error Skype::Error::API" do
      Skype::Chat.findUsingBlob(@chat.get_blob).should == @chat
      #ERROR 610 CHAT: FINDUSINGBLOB: No existing chat for given blob found or invalid blob
      #get_bolb = > ''
    end

    it "Skype::Chat.createUsingBlob(@chat.get_blob) should raise error Skype::Error::API" do
      Skype::Chat.createUsingBlob(@chat.get_blob).should == @chat
      #ERROR 611 CHAT: CREATEUSINGBLOB: Unable to create chat, invalid blob
      #get_bolb = > ''
    end

    it "get_blob should be instance of String and not empty" do
      blob = @chat.getBlob
      blob.should be_instance_of String
      blob.should_not be_empty
    end

    it "set_topic(string) should raise_error Skype::Error::API" do
      @chat.setTopic('TEST').should be_true
    end

    it "set_topic_xml(string) should raise error Skype::Error::API" do
      @chat.setTopicXML('<BLINK>topic is blinking</BLINK>').should be_true
    end

    it "set_options(integer) should be true" do
      lambda{@chat.setOptions(1)}.should raise_error Skype::Error::API
    end

    it "set_guid_lines(string) should be raise error Skype::Error::API" do
      lambda{@chat.setGuideLines('TEST')}.should raise_error Skype::Error::API
    end

    it "leave should raise Skype::Error::API" do
      @chat.leave.should be_true
      @chat = nil
    end

    it "join should raise error Skype::Error::API" do
      @chat.join.should be_true
    end

    it "acceptadd should should raise error Skype::Error::API" do
      @chat.acceptadd.should be_true
      #
    end

    it "disband should should be true" do
      lambda{@chat.disband}.should raise_error Skype::Error::API
    end

    it "set_password(string) should raise error Skype::Error::API" do
      @chat.setPassword('hogehoge').should be_true
    end

    it "enter_password(string) should raise error Skype::Error::API" do
      lambda{@chat.enterPassword('hogehoge')}.should raise_error Skype::Error::API
    end

    it "kick(string) should be true" do
      @chat.kick('echo123').should be_true
    end

    it "kick(user) should be true" do
      @chat.kick(Skype.user('echo123')).should be_true
    end

    it "kick_ban(string) should be true" do
      @chat.kickban('echo123').should be_true
    end

    it "kick_ban(user) should be true" do
      @chat.kickban(Skype.user('echo123')).should be_true
    end

  end
end

