# -*- coding: utf-8 -*-
$LOAD_PATH << 'lib'

require 'spec/matcher_be_boolean'
require 'skype'
require 'timeout'

describe Skype do
  it "VERSION should 0.4.1" do
    Skype::VERSION.to_s.should == '0.4.1'
  end

  it "should init and attach and close" do
    Skype.init 'hoge'
    timeout(3){Skype.attach_wait}
    Skype.close
  end

  it "should more time attach and close" do
    Thread.abort_on_exception = true
    5.times do |i|
      Skype.init 'hoge'
      timeout(3){ Skype.attach_wait }
      Skype.close
    end
  end

  it "user(handle) should be instance of Skype::User" do
    Skype.user('hoge').should be_instance_of Skype::User
  end

  describe 'when attached' do
    before :each do
      Skype.init  'hoge'
      Skype.attach_wait
    end

    after :each do
      Skype.close
    end

    it "Skype::Chat should create.send_message" do
      Skype::Chat.create('echo123').send_message('hoge test')
    end

  end

end

describe Skype, 'general methods' do
  before :all do
    Skype.init 'hoge'
    Skype.attach_wait
  end

  after :all do
    Skype.close
  end

  it "ping should be true" do
    Skype.ping.should be_true
  end

  it "get_skype_version should match \d\.\d\.\d\.\d" do
    Skype.getSkypeVersion.should match /\d+\.\d+.\d+.\d+/
  end

  it "get_current_user_handle should be instance of String and not be empty" do
    Skype.getCurrentUserHandle.should be_instance_of String
    Skype.getCurrentUserHandle.should_not be_empty
  end

  it "get_user_status should match /^(UNKNOWN)|(ONLINE)|(OFFLINE)|(SKYPEME)|(AWAY)|(NA)|(DND)|(INVISIBLE)|(LOGGEDOUT)$/" do
    Skype.getUserStatus.should match /^(UNKNOWN)|(ONLINE)|(OFFLINE)|(SKYPEME)|(AWAY)|(NA)|(DND)|(INVISIBLE)|(LOGGEDOUT)$/
  end

  it "set_user_status(s) should == s" do
    s = Skype.getUserStatus
    Skype.setUserStatus(s).should == s
  end

  it "get_privilege should be boolean" do
    ['SkypeOut','SkypeIn','VOICEMAIL'].each do |user_privilege|
      Skype.getPrivilege(user_privilege).should be_boolean
    end
  end

  it "get_predictive_dialer_country should be instance of String and size 2" do
    pdCountry = Skype.getPredictiveDialerCountry
    pdCountry.should be_instance_of String
    pdCountry.size.should == 2
  end

  it "get_connstatus should match (OFFLINE)|(CONNECTING)|(PAUSING)|(ONLINE)" do
    Skype.getConnstatus.should match /^(OFFLINE)|(CONNECTING)|(PAUSING)|(ONLINE)$/
  end

  describe "device and file methods" do
    it "get_adudio_in should be instance of String and not be empty" do
      Skype.getAudioIn.should be_instance_of String
      Skype.getAudioIn.should_not be_empty
    end

    it "set_audio_in(device) should device" do
      device = Skype.getAudioIn
      Skype.setAudioIn(device).should == device
    end

    it "get_audio_out should be instance of String" do# and not be empty" do
      Skype.getAudioOut.should be_instance_of String
      #Skype.getAudioOut.should_not be_empty
    end

    it "set_audio_out(device) should device" do
      device = Skype.getAudioOut
      Skype.setAudioOut(device).should == device
    end

    it "get_ringer should be instance of String and not be empty" do
      Skype.getRinger.should be_instance_of String
      Skype.getRinger.should_not be_empty
    end

    it "set_ringer(device) should device" do
      pending "SET RINGER speaker => ERROR 50 cannot set device"
      device = Skype.getRinger
      Skype.setRinger(device).should == device
    end

    it "get_mute should be boolean" do
      Skype.getMute.should be_boolean
    end

    it "set_mute(flag) should flag"  do
      flag = Skype.getMute
      Skype.setMute(flag).should == flag
    end

    def prepare_avator &block
      path = File.dirname(File.expand_path(__FILE__ )) << '/skype_avatar.jpg'
      violated "exist #{path}" if test(?e, path)
      block.call path
      File.delete path
    end

    it "get_avator(path) should be nil and save jpg file" do
      prepare_avator do |path|
        Skype.getAvatar(path).should be_nil
        test(?e, path).should be_true
      end
    end

    it "set_avator(path) should path" do
      prepare_avator do |path|
        Skype.getAvatar(path)
        test(?e, path).should be_true
        Skype.setAvatar(path).should == path
      end
    end

    it "get_ringtone should be instance of String and not be empty" do
      Skype.getRingtone.should be_instance_of String
      Skype.getRingtone.should_not be_empty
    end

    it "set_ringtone(rt) should rt" do
      pending "SET RINGTONE 1 call_in: => ERROR 111 SET File not found"
      rt = Skype.getRingtone
      Skype.setRingtone(rt).should  rt
    end

    it "get_rigtone_status should be boolean" do
      Skype.getRingtoneStatus.should be_boolean
    end

    it "set_rigtone_status(flag) should flag" do
      flag = Skype.getRingtoneStatus
      Skype.setRingtoneStatus(flag).should == flag
    end

    it "get_pc_bspeaker should be boolean" do
      Skype.getPCSpeaker.should be_boolean
    end

    it "set_pc_speaker(flag) should flag" do
      flag = Skype.getPCSpeaker
      Skype.setPCSpeaker(flag).should == flag
    end

    it "get_agc should be boolean" do
      Skype.getAGC.should be_boolean
    end

    it "set_agc(flag) should boolean" do
      flag = Skype.getAGC
      Skype.setAGC(flag).should == flag
    end

    it "get_aec should be boolean" do
      Skype.getAEC.should be_boolean
    end

    it "set_aec(flag) should boolean" do
      flag = Skype.getAEC
      Skype.setAEC(flag).should == flag
    end

    it "reset_idle_timer.should be true" do
      Skype.resetIdleTimer.should be_true
    end

    it "get_auto_away should be boolean" do
      Skype.getAutoAway.should be_boolean
    end

    it "set_auto_away(flag) should flag" do
      flag = Skype.getAutoAway
      Skype.setAutoAway(flag).should == flag
    end

    it "get_video_in should be instance of String and not be empty" do
      Skype.getVideoIn.should be_instance_of String
    end

    it "set_video_in(string) should string" do
      string =Skype.getVideoIn
      Skype.setVideoIn(string) == string
    end
  end

  describe "UI methods" do
    before{pending 'uzai'}

    it "should focus" do
      Skype.focus.should be_true
    end

    it "should minimize" do
      Skype.minimize.should be_true
    end

    it "get_window_status should match /(NORMAL)|(MINIMIZED)|(MAXIMIZED)|(HIDDEN)/" do
      Skype.getWindowState.should match /(NORMAL)|(MINIMIZED)|(MAXIMIZED)|(HIDDEN)/
    end

    it "set_window_status(string) should string" do
      Skype.setWindowState('NORMAL').should == 'NORMAL'
    end

    it "should open_video_test" do
      Skype.openVideoTest.should be_true
    end

    it "should open_video_mail" do
      pending
      #assert_equal Skype.openVoiceMail(1)
      #IDが、、、後で調べる。
    end

    it "should open_add_friend(handle or user)" do
      Skype.openAddAFriend('echo123').should be_true
      Skype.openAddAFriend(Skype.user('echo123')).should be_true
    end

    it "should open_im(user, msg)" do
      Skype.openIM('echo123','this is a test').should be_true
    end

    it "should open_chat(chat)" do
      chat = Skype::Chat.create 'echo123'
      Skype.openChat(chat).should be_true
    end

    it "should open_file_transfer(path,*user)" do
      Skype.openFileTransfer(nil,Skype.user('kashi.9')).should be_true
    end

    it "should profile_live_tab" do
      Skype.openLiveTab.should be_true
    end

    it "should open_profile" do
      Skype.openProfile.should be_true
    end

    it "should open_user_info(user)" do
      Skype.openUserInfo('echo123').should be_true
    end

    it "should open_conference" do
      Skype.openConference.should be_true
    end

    it "should open_search" do
      Skype.openSearch.should be_true
    end

    it "should open_options(nil|'general'|'privacy'|'notifications'|'soundalerts'|'sounddevices'|'hotkeys'|'connection'|'voicemail'|'callforward'|'video'|'advanced')" do
      [nil,'general','privacy','notifications','soundalerts','sounddevices','hotkeys','connection','voicemail','callforward','video','advanced'].each do |page|
        Skype.openOptions(page).should be_true
      end
    end

    it "should open_call_history" do
      Skype.openCallHistory.should be_true
    end

    it "should open_contancts" do
      Skype.openContacts.should be_true
    end

    it "should open_dialpad" do
      Skype.openDialPad.should be_true
    end

    it "should open_send_contancts" do
      Skype.openSendContacts('hogehoge_001','hogehoge_002').should be_true
    end

    it "should open_blocked_users" do
      Skype.openBlockedUsers.should be_true
    end

    it "should open_import_contancts" do
      Skype.openImportContacts.should be_true
    end

    it "should open_getting_started" do
      Skype.openGettingStarted.should be_true
    end

    it "should open_authorization" do
      Skype.openAuthorization('hogehoge_1000'.should be_true)
    end

    it "should btn_pressed_released" do
      9.times do |i|
        Skype.BTNPressed(i).should be_true
        sleep 0.5
        Skype.BTNReleased(i).should be_true
      end
    end

    it "get_contacts_focused should be instance of Skype::User" do
      Skype.getContactsFocused.should be_instance_of Skype::User
    end

    it "get_ui_langualge should be instance of String and sieze 2" do
      Skype.getUILanguage.should be_instance_of String
      Skype.getUILanguage.size.should == 2
    end

    it "set_ui_langualge(string) should string" do
      uil = Skype.getUILanguage
      Skype.setUILanguage(uil).should == uil
    end

    it "get_wall_paper should be instance of String" do
      Skype.getWallPaper.should be_instance_of String
    end

    it "set_wall_paper(string) should string" do
      string = Skype.getWallPaper
      Skype.setWallPaper(string).should == string
    end

    it "get_silent_mode should be boolean" do
      Skype.getSilentMode.should be_boolean
    end

    it "set_silent_mode(flag) should flag" do
      silent_mode = Skype.getSilentMode
      Skype.setSilentMode(silent_mode).should == silent_mode
    end

  end

  describe "search methods" do

    it "search_frinends each should be instance of Skype::User" do
      Skype.searchFriends.each do |user|
        user.should be_instance_of Skype::User
      end
    end

    it "search_users(String) each should be instance of Skype::User" do
      Skype.searchUsers('echo123').each do |user|
        user.should be_instance_of Skype::User
      end
    end

    it "search_calls(String or User?) each should be instance of Skype::Call" do
      Skype.searchCalls('echo123').each do |call|
        call.should be_instance_of Skype::Call
      end
    end

    it "search_active_calls each should be instance of Skype::Call" do
      Skype.searchActiveCalls.each do |call|
        call.should be_instance_of Skype::Call
      end
    end

    it "search_missed_calls each should be instance of Skype::Call" do
      Skype.searchMissedCalls.each do |call|
        call.should be_instance_of Skype::Call
      end
    end
    
    it "search_smss should each should be instance of Skype::SMS" do
      Skype.searchSMSs.each do |sms|
        sms.should be_instance_of Skype::SMS
      end
    end

    it "search_missed_smss should each should be instance of Skype::Call" do
      Skype.searchMissedSMSs.each do |call|
        call.should be_instance_of Skype::Call
      end
    end

    it "search_voice_mail should each should be instance of Skype::Call" do
      Skype.searchVoiceMails.each do |call|
        call.should be_instance_of Skype::Call
      end
    end

    it "search_missed_voice_mail should each should be instance of Skype::VoiceMail" do
      Skype.searchMissedVoiceMails.each do |vm|
        vm.should be_instance_of Skype::VoiceMail
      end
    end

    #OBS
    #it "search_messages should" do
    #  Skype.searchMessages('skypetester').each do |msg|
    #     assert_instance_of(Skype::Message, msg)
    #  end
    #end

    it "search_missed_messages should each should be instance of Skype::Message" do
      Skype.searchMissedMessages.each do |msg|
        msg.should be_instance_of Skype::Message
      end
    end

    it "search_chats should each should be instance of Skype::Chat" do
      Skype.searchChats().each do |chat|
        chat.should be_instance_of Skype::Chat
      end
    end

    it "search_active_chats should each should be instance of Skype::Chat" do
      Skype.searchActiveChats().each do |chat|
        chat.should be_instance_of Skype::Chat
      end
    end

    it "search_missed_chats should each should be instance of Skype::Chat" do
      Skype.searchMissedChats.each do |chat|
        chat.should be_instance_of Skype::Chat
      end
    end

    it "search_recent_chats should each should be instance of Skype::Chat" do
      Skype.searchRecentChats().each do |chat|
        chat.should be_instance_of Skype::Chat
      end
    end

    it "search_bookmarked_chats should each should be instance of Skype::Chat" do
      Skype.searchBookMarkedChats().each do |chat|
        chat.should be_instance_of Skype::Chat
      end
    end

    it "search_chat_messages should each should be instance of Skype::ChatMessage" do
      Skype.searchChatMessages('echo123').each do |chat_message|
        chat_message.should be_instance_of Skype::ChatMessage
      end
    end

    it "search_missed_chat_messages should each should be instance of Skype::ChatMessage" do
      Skype.searchMissedChatMessages().each do |chat_message|
        chat_message.should be_instance_of Skype::ChatMessage
      end
    end

    it "search_users_waiting_my_authorization should each should be instance of Skype::User" do
      Skype.searchUsersWaitingMyAuthorization.each do |user|
        user.should be_instance_of Skype::User
      end
    end

    it "search_groups should each should be instance of Skype::Group" do
      Skype.searchGroups('ALL').each do |group|
        group.should be_instance_of Skype::Group
      end
    end

    it "search_file_transfers should each should be instance of Skype::FileTransfer" do
      Skype.searchFileTransfers().each do |file_transfer|
        file_transfer.should be_instance_of Skype::FileTransfer
      end
    end

    it "search_active_file_transfers should each should be instance of Skype::FileTransfer" do
      Skype.searchActiveFileTransfers().each do |file_transfer|
        file_transfer.should be_instance_of Skype::FileTransfer
      end
    end

  end

  describe 'clear history methods' do
    before{pending "I do not want clear"}

    it "clear_chat_history should be_true" do
      Skype.clearChatHistory.should be_true
    end

    it "clear_voice_mail_history should be true" do
      Skype.clearVoiceMailHistory.should be_true
    end

    it "clear_call_history('ALL') should be true" do
      Skype.clearCallHistory('ALL').should be_true
    end
  end
end
