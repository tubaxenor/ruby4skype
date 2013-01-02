module Skype
  class FileTransfer < AbstractObject
    OBJECT_NAME = "FILETRANSFER"

    def get_type() invoke_get("TYPE") end
    def_parser(:type)
    alias getType get_type

    def get_status() invoke_get("STATUS") end
    def_parser(:status)
    alias getStatus get_status

    def get_failure_reason() invoke_get("FAILUREREASON") end
    def_parser(:failure_reason, "FAILUREREASON")
    alias getFailureReason get_failure_reason

    def get_partner() parse :partner, invoke_get("PARTNER_HANDLE") end
    def_parser(:partner, 'PARTNER_HANDLE'){|str| Skype::User.new str}
    alias getPartner get_partner

    def get_partner_dispname() invoke_get("PARTNER_DISPNAME") end
    def_parser(:partner_dispname)
    alias getPartnerDispname get_partner_dispname

    def get_start_time() parse :start_time, invoke_get("STARTTIME") end
    def_parser(:start_time,'STARTTIME'){|str| str.empty? ? nil : Time.at(str.to_i)}
    alias getStartTime get_start_time

    def get_finish_time() parse :finish_time, invoke_get("FINISHTIME") end
    def_parser(:finish_time, 'FINISHTIME'){|str| str.empty? ? nil : Time.at(str.to_i)}
    alias getFinishTime get_finish_time

    def get_file_path() invoke_get("FILEPATH") end
    def_parser(:file_path, 'FILEPATH')
    alias getFilePath get_file_path

    def get_file_size() parse :file_size, invoke_get("FILESIZE") end
    def_parser(:file_size, 'FILESIZE'){|str| str.to_i}
    alias getFileSize get_file_size

    def get_bytes_per_second() parse :bytes_per_second, invoke_get("BYTESPERSECOND") end
    def_parser(:bytes_per_second, 'BYTEPERSECOND'){|str| str.to_i}
    alias getBytesPerSecond get_bytes_per_second

    def get_bytes_transferred() parse :bytes_transferred, invoke_get("BYTESTRANSFERRED") end
    def_parser(:bytes_transferred, 'BYTETRASFERRED'){|str| str.to_i}
    alias getBytesTransferred get_bytes_transferred

  end
end
