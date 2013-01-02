$LOAD_PATH << 'lib'
require 'skype'

describe Skype::Application do
  before(:all) do
    Skype.init 'hogehogehoge'
    Skype.start_messageloop
    Skype.attach_wait
  end

  after :all do
    Skype.close
  end

  before :each do
    @app = Skype::Application.new('testApp')
    @app.create
  end

  after :each do
    @app.delete unless @app.nil?
  end

  it 'get_connectable each should be instance of User' do
    pending 'connectable empty' if @app.get_connectable.empty?
    @app.get_connectable.each{|user| user.should be_instance_of Skype::User}
  end

  it 'get_connecting each should be instance of User' do
    pending 'connection empty' if @app.get_connecting.empty?
    @app.get_connecting.each{|user| user.should be_instance_of Skype::User}
  end

  it 'get_streams each should be instance of Stream' do
    pending 'streams empty' if @app.get_streams.empty?
    @app.get_streams.each{|stream| stream.should be_instance_of Skype::Stream}
  end

  it 'get_sending each should {:stream,:bytes}' do
    pending 'sending empty' if @app.get_sending.empty?
    @app.get_sending.each{|hash|
      hash[:stream].should be_instance_of Skype::Stream
      hash[:bytes].should be_kind_of Integer
    }
  end

  it 'get_received each should {:stream,:bytes}' do
    pending 'received empty' if @app.get_received.empty?
    @app.get_received.each{|hash|
      hash[:stream].should be_instance_of Skype::Stream
      hash[:bytes].should be_kind_of Integer
    }
  end

  it 'connect should be true' do
    @app.connect('echo123').should be_true
  end

  it 'write should be true' do
    pending 'need connection stream'
    @app.write(stream,msg).should be_true
  end

    #assert(app.datagram(stream,msg))
    #assert_instance_of(String, app.read())
    #assert(app.disconnect(stram))

  it 'delete should be true' do
    @app.delete.should be_true
    @app = nil
  end

end

