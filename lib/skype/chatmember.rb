module Skype
  class ChatMember < AbstractObject
    OBJECT_NAME = "CHATMEMBER"

    def get_chat() parse :chat, invoke_get('CHATNAME') end
    def_parser(:chat, 'CHATNAME'){|str| Skype::Chat.new(str)}
    alias getChat get_chat

    def get_user() parse :user, invoke_get('IDENTITY') end
    def_parser(:user, 'IDENTITY'){|str| Skype::User.new(str)}
    alias getUser get_user

    def get_role() invoke_get('ROLE') end
    def_parser :role
    alias getRole get_role

    def get_is_active?() parse :is_active, invoke_get('IS_ACTIVE') end
    def_parser(:is_active){|str| str == 'TRUE' ? true : false}
    alias getIsActive? get_is_active?


    def set_role_to(role) invoke_alter('SETROLETO', role) end
    alias setRoleTo set_role_to

    def can_set_role_to?(role)
      invoke("ALTER CHATMEMBER #{@id} CANSETROLETO #{role}") =~ /ALTER CHATMEMBER CANSETROLETO (TRUE|FALSE)/
      $1 == 'TRUE' ? true : false
    end
    alias canSetRoleTo? can_set_role_to?
  end
end
