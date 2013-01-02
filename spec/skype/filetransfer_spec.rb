$LOAD_PATH << 'lib'
$LOAD_PATH << 'spec'
require 'skype'

describe Skype::FileTransfer do
  before :all do
    Skype.init 'hogehogehoge'
    Skype.start_messageloop
    Skype.attach_wait
  end

  before(:each) do
    @filetransfer = Skype.searchFileTransfers[0]
    pending 'a file_trasfer is nothing.' unless @filetransfer
  end

  after :all do
    Skype.close
  end

  it 'get_type should match /(INCOMING)|(OUTGOING)/' do
    @filetransfer.get_type.should match /(INCOMING)|(OUTGOING)/
  end

  it 'get_status should match /(NEW)|(WAITING_FOR_ACCEPT)|(CONNECTING)|(TRANSFERRING)|(TRANSFERRING_OVER_RELAY)|(PAUSED)|(REMOTELY_PAUSED)|(CANCELLED)|(COMPLETED)|(FAILED)/' do
    @filetransfer.get_status.should match /(NEW)|(WAITING_FOR_ACCEPT)|(CONNECTING)|(TRANSFERRING)|(TRANSFERRING_OVER_RELAY)|(PAUSED)|(REMOTELY_PAUSED)|(CANCELLED)|(COMPLETED)|(FAILED)/
  end

  it 'get_failure_reason /(SENDER_NOT_AUTHORIZED)|(REMOTELY_CANCELLED)|(FAILED_READ)|(FAILED_REMOTE_READ)|(FAILED_WRITE)|(FAILED_REMOTE_WRITE)|(REMOTE_DOES_NOT_SUPPORT_FT)|(REMOTE_OFFLINE_FOR_TOO_LONG)|(UNKNOWN)/' do
    @filetransfer.get_failure_reason.should match /(SENDER_NOT_AUTHORIZED)|(REMOTELY_CANCELLED)|(FAILED_READ)|(FAILED_REMOTE_READ)|(FAILED_WRITE)|(FAILED_REMOTE_WRITE)|(REMOTE_DOES_NOT_SUPPORT_FT)|(REMOTE_OFFLINE_FOR_TOO_LONG)|(UNKNOWN)/
  end

  it 'get_partner should be instance of User' do
    @filetransfer.get_partner.should be_instance_of Skype::User
  end

  it 'get_partner_dispname should be instance of String' do
    @filetransfer.get_partner_dispname.should be_instance_of String
  end

  it 'get_start_time should be instance of Time' do
    @filetransfer.get_start_time.should be_instance_of Time
  end

  it 'get_finish_time should be instance of Time' do
    @filetransfer.get_finish_time.should be_instance_of Time
  end

  it 'get_file_path should be instance of String' do
    @filetransfer.get_file_path.should be_instance_of String
  end

  it 'get_file_size should kind of Numeric' do
    @filetransfer.get_file_size.should be_kind_of Numeric
  end

  it 'get_bytes_per_second should be kind of Numeric' do
    @filetransfer.get_bytes_per_second.should be_kind_of Numeric
  end

  it 'get_bytes_transferred should be kind of Numeric' do
    @filetransfer.get_bytes_transferred.should be_kind_of Numeric
  end

end

