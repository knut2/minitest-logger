#encoding: utf-8
=begin rdoc
Extend Minitest with tests for log4r.
=end
  
require 'log4r'  #
require_relative '../minitest-logger'

module Log4r
=begin rdoc
Define a new Log4r-outputter to catch data into an String.
=end
  class StringOutputter < Log4r::StdoutOutputter
=begin rdoc
Collect messages in array.
=end
    def write(message)
      @messages ||= ''  #create with first call
      @messages  << message
    end
=begin rdoc
Clear message string and return messages.
=end
    def flush
      @messages ||= ''  #create with first call
      messages = @messages.dup
      @messages = ''
      messages.empty? ? nil : messages
    end
  end #ArrayOutputter
    
end