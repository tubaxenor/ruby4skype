require 'date'
require 'forwardable'

module Skype    
  class AbstractObject #:nodoc: all
    module Notify
      def setNotify property=nil,value=nil, block=Proc.new
        property = property.to_s.downcase.to_sym if property
        value = value.to_s.upcase if value.class == Symbol
        @notify[property] = Hash.new unless @notify[property]
        @notify[property][value] = block
      end
      alias set_notify setNotify

      def delNotify property=nil,value=nil
        @notify[property].delete value
      end
      alias del_notify delNotify

      def notify
        @notify
      end

      def notified instance, property,value
        if @notify[nil]
          @notify[nil][nil].call instance, property, value if @notify[nil][nil]
          @notify[nil][value].call instance, property if @notify[nil][value]
        end
        if @notify[property]
          @notify[property][nil].call instance, value if @notify[property][nil]
          @notify[property][value].call instance if @notify[property][value]
        end
      end
      alias set_notify setNotify
      alias del_notify delNotify
    end

    module Get
#      def getter method_name, skypeProperty=method_name.to_s.upcase, &callBack
#        define_method = self == Skype ? self.class.method(:define_method) : method(:define_method)
#        alias_method = self == Skype ? self.class.method(:alias_method) : method(:alias_method)
#
#        define_method.call 'get' + method_name.to_s do
#          str = invoke_get skypeProperty
#          callBack ? callBack.call(str) : str
#        end
#
#        understyle_method_name = 'get'+method_name.to_s.gsub(/[A-Z]+/){ |s| '_' + s.downcase}
#        alias_method.call(understyle_method_name, 'get'+method_name.to_s)
#
#        notice method_name, skypeProperty, &callBack
#      end

      def notice methodName, skypeProperty, &callBack
        if Skype.kind_of? self
          Skype.property2symbol[skypeProperty] = methodName.to_sym
          Skype.property2callback[skypeProperty] = callBack if callBack
        else
          property2symbol[skypeProperty] = methodName.to_sym
          property2callback[skypeProperty] = callBack if callBack
        end
      end

      def def_parser sym, property=sym.to_s.upcase, &callback
        notice sym, property, &callback
      end

      attr_reader :property2symbol, :property2callback
    end

    module Parser
      def parse sym, res
        if self == Skype
          Skype.property2callback[Skype.property2symbol.index(sym)].call(res)
        else
          self.class.property2callback[self.class.property2symbol.index(sym)].call(res)
        end
      end
      private :parse
    end

    module Invokers
      #private

      #invoke_echo "CREATE APPLICATION #{@appName}"
      #CREATE APPLICATION #{@appName} -> CREATE APPLICATION #{@appName}
      def invoke_echo cmd
        begin
          invoke(cmd) == cmd
        rescue Skype::Error::API => e
          e.backtrace.shift
          e.backtrace.shift
          raise e
        end
      end

      #invoke_one "GET CHATMESSAGE #{@id} BODY", "CHATMESSAGE #{@id} BODY"
      #GET CHATMESSAGE #{@id} BODY -> CHATMESSAGE #{@id} BODY (.+)
      def invoke_one cmd, regExp=cmd
        regExp.gsub!(/[\^$.\\\[\]*+{}?|()]/) do |char|
          "\\" + char
        end
        begin
          invoke(cmd) =~ /^#{regExp} (.*)$/m
        rescue Skype::Error::API => e
          e.backtrace.shift
          e.backtrace.shift
          raise e
        end
        return $1
      end

      #invoke_get("GET USER #{@handle} SkypeOut")
      #GET USER #{@handle} SkypeOut -> USER #{@handle} SkypeOut (.+)
      def invoke_get prop, value=nil
        cmd = "GET #{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s+' ' : ''}#{prop}#{value ? ' ' + value : ''}"
        reg = "#{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s+' ' : ''}#{prop}#{value ? ' ' + value : ''}".gsub(/[\^$.\\\[\]*+{}?|()]/) do |char|
          "\\" + char
        end
        begin
          tmp = invoke(cmd)
          tmp =~ /^#{reg} (.*)$/m
        rescue Skype::Error::API => e
          e.backtrace.shift
          e.backtrace.shift
          raise e
        end
        return $1
      end

      def invoke_set prop,value=nil
        cmd = "SET #{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s + ' ' : ''}#{prop}#{value ? ' '+value.to_s : '' }"
        reg = "#{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s + ' ' : ''}#{prop}"
        begin
          str = invoke_one cmd, reg
        rescue Skype::Error::API => e
          e.backtrace.shift
          e.backtrace.shift
          raise e
        end
        #p [self,self.class]
        #if self.class == Module
        #  @property2callcack[prop] ? @property2callback[prop].call(str) : str
        #else
        #  self[prop] ? self.class::V2O[prop].call(str) : str
        #end
        str
      end

      def invoke_alter prop, value=nil
        cmd = "ALTER #{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s + ' ' : ''}#{prop}#{value ? ' '+value.to_s : '' }"
        #res = "ALTER #{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{@id ? @id.to_s + ' ' : ''}#{prop}"
        #reg.gsub!(/[\^$.\\\[\]*+{}?|()]/) do |char|
        #  "\\" + char
        #end
        #res = "ALTER #{defined?(self.class::OBJECT_NAME) ? self.class::OBJECT_NAME + ' ' : ''}#{prop}"
        begin
          invoke(cmd)# == res
        rescue Skype::Error::API => e
          e.backtrace.shift
          e.backtrace.shift
          raise e
        end
        true
      end

      #def sendAlterWithID prop, value=nil
      #  str = invoke_one "ALTER #{self.class::OBJECT_NAME} #{@id} #{prop}#{value ? ' '+value.to_s : '' }","ALTER #{self.class::OBJECT_NAME} #{@id} #{prop}"
      #  self.class::V2O[self.class::P2M[prop]] ? self.class::V2O[self.class::P2M[prop]].call(str) : str
      #end
    end

    extend Notify
    extend Forwardable
    extend Get
    include Parser
    include Notify
    include Invokers
      
    @@instance = Hash.new do |hash,key|
      hash[key] = Hash.new
    end
    @@skypeApi = Skype
      
    def self.inherited sub
      if self == AbstractObject
        sub.instance_variable_set :@property2symbol, Hash.new{|hash,key| hash[key] = key}
        sub.instance_variable_set :@property2callback, Hash.new
      end
      sub.instance_variable_set :@notify, Hash.new
    end

    def self.notified msg
      if msg =~ /^([^ ]+) ([^ ]+) (.*)$/m
        id = $1; skypeProperty = $2; value = $3
        instance = new id
        property = @property2symbol[skypeProperty].to_s.downcase.to_sym if @property2symbol[skypeProperty].class == Symbol
        value = @property2callback[skypeProperty].call value if @property2callback[skypeProperty]

          
        if @notify[nil]
          @notify[nil][nil].call instance, property, value if @notify[nil][nil]
          @notify[nil][value].call instance, property if @notify[nil][value]
        end
        if @notify[property]
          @notify[property][nil].call instance, value if @notify[property][nil]
          @notify[property][value].call instance if @notify[property][value]
        end
        @@instance[self][id].notified instance, property, value if @@instance[self][id]
      end
    end
      
    def self.new id
      if @@instance[self][id]
        return @@instance[self][id]
      else
        instance = super id
        instance.instance_variable_set(:@notify, Hash.new do |h,k|
            h[k] = Hash.new
          end)
        @@instance[self][id] = instance
        return instance
      end
    end
      
    def initialize id
      @id = id
    end
      
    def to_s
      @id.to_s
    end
      
    def_delegators :@@skypeApi, :invoke
  end
end


class NilClass
  def _flag
    nil
  end

  def _swi
    nil
  end

  def _str
    ""
  end

  def _int
    nil
  end
end

class String
  def _flag
    case self
    when /^(TRUE)|(ON)$/i
      return true
    when /^(FALSE)|(OFF)$/i
      return false
    else
      self
    end
  end

  def _int
    self.empty? ? nil : self.to_i
  end

  def _str
    self
  end
end

class TrueClass
  def _swi
    "ON"
  end

  def _str
    "TRUE"
  end
end

class FalseClass
  def _swi
    "OFF"
  end

  def _str
    "FALSE"
  end
end

