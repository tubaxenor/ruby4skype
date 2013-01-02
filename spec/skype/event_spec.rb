$LOAD_PATH << 'lib'
$LOAD_PATH << 'spec'
require 'skype'
require 'timeout'

describe Skype::Event do
  before :all do
    Skype.init 'hogehogehoge'
    Skype.start_messageloop
    Skype.attach_wait
  end

  after :all do
    Skype.close
  end

  it "should event create" do
    pending 'skype event obs?'
    flag = false
    event = Skype::Event.create('testEvent','testEvent','Testhint') do
      flag = true
    end
    event.should be_instance_of Skype::Event

    puts 'click testEvent'

    timeout(60){sleep 1 until flag}
    
    event.delete.should be_true
  end

end

