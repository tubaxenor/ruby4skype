$LOAD_PATH << 'lib'
$LOAD_PATH << 'spec'
require 'skype'

describe Skype::MenuItem do
  before :all do
    Skype.init 'hogehogehoge'
    Skype.start_messageloop
    Skype.attach_wait
  end

  after :all do
    Skype.close
  end

  it "should,,," do
    pending 'menu_item obs?'
    flag = false
    menuitem = Skype::MenuItem.create(:id => 'testMenu', :context => 'CONTACT', :caption => 'testMenu') do |instance, context, user, context_id|
      menuitem.should == instance
      context.should be_instance_of String
      user.should be_instance_of Skype::User
      context_id.should be_nil
      flag = true
    end

    puts "click user context menu changeCap"

    menuitem.should be_instance_of Skype::MenuItem
    menuitem.setCaption('changeCap').should be_true
    menuitem.setHint('changeHint').should be_true
    menuitem.setEnabled(false).should be_true
    menuitem.setEnabled(true).should be_true
    timeout(60){sleep until flag}
    menuitem.delete.should be_true
  end

end

