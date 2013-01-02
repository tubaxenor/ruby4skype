module Skype
  class Call < AbstractObject
    OBJECT_NAME = "CALL"

    def self.create *targets
      res = (Skype.invoke_one "CALL " + targets.join(", "),"CALL").split(" ")
      #return Skype::Call.new(res[0]),res[2]
      new res[0]
    end

    def get_timestamp() parse :timestamp, invoke_get("TIMESTAMP") end
    def_parser(:timestamp){|str| str.empty? ? nil : Time.at(str.to_i)}
    alias getTimestamp get_timestamp

    def get_partner() parse :partner, invoke_get("PARTNER_HANDLE") end
    def_parser(:partner,'PARTNER_HANDLE'){|str| Skype::User.new str}
    alias getPartner get_partner

    def get_partner_dispname() invoke_get("PARTNER_DISPNAME") end
    def_parser(:partner_dispname)
    alias getPartnerDispname get_partner_dispname

    def get_target_identity() invoke_get("TARGET_IDENTITY") end
    def_parser(:target_identity)
    alias getTargetIdentity get_target_identity

    def get_conf_id() parse :conf_id, invoke_get("CONF_ID") end
    def_parser(:conf_id){|str| str.to_i}
    alias getConfID get_conf_id

    def get_type() invoke_get("TYPE") end
    def_parser(:type)
    alias getType get_type

    def get_status() invoke_get("STATUS") end
    def_parser(:status)
    alias getStatus get_status

    def get_video_status() invoke_get("VIDEO_STATUS") end
    def_parser(:video_status)
    alias getVideoStatus get_video_status

    def get_video_send_status() invoke_get("VIDEO_SEND_STATUS") end
    def_parser(:video_send_status)
    alias getVideoSendStatus get_video_send_status

    def get_video_receive_status() invoke_get("VIDEO_RECEIVE_STATUS") end
    def_parser(:video_receive_status)
    alias getVideoReceiveStatus get_video_receive_status

    def get_failure_reason() parse :failure_reason, invoke_get("FAILUREREASON") end
    def_parser(:failure_reason,'FAILUREREASON'){|str| str.to_i}
    alias getFailureReason get_failure_reason

    #getter :Subject, 'SUBJECT'

    def get_pstn_number() invoke_get("PSTN_NUMBER") end
    def_parser(:pstn_number)
    alias getPSTNNumber get_pstn_number

    def get_duration() parse :duration, invoke_get("DURATION") end
    def_parser(:duration){|str| str.to_i}
    alias getDuration get_duration

    def get_pstn_status() invoke_get("PSTN_STATUS") end
    def_parser(:pstn_status)
    alias getPSTNStatus get_pstn_status

    def get_conf_participants_count() parse :conf_participants_count, invoke_get("CONF_PARTICIPANTS_COUNT") end
    def_parser(:conf_participants_count){|str| str.to_i}
    alias getConfParticipantsCount get_conf_participants_count


    #?CALL 59 CONF_PARTICIPANT 1 echo123 INCOMING_P2P INPROGRESS Echo Test Service .
    def_parser(:conf_participant, 'CONF_PARTICIPANT'){|str|
      res = str.split(' ')
      res[1] = Skype::User.new res[1] if res[1]
      res
    }

    #????
    def get_conf_participant num
      str = invoke_get "CONF_PARTICIPANT #{num}"
      res = str.split(' ')
      res[0] = Skype::User.new res[0]
      res
    end
    alias getConfParticipant get_conf_participant

    def get_vm_duration() parse :vm_duration, invoke_get("VM_DURATION") end
    def_parser(:vm_duration){|str| str.to_i}
    alias getVMDuration get_vm_duration

    def get_vm_allowed_duration() parse :vm_allowed_duration, invoke_get("VM_ALLOWED_DURATION") end
    def_parser(:vm_allowed_duration){|str| str.to_i}
    alias getVMAllowedDuration get_vm_allowed_duration

    def get_rate() parse :rate, invoke_get("RATE") end
    def_parser(:rate){|str| str.to_i}
    alias getRate get_rate

    def get_rate_currency() invoke_get("RATE_CURRENCY") end
    def_parser(:rate_currency)
    alias getRateCurrency get_rate_currency

    def get_rate_precision() parse :rate_precision, invoke_get("RATE_PRECISION") end
    def_parser(:rate_precision){|str| str.to_f} #?
    alias getRatePrecision get_rate_precision

    def get_input() invoke_get("INPUT") end
    def_parser(:input)
    alias getInput get_input

    def get_output() invoke_get("OUTPUT") end
    def_parser(:output)
    alias getOutput get_output

    def get_capture_mic() invoke_get("CAPTURE_MIC") end
    def_parser(:capture_mic)
    alias getCaptureMic get_capture_mic

    def get_vaa_input_status() parse :vaa_input_status, invoke_get("VAA_INPUT_STATUS") end
    def_parser(:vaa_input_status){|str| str._flag}
    alias getVAAInputStatus get_vaa_input_status

    def get_forwarded_by() parse :forwarded_by, invoke_get("FORWARDED_BY") end
    def_parser(:forwarded_by){|str| (str.empty? or str == '?') ? nil : Skype::User.new(str)}
    alias getForwardedBy get_forwarded_by

    def get_transfer_active?() parse :transfer_active, invoke_get("TRANSFER_ACTIVE") end
    def_parser(:transfer_active){|str| str._flag}
    alias getTransferActive? get_transfer_active?

    def get_transfer_status() invoke_get("TRANSFER_STATUS") end
    def_parser(:transfer_status)
    alias getTransferStatus get_transfer_status

    def get_transferred_by() parse :transferred_by, invoke_get("TRANSFERRED_BY") end
    def_parser(:transferred_by){|str| str.empty? ? nil : Skype::User.new(str)}
    alias getTransferredBy get_transferred_by

    def get_transferred_to() parse :transferred_to, invoke_get("TRANSFERRED_TO") end
    def_parser(:transferred_to){|str| str.empty? ? nil : Skype::User.new(str)}
    alias getTransferredTo get_transferred_to

    def get_can_transfer user
      parse :can_transffer, user.to_s + ' ' + invoke_get("CAN_TRANSFER #{user}")
    end
    def_parser(:can_transffer){|str| str.split(' ')[1]._flag}
    alias getCanTransfer get_can_transfer

    def get_seen() parse :seen, invoke_get("SEEN") end
    def_parser(:seen){|str| str._flag}
    alias getSeen get_seen

    #Notify?
    #getter :DTMF, "DTMF" do |str|
    #  str.to_i
    #end
    #getter :JoinConference, "JOIN_CONFERENCE"
    #getter :StartVideoSend, "START_VIDEO_SEND"
    #getter :StopVideoSend, "STOP_VIDEO_SEND"
    #getter :StartVideoReceive, "START_VIDEO_RECEIVE"
    #getter :StopVideoReceive, "STOP_VIDEO_RECEIVE"

    #
    def set_seen() invoke_set "SEEN" end
    alias setSeen set_seen

    def set_status(status) invoke_set "STATUS", status end
    alias setStatus set_status

    def set_status_onhold() set_status "ONHOLD" end
    alias setStatusOnhold set_status_onhold

    def set_status_inprogress() set_status "INPROGRESS" end
    alias setStatusInprogress set_status_inprogress

    def set_status_finished() setStatus "FINISHED" end
    alias setStatusFinished set_status_finished

    #def setDTMF number
    #  invoke_set "DTMF #{number}"
    #end
    #alias set_dtmf setDTMF

    #
    def set_join_conference(master_call) invoke_set "JOIN_CONFERENCE", master_call.to_s end
    alias setJoinConference set_join_conference

    def set_start_video_send() invoke_set "START_VIDEO_SEND" end
    alias setStartVideoSend set_start_video_send

    def set_stop_video_send() invoke_set "STOP_VIDEO_SEND" end
    alias setStopVideoSend set_stop_video_send

    def set_start_video_receive() invoke_set "START_VIDEO_RECEIVE" end
    alias setStartVideoReceive set_start_video_receive

    def set_stop_video_receive() invoke_set "STOP_VIDEO_RECEIVE" end
    alias setStopVideoReceive set_stop_video_receive

    def answer() invoke_alter "ANSWER" end

    def hold() invoke_alter "HOLD" end

    def resume() invoke_alter "RESUME" end

    def hangup() invoke_alter "HANGUP" end

    def end(value='') invoke_alter "END", value end

  def dtmf(number) invoke_alter "DTMF", number end

  def transfer(*users) invoke_alter "TRANSFER", users.join(', ') end

  #???
  def join_conference(call) invoke_alter "JOIN_CONFERENCE" end
  alias joinConference join_conference

  def start_video_send() invoke_alter "START_VIDEO_SEND" end
  alias startVideoSend start_video_send

  def stop_video_send() invoke_alter "STOP_VIDEO_SEND" end
  alias stop_video_send startVideoSend

  def start_video_receive() invoke_alter "START_VIDEO_RECEIVE" end
  alias startVideoReceive start_video_receive

  def stop_video_receive() invoke_alter"STOP_VIDEO_RECEIVE" end
  alias stopVideoReceive stop_video_receive

  def set_input(device) invoke_alter "SET_INPUT", device end
  alias setInput set_input

  def set_output(device) invoke_alter "SET_OUTPUT", device end
  alias set_output set_output

  def set_capture_mic(device) invoke_alter "SET_CAPTURE_MIC", device end
  alias setCaptureMic set_capture_mic

  #???
  def alter value
    invoke_one "ALTER CALL #{@id} #{value}","ALTER CALL #{@id}"
  end
end
end
