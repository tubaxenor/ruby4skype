module Skype
  class ChatMessage < AbstractObject
    OBJECT_NAME = "CHATMESSAGE"

    class << self
      def create chat ,msg
        Skype.invoke("CHATMESSAGE #{chat} #{msg}") =~ /^CHATMESSAGE (\d+) STATUS (.+)$/
        Skype::ChatMessage.new($1)#, $2
      end
    end

    def get_body() invoke_get 'BODY' end
    def_parser :body
    alias getBody get_body

    def get_timestamp() parse :timestamp, invoke_get('TIMESTAMP') end
    def_parser(:timestamp){|str| str.empty? ? nil : Time.at(str.to_i)}
    alias getTimestamp get_timestamp

#OBS
#    def get_partner() parse :partner, invoke_get('PARTNER_HANDLE') end
#    def_parser(:partner, 'PARTNER_HANDLE'){|str| Skype::User.new str}
#    alias getPartner get_partner
#
#    def get_partner_dispname() invoke_get('PARTNER_DISPNAME') end
#    def_parser(:partner_dispname)
#    alias getPartnerDispname get_partner_dispname

    def get_from() parse :from, invoke_get('FROM_HANDLE') end
    def_parser(:from, 'FROM_HANDLE'){|str| Skype::User.new str}
    alias getFrom get_from

    def get_from_dispname() invoke_get('FROM_DISPNAME') end
    def_parser :from_dispname
    alias getFromDispname get_from_dispname

    def get_type() invoke_get 'TYPE' end
    def_parser :type
    alias getType get_type

    def get_status() invoke_get 'STATUS' end
    def_parser :status
    alias getStatus get_status

    def get_leave_reason() parse :leave_reason, invoke_get('LEAVEREASON') end
    def_parser(:leave_reason, 'LEAVEREASON'){|str| str.empty? ? nil : str}
    alias getLeaveReason get_leave_reason

    def get_chat() parse :chat, invoke_get('CHATNAME') end
    def_parser(:chat, 'CHATNAME'){|str| Skype::Chat.new str}
    alias getChat get_chat

    def get_users() parse :users, invoke_get('USERS') end
    def_parser(:users){|str| str.split(',').map{|handle| Skype::User.new handle}}
    alias getUsers get_users

    def get_is_editable?() parse :is_editable, invoke_get('IS_EDITABLE') end
    def_parser(:is_editable){|str| str == 'TRUE' ? true : false}
    alias getIsEditable? get_is_editable?

    def get_edited_by() parse :edited_by, invoke_get("EDITED_BY") end
    def_parser(:edited_by){|str| str.empty? ? nil : Skype::User.new(str)}
    alias getEditedBy get_edited_by

    def get_edited_timestamp() parse :edited_timestamp, invoke_get('EDITED_TIMESTAMP') end
    def_parser(:edited_timestamp){|str| str.empty? ? nil : Time.at(str.to_i)}
    alias getEditedTimestamp get_edited_timestamp

    def get_options() parse :options, invoke_get('OPTIONS') end
    def_parser(:options){|str| str.to_i}
    alias getOptions get_options

    def get_role() invoke_get('ROLE') end
    def_parser(:role)
    alias getRole get_role

    def set_seen
      return true if Skype.invoke("SET CHATMESSAGE #{@id} SEEN") =~ /^CHATMESSAGE #{@id} STATUS (.+)$/
      raise 'hogehoge'
    end
    alias setSeen set_seen

    def set_body(text) invoke_set('BODY', text) end
    alias setBody set_body
  end
end
