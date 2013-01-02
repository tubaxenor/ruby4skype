
module Skype
  class Chat < AbstractObject
    OBJECT_NAME =  "CHAT"

    class << self
      def create *users
        Skype.invoke("CHAT CREATE #{users.join(', ')}") =~ /^CHAT ([^ ]+) STATUS (.+)$/
        chatID, status = $1, $2
        return Skype::Chat.new(chatID)#, status
      end

      def find_using_blob blob
        Skype.invoke("CHAT FINDUSINGBLOB #{blob}") =~ /^CHAT ([^ ]+) STATUS (.+)$/
        chatID, status = $1, $2
        return Skype::Chat.new(chatID)#, status
      end
      alias findUsingBlob find_using_blob

      def create_using_blob blob
        Skype.invoke("CHAT CREATEUSINGBLOB #{blob}") =~ /^CHAT ([^ ]+) STATUS (.+)$/
        chatID, status = $1, $2
        return Skype::Chat.new(chatID)#, status
      end
      alias createUsingBlob create_using_blob
    end

    def get_name() invoke_get('NAME') end
    def_parser(:name)
    alias getName get_name

    def get_timestamp() parse :timestamp, invoke_get('TIMESTAMP') end
    def_parser(:timestamp){|str| str.empty? ? nil : Time.at(str.to_i) }
    alias getTimestamp get_timestamp

    def get_adder() parse :adder, invoke_get('ADDER') end
    def_parser(:adder){|str| str.empty? ? nil : Skype::User.new(str) }
    alias getAdder get_adder

    def get_status() invoke_get 'STATUS' end
    def_parser :status
    alias getStatus get_status

    def get_posters() parse :posters, invoke_get('POSTERS') end
    def_parser(:posters){|str| str.split(', ').map{|handle| Skype::User.new handle}}
    alias getPosters get_posters

    def get_members() parse :members, invoke_get('MEMBERS') end
    def_parser(:members){|str| str.split(' ').map{|handle| Skype::User.new handle}}
    alias getMembers get_members

    def get_topic() invoke_get('TOPIC') end
    def_parser(:topic)
    alias getTopic get_topic

    def get_topic_xml() invoke_get('TOPICXML') end
    def_parser(:topic_xml,'TOPICXML')
    alias getTopicXML get_topic_xml

    def get_chat_messages() parse :chat_messages, invoke_get('CHATMESSAGES') end
    def_parser(:chat_messages, 'CHATMESSAGES'){|str| str.split(' ').map{|id| Skype::ChatMessage.new id}}
    alias getChatMessages get_chat_messages

    def get_active_members() parse :active_members, invoke_get('ACTIVEMEMBERS') end
    def_parser(:active_members, 'ACTIVEMEMBERS'){|str| str.split(' ').map{|handle| Skype::User.new handle}}
    alias getActiveMembers get_active_members

    def get_friendly_name() invoke_get('FRIENDLYNAME') end
    def_parser :friendly_name, 'FRIENDLYNAME'
    alias getFriendlyName get_friendly_name

    def get_recent_chat_messages() parse :recent_chat_messages, invoke_get('RECENTCHATMESSAGES') end
    def_parser(:recent_chat_messages, 'RECENTCHATMESSAGES'){|str| str.split(' ').map{|handle| Skype::ChatMessage.new handle}}
    alias getRecentChatMessages get_recent_chat_messages

    def get_bookmarked() parse :bookmarked, invoke_get("BOOKMARKED") end
    def_parser(:bookmarked){|str| str._flag}
    alias getBookmarked get_bookmarked

    def get_member_objects() parse :member_objects, invoke_get('MEMBEROBJECTS') end
    def_parser(:member_objects, 'MEMBEROBJECTS'){|str| str.split(' ').map{|id| id.chop! if id[-1,1] == ','; Skype::ChatMember.new id}}
    alias getMemberObjects get_member_objects

    def get_password_hint() invoke_get 'PASSWORDHINT' end
    def_parser :password_hint, 'PASSWORDHINT'
    alias getPasswordHint get_password_hint

    def get_guidelines() invoke_get 'GUIDELINES' end
    def_parser :guidelines
    alias getGuidelines get_guidelines

    def get_options() parse :options, invoke_get('OPTIONS') end
    def_parser(:options){|str| str.to_i}
    alias getOptions get_options

    def get_description() invoke_get('DESCRIPTION') end
    def_parser :description
    alias getDescription get_description

    def get_dialog_partner() parse :dialog_partner, invoke_get('DIALOG_PARTNER') end
    def_parser(:dialog_partner){|str| str.empty? ? nil : Skype::User.new(str)}
    alias getDialogPartner get_dialog_partner

    def get_activity_timestamp() parse :activity_timestamp, invoke_get('ACTIVITY_TIMESTAMP') end
    def_parser(:activity_timestamp){|str| str.empty? ? nil : Time.at(str.to_i)}
    alias getActivityTimestamp get_activity_timestamp

    def get_type() invoke_get 'TYPE' end
    def_parser :type
    alias getType get_type

    def get_my_status() invoke_get 'MYSTATUS' end
    def_parser :my_status, 'MYSTATUS'
    alias getMyStatus get_my_status

    def get_my_role() invoke_get 'MYROLE' end
    def_parser :my_role, 'MYROLE'
    alias getMyRole get_my_role

    def get_blob() invoke_get 'BLOB' end
    def_parser :blob
    alias getBlob get_blob

    def get_applicants() parse :applicants, invoke_get('APPLICANTS') end
    def_parser(:applicants){|str| str.split(' ').map{|handle| Skype::User.new handle}}
    alias getApplicants get_applicants

    def set_topic(topic) invoke_alter "SETTOPIC", topic end
    alias setTopic set_topic

    def set_topic_xml(topic) invoke_alter "SETTOPICXML", topic end
    alias setTopicXML set_topic_xml

    def add_members(*members) invoke_alter "ADDMEMBERS",  members.join(', ') end
    alias addMembers add_members

    def leave() invoke_alter "LEAVE" end

    def bookmarked() invoke_alter "BOOKMARK" end

    def unbookmarked() invoke_alter "UNBOOKMARK" end

    def join() invoke_alter "JOIN" end

    def clear_recent_messages() invoke_alter "CLEARRECENTMESSAGES" end
    alias clearRecentMessages clear_recent_messages

    def set_alert_string(string) invoke_alter "SETALERTSTRING", string end
    alias setAlertString set_alert_string

    def acceptadd() invoke_alter "ACCEPTADD" end

    def disband() invoke_alter "DISBAND" end

    def set_password(password, passwordHint='') invoke_alter "SETPASSWORD", password + ' ' + passwordHint end
    alias setPassword set_password

    def enter_password(password) invoke_alter "ENTERPASSWORD", password end
    alias enterPassword enter_password

    def set_options(option) invoke_alter "SETOPTIONS", option.to_s end
    alias setOptions set_options

    def kick(*users) invoke_alter "KICK", users.join(', ') end

    def kickban(*users) invoke_alter "KICKBAN", users.join(', ') end

    def set_guidelines(guidlines) invoke_alter 'SETGUIDELINES', guidlines end
    alias setGuideLines set_guidelines


    def send_message(strings) Skype::ChatMessage.create self, strings end
    alias sendMessage send_message

  end
end
