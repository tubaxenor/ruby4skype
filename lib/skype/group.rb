module Skype
  class Group < AbstractObject
    OBJECT_NAME = "GROUP"

    #FASdfklasjidfojsdlkjljfaslkdjf!!!!!!!!!!!!!!!!!!!!
    def self.create displayName
      Skype.invoke("CREATE GROUP #{displayName}")
      group = nil
      tmp = nil
      if Skype::Group.notify[:displayname] and Skype::Group.notify[:displayname][displayName]
        tmp = Skype::Group.notify[:displayname][displayName]
      end
      Skype::Group.setNotify :DisplayName, displayName do |g|
        group = g
      end
      until group
        Skype.polling
        sleep 0.0123
      end
      if tmp
        Skype::Group.setNotify :DisplayName, displayName, tmp
        tmp.call group
      else
        Skype::Group.notify[:displayname][displayName] = nil
      end
      group
      #ThreadSafe ����ς��낤�Ȃ��B�B�B
    end

    def get_type() invoke_get("TYPE") end
    def_parser(:type)
    alias getType get_type

    def get_custom_group_id() parse :custom_group_id, invoke_get("CUSTOM_GROUP_ID") end
    def_parser(:custom_group_id){|str| str.to_i}
    alias getCustomGroupID get_custom_group_id

    def get_displayname() invoke_get("DISPLAYNAME") end
    def_parser(:displayname)
    alias getDisplayname get_displayname

    def get_nrof_users() parse :nrof_users, invoke_get("NROFUSERS") end
    def_parser(:nrof_users,"NROFUSERS"){|str| str.to_i}
    alias getNrofUsers get_nrof_users

    def get_nrof_users_online() parse :nrof_users_online, invoke_get("NROFUSERS_ONLINE") end
    def_parser(:nrof_users_online,"NROFUSERS_ONLINE"){|str| str.to_i}
    alias getNrofUsersOnline get_nrof_users_online

    def get_users() parse :users, invoke_get("USERS") end
    def_parser(:users){|str| str.split('./')}
    alias getUsers get_users

    def get_visible() parse :visible, invoke_get("VISIBLE") end
    def_parser(:visible){|str| str._flag}
    alias getVisible get_visible

    def get_expanded() parse :expanded, invoke_get("EXPANDED") end
    def_parser(:expanded){|str| str._flag}
    alias getExpanded get_expanded

    def set_displayname(dispname) invoke_set "DISPLAYNAME", dispname end
    alias setDisplayname set_displayname

    def delete() invoke_echo "DELETE GROUP #{@id}" end

    def add_user(user) invoke_alter "ADDUSER", user end
    alias addUser add_user

    def remove_user(user) invoke_alter "REMOVEUSER", user end
    alias removeUser remove_user

    def share(msg='') invoke_alter "Share", msg end

    def accept() invoke_alter "ACCEPT" end

    def decline() invoke_alter "DECLINE" end

  end
end
