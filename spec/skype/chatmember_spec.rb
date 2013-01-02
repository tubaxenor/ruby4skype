$LOAD_PATH << 'lib'
$LOAD_PATH << 'spec'
require 'skype'
require 'matcher_be_boolean'

describe Skype::ChatMember do
  before(:all) do
    Skype.init 'hogehogehoge'
    Skype.start_messageloop
    Skype.attach_wait
  end
  before(:each) do
    @chat = Skype::Chat.create 'echo123'
    @chat.send_message 'chat_member tests'
    @chatmember = @chat.get_member_objects.first
  end

  it "get_chat should be instance of Chat" do
    @chatmember.get_chat.should be_instance_of Skype::Chat
  end

  it "get_user should be instance of User" do
    @chatmember.get_user.should be_instance_of Skype::User
  end

  it 'get_role should match /^(CREATOR)|(MASTER)|(HELPER)|(USER)|(LISTENER)|(APPLICANT)$/' do
    @chatmember.get_role.should match /^(CREATOR)|(MASTER)|(HELPER)|(USER)|(LISTENER)|(APPLICANT)$/
  end

  it 'get_is_active? should be boolean' do
    @chatmember.get_is_active?.should be_boolean
  end

  it "can_set_role_to('MATER') should be true" do
    @chatmember.can_set_role_to?('MASTER').should be_true
  end

  it "set_role_to('MASTER') should raise error" do
    lambda{@chatmember.set_role_to('MASTER')}.should raise_error Skype::Error::API
  end
end

