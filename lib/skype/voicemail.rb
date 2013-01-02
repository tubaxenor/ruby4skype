module Skype
  class VoiceMail < AbstractObject
    OBJECT_NAME = "VOICEMAIL"
      
    def self.create target
      Skype.invoke "CALLVOICEMAIL #{target}"
    end
      
    def self.open id
      Skype.invoke "OPEN VOICEMAIL #{id}"
    end
      
    def get_type() invoke_get("TYPE") end
    def_parser(:type)
    alias getType get_type

    def get_partner() parse :partner, invoke_get("PARTNER_HANDLE") end
    def_parser(:partner,"PARTNER_HANDLE"){|str| Skype::User.new str}
    alias getPartner get_partner

    def get_partner_dispname() invoke_get("PARTNER_DISPNAME") end
    def_parser(:partner_dispname)
    alias getPartnerDispname get_partner_dispname

    def get_status() invoke_get("STATUS") end
    def_parser(:status)
    alias getStatus get_status

    def get_failure_reason() invoke_get("FAILUREREASON") end
    def_parser(:failure_reason,"FAILUREREASON")
    alias getFailureReason get_failure_reason

    def get_timestamp() parse :timestamp, invoke_get("TIMESTAMP") end
    def_parser(:timestamp){|str| str.empty? ? nil : Time.at(str.to_i)}
    alias getTimestamp get_timestamp

    def get_duration() parse :duration, invoke_get("DURATION") end
    def_parser(:duration){|str| str.to_i}
    alias getDuration get_duration

    def get_allowed_duration() parse :allowed_duration, invoke_get("ALLOWED_DURATION") end
    def_parser(:allowed_duration){|str| str.to_i}
    alias getAllowedDuration get_allowed_duration
    #def alter action
    #  @@skypeApi.invoke "ALTER VOICEMAIL #{id} #{action}"
    #end
      
    def start_playback() invoke_alter "STARTPLAYBACK" end
    alias startPlayback start_playback

    def stop_playback() invoke_alter "STOPPLAYBACK" end
    alias stopPlayback stop_playback

    def upload() invoke_alter "UPLOAD" end

    def download() invoke_alter "DOWNLOAD" end
        
    def start_recording() invoke_alter "STARTRECORDING" end
    alias startRecording start_recording

    def stop_recording() invoke_alter "STOPRECORDING" end
    alias stopRecording stop_recording

    def delete() invoke_alter "DELETE" end
      
  end
end
