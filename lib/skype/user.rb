module Skype
  class User < AbstractObject
    OBJECT_NAME = "USER"

    def get_handle() invoke_get("HANDLE") end
    def_parser(:handle)
    alias getHandle get_handle

    def get_fullname() invoke_get("FULLNAME") end
    def_parser(:fullname)
    alias getFullname get_fullname

    def get_birthday() parse :birthday, invoke_get("BIRTHDAY") end
    def_parser(:birthday){|yyyymmdd| (yyyymmdd =~ /(\d\d\d\d)(\d\d)(\d\d)/) ? Date.new($1.to_i,$2.to_i,$3.to_i) : nil}
    alias getBirthday get_birthday

    def get_sex() invoke_get("SEX") end
    def_parser(:sex)
    alias getSex get_sex

    def get_language() parse :language, invoke_get("LANGUAGE") end
    def_parser(:language){|str| str.empty? ? str : str.split(' ',2)[0]}
    alias getLanguage get_language

    def get_country() parse :country, invoke_get("COUNTRY") end
    def_parser(:country){|str| str.empty? ? str : str.split(' ',2)[0]}
    alias getCountry get_country

    def get_province() invoke_get("PROVINCE") end
    def_parser(:province)
    alias getProvince get_province

    def get_city() invoke_get("CITY") end
    def_parser(:city)
    alias getCity get_city

    def get_phone_home() invoke_get("PHONE_HOME") end
    def_parser(:phone_home)
    alias getPhoneHome get_phone_home

    def get_phone_office() invoke_get("PHONE_OFFICE") end
    def_parser(:phone_office)
    alias getPhoneOffice get_phone_office

    def get_phone_mobile() invoke_get("PHONE_MOBILE") end
    def_parser(:phone_mobile)
    alias getPhoneMobile get_phone_mobile

    def get_homepage() invoke_get("HOMEPAGE") end
    def_parser(:homepage)
    alias getHomepage get_homepage

    def get_about() invoke_get("ABOUT") end
    def_parser(:about)
    alias getAbout get_about

    def get_has_call_equipment?() parse :has_call_equipment, invoke_get("HASCALLEQUIPMENT") end
    def_parser(:has_call_equipment, "HASCALLEQUIPMENT"){|str| str == 'TRUE' ? true : false}
    alias getHasCallEquipment? get_has_call_equipment?

    def get_is_video_capable?() parse :is_video_capable, invoke_get("IS_VIDEO_CAPABLE") end
    def_parser(:is_video_capable){|str| str == 'TRUE' ? true : false}
    alias getIsVideoCapable? get_is_video_capable?

    def get_is_voicemail_capable?() parse :is_voicemail_capable, invoke_get("IS_VOICEMAIL_CAPABLE") end
    def_parser(:is_voicemail_capable){|str| str == 'TRUE' ? true : false}
    alias getIsVoicemailCapable? get_is_voicemail_capable?

    def get_buddy_status() parse :buddy_status, invoke_get("BUDDYSTATUS") end
    def_parser(:buddy_status, 'BUDDYSTATUS'){|str| str.to_i}
    alias getBuddyStatus get_buddy_status

    def get_is_authorized?() parse :is_authorized, invoke_get("ISAUTHORIZED") end
    def_parser(:is_authorized, 'ISAUTHORIZED'){|str| str == 'TRUE' ? true : false}
    alias getIsAuthorized? get_is_authorized?

    def get_is_blocked?() parse :is_blocked, invoke_get("ISBLOCKED") end
    def_parser(:is_blocked, 'ISBLOCKED'){|str| str == 'TRUE' ? true : false}
    alias getIsBlocked? get_is_blocked?

    def get_online_status() parse :online_status, invoke_get("ONLINESTATUS") end
    def_parser(:online_status, 'ONLINESTATUS')
    alias getOnlineStatus get_online_status

    def get_last_online_timestamp() parse :last_online_timestamp, invoke_get("LASTONLINETIMESTAMP") end
    def_parser(:last_online_timestamp, "LASTONLINETIMESTAMP"){|str| str.empty? ? nil : Time.at(str.to_i)}
    alias getLastOnlineTimestamp get_last_online_timestamp

    def get_can_leave_vm?() parse :can_leave_vm, invoke_get("CAN_LEAVE_VM") end
    def_parser(:can_leave_vm){|str| str == 'TRUE' ? true : false}
    alias getCanLeaveVM? get_can_leave_vm?

    def get_speed_dial() invoke_get("SPEEDDIAL") end
    def_parser(:speed_dial, 'SPEEDDIAL')
    alias getSpeedDial get_speed_dial

    def get_received_auth_request() invoke_get("RECEIVEDAUTHREQUEST") end
    def_parser(:received_auth_request,"RECEIVEDAUTHREQUEST")
    alias getReceivedAuthRequest get_received_auth_request

    def get_mood_text() invoke_get("MOOD_TEXT") end
    def_parser(:mood_text)
    alias getMoodText get_mood_text

    def get_rich_mood_text() invoke_get("RICH_MOOD_TEXT") end
    def_parser(:rich_mood_text)
    alias getRichMoodText get_rich_mood_text

    def get_aliases() invoke_get("ALIASES") end
    def_parser(:aliases)
    alias getAliases get_aliases

    def get_timezone() parse :timezone, invoke_get("TIMEZONE") end
    def_parser(:timezone){|str| str.to_i}
    alias getTimezone get_timezone

    def get_is_cf_active?() parse :is_cf_active, invoke_get("IS_CF_ACTIVE") end
    def_parser(:is_cf_active){|str| str == 'TRUE' ? true : false}
    alias getIsCFActive? get_is_cf_active?

    def get_nrof_authed_buddies() parse :nrof_authed_buddies, invoke_get("NROF_AUTHED_BUDDIES") end
    def_parser(:nrof_authed_buddies){|str| str.to_i}
    alias getNrofAuthedBuddies get_nrof_authed_buddies

    def get_displayname() invoke_get("DISPLAYNAME") end
    def_parser(:displayname)
    alias getDisplayname get_displayname
      
    def get_avatar(file_path) invoke("GET USER #{@id} AVATAR 1 #{file_path}") =~ /^USER #{@id} AVATAR \d+ (.+)$/ end
    def_parser :avatar, 'AVATAR 1'
    alias getAvatar get_avatar

    def set_buddy_status(statusCode, msg="")
      raise ArgumentErorr unless statusCode.to_i == 1 or statusCode.to_i == 2
      invoke_set('BUDDYSTATUS',"#{statusCode} #{msg}")
    end
    alias setBuddyStatus set_buddy_status
      
    def set_is_blocked(flag) invoke_set('ISBLOCKED', flag ? 'TRUE' : 'FALSE') end
    alias setIsBlocked set_is_blocked
      
    def set_is_authorized(flag) invoke_set('ISAUTHORIZED', flag ? 'TRUE' : 'FALSE') end
    alias setIsAuthorized set_is_authorized
      
    def set_speed_dial(numbers) invoke_set('SPEEDDIAL', numbers) end
    alias setSpeedDial set_speed_dial
      
    def set_displayname(name) invoke_set('DISPLAYNAME', name);end
    alias setDisplayname set_displayname


    def add_contactlist msg=""
      val = invoke_set("BUDDYSTATUS","2 #{msg}")
      val == 2 or val == 3
    end
    alias addContactlist add_contactlist

    def added_contactlist?
      val = get_buddy_status
      val == 3 or val == 2
    end
    alias addedContactlist? added_contactlist?
      
    def del_contactlist
      invoke_set("BUDDYSTATUS","1") == 1
    end
    alias delContactlist del_contactlist
  end
end
