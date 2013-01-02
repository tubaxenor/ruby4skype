module Skype
  class SMS< AbstractObject
    OBJECT_NAME = "SMS"
    class << self
      def create target, type="OUTGOING"
        res = Skype.invoke "CREATE SMS #{type} #{target}"
        res =~ /^SMS (\d+) STATUS (.+)$/
        id, status = $1, $2
        return id, status
      end
        
      def createConfirmationCodeRequest target
        create target, 'CONFIRMATION_CODE_REQUEST'
      end
      alias create_confirmation_code_request createConfirmationCodeRequest
        
      def delete id
        Skype.invoke_echo "DELETE SMS #{id}"
      end
    end

    def get_body() invoke_get("BODY") end
    def_parser(:body)
    alias getBody get_body

    def get_type() invoke_get("TYPE") end
    def_parser(:type)
    alias getType get_type

    def get_status() invoke_get("STATUS") end
    def_parser(:status)
    alias getStatus get_status

    def get_failure_reason() invoke_get("FAILUREREASON") end
    def_parser(:failure_reason,"FAILUREREASON")
    alias getFailureReason get_failure_reason

    def get_is_failed_unseen?() invoke_get("IS_FAILED_UNSEEN") end
    def_parser(:is_failed_unseen)
    alias getIsFailedUnseen? get_is_failed_unseen?

    def get_timestamp() parse :timestamp, invoke_get("TIMESTAMP") end
    def_parser(:timestamp){|str| str.empty? ? nil : Time.at(str.to_i)}
    alias getTimestamp get_timestamp

    def get_price() parse :price, invoke_get("PRICE") end
    def_parser(:price){|str| str.to_i}
    alias getPrice get_price

    def get_price_precision() parse :price_precision, invoke_get("PRICE_PRECISION") end
    def_parser(:price_precision){|str| str.to_i}
    alias getPricePrecision get_price_precision

    def get_price_currency() invoke_get("PRICE_CURRENCY") end
    def_parser(:price_currency)
    alias getPriceCurrency get_price_currency

    def get_reply_to_number() invoke_get("REPLY_TO_NUMBER") end
    def_parser(:reply_to_number)
    alias getReplyToNumber get_reply_to_number

    def get_target_numbers() parse :target_numbers, invoke_get("TARGET_NUMBERS") end
    def_parser(:target_numbers){|str| str.split(', ')}
    alias getTargetNumbers get_target_numbers

    def get_target_statuses() parse :target_statuses, invoke_get("TARGET_STATUSES") end
    def_parser(:target_statuses){|str|
      hash = Hash.new
      str.split(', ').each{ |lump|
        pstn, status = lump.split('=')
        hash[pstn] = status
      }
      hash
    }
    alias getTargetStatuses get_target_statuses

    #send?
    def get_chunk noOfChunks
      res = invoke "CHUNK #{noOfChunks}"
      return noOfChunks, res
    end
    alias getChunk get_chunk
      
    def set_body(text) invoke_set "BODY", text end
    alias setBody set_body
      
    def send() invoke_alter "SEND" end
      
    def delete() invoke_echo "DLETE SMS #{@id}" end
      
    def set_target_number *nums
      nums = nums[0] if nums[0].class == Array
      invoke_set "TARGET_NUMBERS", nums.join(', ')
    end
    alias setTargetNumber set_target_number
      
    def set_seen() invoke_set "SEEN" end
    alias setSeen set_seen
      
    def set_reply_to_number(pstn) invoke_set "REPLY_TO_NUMBER", pstn end
    alias setReplyToNumber set_reply_to_number
      
  end
end
