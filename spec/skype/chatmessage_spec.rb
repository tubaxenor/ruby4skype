$LOAD_PATH << 'lib'
$LOAD_PATH << 'spec'
require 'skype'
require 'matcher_be_boolean'

describe Skype::ChatMessage do

  before :all do
    Skype.init 'hogehogehoge'
    Skype.start_messageloop
    Skype.attach_wait
  end

  before(:each) do
    @chat = Skype::Chat.create('echo123', 'fk.8600gt')
    @chatmessage = @chat.send_message 'chatmessage test'
  end

  after do
    @chat.leave
  end

  it "get_timestamp shoulb be instance of Time" do
    @chatmessage.get_timestamp.should be_instance_of Time
  end

  it "get_from should be instance of User" do
    @chatmessage.get_from.should be_instance_of Skype::User
  end

  it "get_from_dispname should be instance of String" do
    @chatmessage.get_from_dispname.should be_instance_of String
  end

  it "get_type should match /(SETTOPIC)|(SAID)|(ADDEDMEMBERS)|(SAWMEMBERS)|(CREATEDCHATWITH)|(LEFT)|(POSTEDCONTACTS)|(GAP_IN_CHAT)|(SETROLE)|(KICKED)|(KICKBANNED)|(SETOPTIONS)|(SETPICTURE)|(SETGUIDELINES)|(JOINEDASAPPLICANT)|(UNKNOWN)/" do
    @chatmessage.get_type.should match /(SETTOPIC)|(SAID)|(ADDEDMEMBERS)|(SAWMEMBERS)|(CREATEDCHATWITH)|(LEFT)|(POSTEDCONTACTS)|(GAP_IN_CHAT)|(SETROLE)|(KICKED)|(KICKBANNED)|(SETOPTIONS)|(SETPICTURE)|(SETGUIDELINES)|(JOINEDASAPPLICANT)|(UNKNOWN)/
  end

  it 'get_status should match /(SENDING)|(SENT)|(RECEIVED)|(READ)/' do
    @chatmessage.get_status.should match /(SENDING)|(SENT)|(RECEIVED)|(READ)/
  end

  it 'get_leave_reason should nil or match /(USER_NOT_FOUND)|(USER_INCAPABLE)|(ADDER_MUST_BE_FRIEND)|(ADDED_MUST_BE_AUTHORIZED)|(UNSUBSCRIBE)/' do
    @chatmessage.get_leave_reason.should be_nil
    pending 'this test need type LEFT'
    @chatmessage.get_leave_reason.should match /(USER_NOT_FOUND)|(USER_INCAPABLE)|(ADDER_MUST_BE_FRIEND)|(ADDED_MUST_BE_AUTHORIZED)|(UNSUBSCRIBE)/
  end

  it 'get_chat should be instance of Chat' do
    @chatmessage.get_chat.should be_instance_of Skype::Chat
  end

  it 'get_users each should be instance of User' do
    @chatmessage.get_users.each{|user| user.should be_instance_of Skype::User}
  end

  it 'get_is_editable? should be boolean' do
    @chatmessage.get_is_editable?.should be_boolean
  end

  it 'get_edited_by should be nil or instance of User' do
    @chatmessage.get_edited_by.should be_nil
    @chatmessage.set_body('testEdit')
    @chatmessage.get_edited_by.should be_instance_of Skype::User
  end

  it 'get_edited_timestamp should be nil or instance of Time' do
    @chatmessage.get_edited_timestamp.should be_instance_of Time
  end

  it 'get_option should be kind of Integer' do
    @chatmessage.get_options.should be_kind_of Integer
  end

  it 'get_role should match /(CREATOR)|(MASTER)|(HELPER)|(USER)|(LISTENER)|(APPLICANT)|(UNKNOWN)/' do
    @chatmessage.get_role.should match /(CREATOR)|(MASTER)|(HELPER)|(USER)|(LISTENER)|(APPLICANT)|(UNKNOWN)/
  end

  it 'set_body("hoge") should be_true and get_body should "hoge"' do
    @chatmessage.set_body('hoge').should be_true
    @chatmessage.get_body.should == 'hoge'
  end

  it 'set_seen should be true' do
    @chatmessage.set_seen.should be_true
  end

end
