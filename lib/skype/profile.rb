module Skype
  class Profile < AbstractObject
    OBJECT_NAME = "PROFILE"

    def initialize(id=nil)
      super nil
    end

    def self.new
      super nil
    end

    def self.notified msg
      if msg =~ /^([^ ]+) (.*)$/m
        property = P2M[$1]
        value = V2O[property] ? V2O[property].call($2) : $2
        instance = new
        instance.notified instance, property,value #if @@instance[self][id]

        #p [property,value,instance,@notify]
        #if @notify[nil]
        #  @notify[nil][nil].call instance, property, value if @notify[nil][nil]
        #  @notify[nil][value].call instance, property if @notify[nil][value]
        #end
        #if @notify[property]
        #  @notify[property][nil].call instance, value if @notify[property][nil]
        #  @notify[property][value].call instance if @notify[property][value]
        #end
      end
    end

    def get_pstn_balance() parse :pstn_balance, invoke_get("PSTN_BALANCE") end
    def_parser(:pstn_balance){|str| str._int}
    alias getPSTNBalance get_pstn_balance

    def get_pstn_balance_currency() invoke_get("PSTN_BALANCE_CURRENCY") end
    def_parser(:pstn_balance_currency)
    alias getPSTNBalanceCurrency get_pstn_balance_currency

    def get_fullname() invoke_get("FULLNAME") end
    def_parser(:fullname)
    alias getFullname get_fullname

    def get_birthday() parse :birthday, invoke_get("BIRTHDAY") end
    def_parser(:birthday){|yyyymmdd| (yyyymmdd =~ /(\d\d\d\d)(\d\d)(\d\d)/) ? Date.new($1.to_i,$2.to_i,$3.to_i) : nil}
    alias getBirthday get_birthday

    def get_sex() invoke_get("SEX") end
    def_parser(:sex)
    alias getSex get_sex

    def get_languages() parse :languages, invoke_get("LANGUAGES") end
    def_parser(:languages){|str| str.split(' ')}
    alias getLanguages get_languages

    def get_country() parse :country, invoke_get("COUNTRY") end
    def_parser(:country){|str| str.empty? ? str : str.split(' ', 2)[0]}
    alias getCountry get_country

    def get_ip_country() invoke_get("IPCOUNTRY") end
    def_parser(:ip_country,"IPCOUNTRY")
    alias getIPCountry get_ip_country

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

    def get_mood_text() invoke_get("MOOD_TEXT") end
    def_parser(:mood_text)
    alias getMoodText get_mood_text

    def get_rich_mood_text() invoke_get("RICH_MOOD_TEXT") end
    def_parser(:rich_mood_text)
    alias getRichMoodText get_rich_mood_text

    def get_timezone() parse :timezone, invoke_get("TIMEZONE") end
    def_parser(:timezone){|str| str._int}
    alias getTimezone get_timezone

    def get_call_apply_cf() parse :call_apply_cf, invoke_get("CALL_APPLY_CF") end
    def_parser(:call_apply_c_f){|str| str._flag}
    alias getCallApplyCF get_call_apply_cf

    def get_call_noanswer_timeout() parse :call_noanswer_timeout, invoke_get("CALL_NOANSWER_TIMEOUT") end
    def_parser(:call_noanswer_timeout){|str| str._int}
    alias getCallNoanswerTimeout get_call_noanswer_timeout

    def get_call_forward_rules() parse :call_forward_rules, invoke_get("CALL_FORWARD_RULES") end
    def_parser(:call_forward_rules){|str|
      cfs = str.split ' '
      cfs = cfs.map{ |cf|
        cf = cf.split ','
        cf[2] = Skype::User.new(cf[2]) unless cf[2] =~ /^\+/
        [cf[0].to_i, cf[1].to_i, (cf[2] =~ /^\+/ ? cf[2] : Skype::User.new(cf[2]))]
      }
    }
    alias getCallForwardRules get_call_forward_rules

    def get_call_send_to_vm() parse :call_send_to_vm, invoke_get("CALL_SEND_TO_VM") end
    def_parser(:call_send_to_vm,"CALL_SEND_TO_VM"){|str| str._flag}
    alias getCallSendToVM get_call_send_to_vm

    def get_sms_validated_numbers() parse :sms_validated_numbers, invoke_get("SMS_VALIDATED_NUMBERS") end
    def_parser(:sms_validated_numbers){|str| str.split(', ')}
    alias getSMSValidatedNumbers get_sms_validated_numbers

    def setFullname(name) invoke_set('FULLNAME', name); end
    def setBirthday(dateOrYear=nil, month=nil, day=nil)
      if dateOrYear.nil?
        val = ''
      else
        val = dateOrYear.class == Date ? dateOrYear.strftime('%Y%m%d') : sprintf("%04d%02d%02d",dateOrYear,month,day)
      end
      invoke_set('BIRTHDAY', val)
    end
    def setSex(sex) invoke_set('SEX', sex); end
    def setLanguages(*langs)
      invoke_set('LANGUAGES', langs.join(' '))
    end
    def setCountry(iso) invoke_set('COUNTRY', iso); end
    #def setIpcountry(val) invoke_set('IPCOUNTRY', val); end
    def setProvince(province) invoke_set('PROVINCE', province); end
    def setCity(city) invoke_set('CITY', city); end
    def setPhoneHome(numbers) invoke_set('PHONE_HOME', numbers); end
    def setPhoneOffice(numbers) invoke_set('PHONE_OFFICE', numbers); end
    def setPhoneMobile(numbers) invoke_set('PHONE_MOBILE', numbers); end
    def setHomepage(url) invoke_set('HOMEPAGE', url); end
    def setAbout(text) invoke_set('ABOUT', text); end
    def setMoodText(text) invoke_set('MOOD_TEXT', text); end
    def setRichMoodText(text) invoke_set('RICH_MOOD_TEXT', text); end
    def setTimezone(timezone) invoke_set('TIMEZONE', timezone); end
    def setCallApplyCF(flag)
      invoke_set('CALL_APPLY_CF', flag._str)
    end
    def setCallNoanswerTimeout(sec) invoke_set('CALL_NOANSWER_TIMEOUT', sec); end
    def setCallForwardRules(*rules)
      if rules[0] == nil
        invoke_set('CALL_FORWARD_RULES', '')
      else
        rules.map! do |rule|
          rule.join ','
        end
        rules = rules.join ' '
        invoke_set('CALL_FORWARD_RULES', rules)
      end
    end
    def setCallSendToVM(flag)
      invoke_set('CALL_SEND_TO_VM', flag._str)
    end

    alias set_fullname setFullname
    alias set_birthday setBirthday
    alias set_sex setSex
    alias set_languages setLanguages
    alias set_country setCountry
    #alias set_ipcountry setIpcountry
    alias set_province setProvince
    alias set_city setCity
    alias set_phone_home setPhoneHome
    alias set_phone_office setPhoneOffice
    alias set_phone_mobile setPhoneMobile
    alias set_homepage setHomepage
    alias set_about setAbout
    alias set_mood_text setMoodText
    alias set_rich_mood_text setRichMoodText
    alias set_timezone setTimezone
    alias set_call_apply_cf setCallApplyCF
    alias set_call_noanswer_timeout setCallNoanswerTimeout
    alias set_call_forward_rules setCallForwardRules
    alias set_call_send_to_vm setCallSendToVM

  end
end
