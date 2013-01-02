require "forwardable"
require 'skype/os/notifier'
require "skype/object.rb"
require "skype/version.rb"
require "skype/user.rb"
require "skype/profile.rb"
require "skype/call.rb"
require "skype/message.rb"
require "skype/chat.rb"
require "skype/chatmessage.rb"
require "skype/chatmember.rb"
require "skype/voicemail.rb"
require "skype/sms.rb"
require "skype/application.rb"
require "skype/group.rb"
require "skype/filetransfer.rb"
require "skype/event.rb"
require "skype/menuitem.rb"
require "skype/os/etc.rb"
require 'skype/error'


module Skype
  extend AbstractObject::Notify
  extend AbstractObject::Get
  extend AbstractObject::Invokers
  extend AbstractObject::Parser
  
  #P2M = Hash.new{|hash,key| hash[key] = key}
  #V2O = Hash.new

  @property2symbol = Hash.new{|hash,key| hash[key] = key}
  @property2callback = Hash.new
  
  class << self

    def init app_name, os=RUBY_PLATFORM.downcase
      case os
      when /(mswin(?!ce))|(mingw)|(cygwin)|(bccwin)/
        require 'skype/os/windows.rb'
        init_os Skype::OS::Windows, app_name
      when /(mac)|(darwin)/
        require 'skype/os/mac.rb'
        init_os Skype::OS::Mac, app_name
      when /(linux)/
        require 'skype/os/linux.rb'
        init_os Skype::OS::Linux, app_name
      else
        raise Skype::NotImplementError.new("#{os} is unknown or not support OS")
      end
      @notify = Hash.new
      init_notifier
    end
    
    def init_os os_class, app_name
      @os = os_class.new app_name
      forward_os_methods        
    end
    
    def forward_os_methods
      self.class.extend Forwardable
      self.class.def_delegators(:@os,
      :invoke,
      :add_event,
      :del_event,
      :get_event,
      :exist_event?,
      :attach,
      :attach_wait,
      :polling,
      :start_messageloop,
      :messageloop,
      :messagepolling,
      :close
      )
      class << self
        alias addEvent add_event
        alias setEvent add_event
        alias delEvent del_event
        alias getEvent get_event
        alias existEvent? exist_event?
        alias attachWait attach_wait
      end
    end
    
    def init_notifier
      @notifier = Skype::OS::Notifier.new
      @os.set_notify_selector @notifier.method(:fire)
      @notifier.add nil, method(:notified)
      objectsInit
    end
    private :init_os, :forward_os_methods, :init_notifier

    def new
      init
      self
    end
    
    def os
      @os
    end
    
    def notified msg
      skypeProperty = nil
      propertyReg = '(?:' + [
        'CONTACTS FOCUSED',
        'RINGTONE 1 STATUS',
        'RINGTONE 1',
        '[^ ]+'
      ].join(')|(?:') + ')'
      
      if msg =~ /^(#{propertyReg}) (.+)$/m
        skypeProperty = $1; value = $2
        #property = self::P2M[skypeProperty].to_s.downcase.to_sym if self::P2M[skypeProperty].class == Symbol
        #value = self::V2O[skypeProperty].call value if self::V2O[skypeProperty]
        property = @property2symbol[skypeProperty].to_s.downcase.to_sym if @property2symbol[skypeProperty].class == Symbol
        value = @property2callback[skypeProperty].call value if @property2callback[skypeProperty]

        if @notify[nil]
          @notify[nil][nil].call property, value if @notify[nil][nil]
          @notify[nil][value].call property if @notify[nil][value]
        end
        if @notify[property]
          @notify[property][nil].call value if @notify[property][nil]
          @notify[property][value].call if @notify[property][value]
        end
      end
    end
    
    def objectsInit
      [Skype::User,Skype::Profile,Skype::Call,Skype::Message,Skype::Chat,Skype::ChatMessage,Skype::ChatMember,Skype::VoiceMail,Skype::SMS,Skype::Application,Skype::Group,Skype::FileTransfer,Skype::Event,Skype::MenuItem].each do |klass|
        #@os.add_notify /^#{klass::OBJECT_NAME} (.+)$/m, klass.method(:notified)
        @notifier.add /^#{klass::OBJECT_NAME} (.+)$/m, klass.method(:notified)
      end
    end
    
    def user(id) Skype::User.new(id) ; end
    
    def call(id) Skype::Call.new(id) ; end
    
    #def Profile() Skype::Profile.new nil ; end
    
    #def profile() Skype::Profile.new nil ; end
    
    def chat(id) Skype::Chat.new(id) ; end
    
    def chatMessage(id) Skype::ChatMessage.new(id) ; end
    
    def chatMember(id) Skype::ChatMember.new(id) ; end
    
    #def message(id) Skype::Message.new(id) ; end
    
    def voiceMail(id) Skype::VoiceMail.new(id) ; end
    
    def sms(id) Skype::SMS.new(id) ; end
    
    def app(id) Skype::Application.new(id) ; end
    
    def group(id) Skype::Group.new(id) ; end

    def fileTransfer(id) Skype::FileTransfer.new(id) ; end
    
    def event(id) Skype::Event.new(id) ; end
    
    def menuItem(id) Skype::MenuItem.new(id) ; end
    
  end

  class << self
    #@property2symbol = Hash.new{|hash,key| hash[key] = key}
    #@property2callback = Hash.new
    attr_reader :property2symbol, :property2callback

    #General
    extend AbstractObject::Get
    
    def get_skype_version() invoke_get("SKYPEVERSION") end
    def_parser(:skype_version,"SKYPEVERSION")
    alias getSkypeVersion get_skype_version

    def get_current_user_handle() invoke_get("CURRENTUSERHANDLE") end
    def_parser(:current_user_handle,"CURRENTUSERHANDLE")
    alias getCurrentUserHandle get_current_user_handle

    def get_user_status() invoke_get("USERSTATUS") end
    def_parser(:user_status,"USERSTATUS")
    alias getUserStatus get_user_status

    # privilege SkypeOut | SkypeIn | VoiceMail
    def get_privilege(privilege) parse :privilege, invoke_get("PRIVILEGE #{privilege}") end
    def_parser(:privilege){|str| str._flag}
    alias getPrivilege get_privilege

    def set_user_status(status) invoke_set("USERSTATUS", status) end
    alias setUserStatus set_user_status
    
    def get_predictive_dialer_country() invoke_get("PREDICTIVE_DIALER_COUNTRY") end
    def_parser(:predictive_dialer_country)
    alias getPredictiveDialerCountry get_predictive_dialer_country

    def get_connstatus() invoke_get("CONNSTATUS") end
    def_parser(:connstatus)
    alias getConnstatus get_connstatus

    def get_audio_in() invoke_get("AUDIO_IN") end
    def_parser(:audio_in)
    alias getAudioIn get_audio_in

    def set_audio_in(device) invoke_set "AUDIO_IN", device  end
    alias setAudioIn set_audio_in

    def get_audio_out() invoke_get("AUDIO_OUT") end
    def_parser(:audio_out)
    alias getAudioOut get_audio_out

    def set_audio_out(device) invoke_set "AUDIO_OUT", device ; end
    alias setAudioOut set_audio_out

    def get_ringer() invoke_get("RINGER") end
    def_parser(:ringer)
    alias getRinger get_ringer

    def set_ringer(device) invoke_set("RINGER", device) ; end
    alias setRinger set_ringer

    def get_mute() parse :mute, invoke_get("MUTE") end
    def_parser(:mute){|str| str._flag}
    alias getMute get_mute

    def set_mute(flag) parse :mute, invoke_set("MUTE", flag._swi) ;end
    alias setMute set_mute

    def get_avatar(filePath, num=1) invoke_get("AVATAR #{num} #{filePath}") end
    alias getAvatar get_avatar

    def set_avatar(filePath, idx="", num=1)
      invoke_set("AVATAR", "#{num} #{filePath}#{idx.empty? ? '' : ':'+idx.to_s}").split(' ')[1..-1].join(' ')
    end
    alias setAvatar set_avatar

    def get_ringtone(id=1) invoke_get("RINGTONE #{id}") end
    def_parser(:ringtone, "RINGTONE 1")
    alias getRingtone get_ringtone

    def set_ringtone(filePath, idx="", id=1) invoke_set("RINGTONE","#{id} #{filePath}:#{idx}")  end
    alias setRingtone set_ringtone

    def get_ringtone_status(id=1)
      invoke("GET RINGTONE #{id} STATUS") =~ /RINGTONE #{id} ((ON)|(OFF))/
      $2._flag
    end
    def_parser(:ringtone_status, "RINGTONE 1 STATUS" ){|str| str._flag}
    alias getRingtoneStatus get_ringtone_status

    def set_ringtone_status(flag, id=1)
      invoke("SET RINGTONE #{id} STATUS #{flag._swi}") =~ /RINGTONE #{id} ((ON)|(OFF))/
      $2._flag
    end
    alias setRingtoneStatus set_ringtone_status

    def get_pc_speaker() parse :pc_speaker, invoke_get('PCSPEAKER') end
    def_parser(:pc_speaker, 'PCSPEAKER'){|str| str._flag}
    alias getPCSpeaker get_pc_speaker

    def set_pc_speaker(flag) parse :pc_speaker, invoke_set("PCSPEAKER", flag._swi) ; end
    alias setPCSpeaker set_pc_speaker
  
    def get_agc() parse :agc, invoke_get("AGC") end
    def_parser(:agc){|str| str._flag}
    alias getAGC get_agc

    def set_agc(flag) parse :agc, invoke_set("AGC", flag._swi) end
    alias setAGC set_agc

    def get_aec() parse :aec, invoke_get("AEC") end
    def_parser(:aec){|str| str._flag}
    alias getAEC get_aec

    def set_aec(flag) parse :aec, invoke_set("AEC", flag._swi) end
    alias setAEC set_aec

    #notice?
    def reset_idle_timer() invoke("RESETIDLETIMER") == "RESETIDLETIMER" end
    def_parser :reset_idle_timer, 'RESETIDLETIMER'
    alias resetIdleTimer reset_idle_timer

    def get_auto_away() parse :auto_away, invoke_get("AUTOAWAY") end
    def_parser(:auto_away,"AUTOAWAY"){|str|
      case str
      when /ON/
        true
      when /OFF/
        false
      else
        str
      end
    }
    alias getAutoAway get_auto_away

    def set_auto_away(flag) parse :auto_away, invoke_set('AUTOAWAY', flag._swi) end
    alias setAutoAway set_auto_away

    def get_video_in() invoke_get("VIDEO_IN") end
    def_parser(:video_in)
    alias getVideoIn get_video_in

    def set_video_in(device) invoke_set("VIDEO_IN", device) end
    alias setVideoIn set_video_in
    
    def ping
      invoke("PING") == "PONG"
    end

    #UserInterFace

    def focus() invoke('FOCUS') == 'FOCUS' end
    
    def minimize() invoke('MINIMIZE') == 'MINIMIZE' end
    
    def get_window_state() invoke_get("WINDOWSTATE") end
    def_parser(:window_state,"WINDOWSTATE")
    alias getWindowState get_window_state

    def set_window_state(state) invoke_set("WINDOWSTATE", state) end
    alias setWindowState set_window_state
    
    def open prop, *value
      begin
        "OPEN #{prop} #{value.join(' ')}".rstrip == invoke("OPEN #{prop} #{value.join(' ')}".rstrip)
      rescue => e
        e.backtrace.shift
        raise e
      end
    end
    
    def openVideoTest id=''
      open 'VIDEOTEST', id
    end
    alias open_video_test openVideoTest
    
    def openVoiceMail id
      open 'VOICEMAIL', id
    end
    alias open_voice_mail openVoiceMail
    
    def openAddAFriend user=''
      open 'ADDAFRIEND', user.to_s
    end
    alias open_add_a_friend openAddAFriend
    
    def openIM user, msg=''
      open 'IM', user.to_s, msg
    end
    alias open_im openIM
    
    def openChat chat
      open 'CHAT', chat
    end
    alias open_chat openChat
    
    def openFileTransfer path=nil, *users
      open 'FILETRANSFER', "#{users.join(', ')}",path ? "IN #{path}" : ''
    end
    alias open_file_trasfer openFileTransfer
    
    def openLiveTab
      open 'LIVETAB'
    end
    alias open_live_tab openLiveTab
    
    def openProfile
      open 'PROFILE'
    end
    alias open_profile openProfile
    
    def openUserInfo user
      open 'USERINFO', user.to_s
    end
    alias open_user_info openUserInfo
    
    def openConference
      open 'CONFERENCE'
    end
    alias open_conference openConference
    
    def openSearch
      open 'SEARCH'
    end
    alias open_search openSearch
    
    def openOptions page=''
      open 'OPTIONS', page
    end
    alias open_options openOptions
    
    def openCallHistory
      open 'CALLHISTORY'
    end
    alias open_call_history openCallHistory
    
    def openContacts
      open 'CONTACTS'
    end
    alias open_contancts openContacts
    
    def openDialPad
      open 'DIALPAD'
    end
    alias open_dial_pad openDialPad
    
    def openSendContacts *users
      open 'SENDCONTACTS', users.join(' ')
    end
    alias open_send_contancts openSendContacts
    
    def openBlockedUsers
      open 'BLOCKEDUSERS'
    end
    alias open_blocked_users openBlockedUsers
    
    def openImportContacts
      open 'IMPORTCONTACTS'
    end
    alias open_import_contacts openImportContacts
     
    def openGettingStarted
      open 'GETTINGSTARTED'
    end
    alias open_getting_started openGettingStarted
    
    def openAuthorization user
      open 'AUTHORIZATION', user
    end
    alias open_authorization openAuthorization
    
    def BTNPressed key
      invoke_echo "BTN_PRESSED #{key}"
    end
    alias btnp_presse BTNPressed
    
    def BTNReleased key
      invoke_echo "BTN_RELEASED #{key}"
    end
    alias btn_released BTNReleased

    def get_contacts_focused() parse :contacts_focused, invoke_get("CONTACTS_FOCUSED") end
    def_parser(:contacts_focused){|str| Skype::User.new str}
    alias getContactsFocused get_contacts_focused
  
    def get_ui_language() invoke_get("UI_LANGUAGE") end
    def_parser(:ui_language,"UI_LANGUAGE")
    alias getUILanguage get_ui_language
  
    def set_ui_language(lang) invoke_set("UI_LANGUAGE", lang) end
    alias setUILanguage set_ui_language

    def get_wallpaper() invoke_get("WALLPAPER") end
    def_parser(:wallpaper)
    alias getWallPaper get_wallpaper
  
    def set_wallpaper(filePath) invoke_set('WALLPAPER', filePath) end
    alias setWallpaper set_wallpaper

    def get_silent_mode() parse :silent_mode, invoke_get("SILENT_MODE") end
    def_parser(:silent_mode){|str| str._flag}
    alias getSilentMode get_silent_mode
   
    def set_silent_mode(flag) parse :silent_mode, invoke_set('SILENT_MODE', flag._swi) end
    alias setSilentMode set_silent_mode
  
    #Search
  
    def search prop, preffix=prop, val=''
      ret = invoke "SEARCH #{prop} #{val}"
      ret =~ /^#{preffix} (.+)$/
      if $1
        $1.split(', ')
      else
        []
      end
    end
    
    def searchFriends
      search('FRIENDS','USERS').map do |handle|
        user(handle)
      end
    end
    
    def searchUsers target
      search('USERS','USERS',target).map do |handle|
        user(handle)
      end
    end
    
    def searchCalls target
      search('CALLS','CALLS',target).map do |id|
        call(id)
      end
    end
    
    def searchActiveCalls
      search('ACTIVECALLS','CALLS').map do |id|
        call(id)
      end
    end
    
    def searchMissedCalls
      search('MISSEDCALLS','CALLS').map do |id|
        call(id)
      end
    end
    
    def searchSMSs
      search('SMSS').map do |id|
        sms(id)
      end
    end
    
    def searchMissedSMSs
      search('MISSEDSMSS','SMSS').map do |id|
        sms(id)
      end
    end
    
    def searchVoiceMails
      search('VOICEMAILS').map do |id|
        voiceMail(id)
      end
    end
    
    def searchMissedVoiceMails
      search('MISSEDVOICEMAILS','VOICEMAILS').map do |id|
        voiceMail id
      end
    end
      
    def searchMessages(target='')
      search('MESSAGES', 'MESSAGES', target).map do |id|
        message id
      end
    end
    
    def searchMissedMessages
      search('MISSEDMESSAGES','MESSAGES').map do |id|
        message id
      end
    end
    
    def searchChats
      search('CHATS').map do |id|
        chat id
      end
    end
    
    def searchActiveChats
      search('ACTIVECHATS','CHATS').map do |id|
        chat id
      end
    end
    
    def searchMissedChats
      search('MISSEDCHATS','CHATS').map do |id|
        chat id
      end
    end
    
    def searchRecentChats
      search('RECENTCHATS','CHATS').map do |id|
        chat id
      end
    end
    
    def searchBookMarkedChats
      search('BOOKMARKEDCHATS','CHATS').map do |id|
        chat id
      end
    end
    
    def searchChatMessages target=''
      search('CHATMESSAGES','CHATMESSAGES', target).map do |id|
        chatMessage id
      end
    end
    
    def searchMissedChatMessages
      search('MISSEDCHATMESSAGES','CHATMESSAGES').map do |id|
        chatMessage id
      end
    end
    
    def searchUsersWaitingMyAuthorization
      search('USERSWAITINGMYAUTHORIZATION','USERS').map do |handle|
        user handle
      end
    end
    
    def searchGroups type=''
      search('GROUPS','GROUPS',type).map do |id|
        group id
      end
    end
    
    def searchFileTransfers
      search('FILETRANSFERS').map do |id|
        fileTransfer id
      end
    end
    
    def searchActiveFileTransfers
      search('ACTIVEFILETRANSFERS','FILETRANSFERS').map do |id|
        fileTransfer id
      end
    end
    
    alias search_friends searchFriends
    alias search_users searchUsers
    alias search_calls searchCalls
    alias search_active_calls searchActiveCalls
    alias search_missed_calls searchMissedCalls
    alias search_smss searchSMSs
    alias search_missed_smss searchMissedSMSs
    alias search_voice_mails searchVoiceMails
    alias search_missed_voice_mails searchMissedVoiceMails
    alias search_messages searchMessages
    alias search_missed_messages searchMissedMessages
    alias search_chats searchChats
    alias search_active_chats searchActiveChats
    alias search_missed_chats searchMissedChats
    alias search_recent_chats searchRecentChats
    alias search_book_marked_chats searchBookMarkedChats
    alias search_chat_messages searchChatMessages
    alias search_missed_chat_messages searchMissedChatMessages
    alias search_users_waiting_my_authorization searchUsersWaitingMyAuthorization
    alias search_groups searchGroups
    alias search_file_transfers searchFileTransfers
    alias search_active_file_transfers searchActiveFileTransfers

    #History
  
    def clearChatHistory() invoke('CLEAR CHATHISTORY') == 'CLEAR CHATHISTORY' ; end 
    
    def clearVoiceMailHistory() invoke('CLEAR VOICEMAILHISTORY') == 'CLEAR VOICEMAILHISTORY' ; end
    
    def clearCallHistory(type, handle='')
      invoke("CLEAR CALLHISTORY #{type} #{handle}") == "CLEAR CALLHISTORY #{type} #{handle}".rstrip
    end
    alias clear_chat_history clearChatHistory
    alias clear_voice_mail_history clearVoiceMailHistory
    alias clear_call_history clearCallHistory
  
    def_parser :call_history_changed, 'CALLHISTORYCHANGED'
    def_parser :im_history_changed, 'IMHISTORYCHANGED'
  end
end
