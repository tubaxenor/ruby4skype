$LOAD_PATH << 'lib'
$LOAD_PATH << 'spec'
require 'skype'

describe Skype::Profile do
  before :all do
    Skype.init'hogehogehoge'
    Skype.start_messageloop
    Skype.attach_wait
  end

  after :all do
    Skype.close
  end

  before(:each) do
    @profile = Profile.new
  end

  it "should desc" do
    # TODO
  end
end

