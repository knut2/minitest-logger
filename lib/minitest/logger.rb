#encoding: utf-8
=begin rdoc
Extend Logger with features to catch messages.
=end
  
require 'logger'  #
require_relative '../minitest-logger'

=begin rdoc
Extend Logger by #catch_messages and #catch_messages_stop to 
store logger messages for later evaluation.
Idea based on http://stackoverflow.com/a/12658810/676874

This is used for Logger-instances in Minitest::Assertions#assert_log

=end
class Logger
  # Collect all messages for later evaluation.
  def catch_messages(level)
    @logdev.catch_messages(level)
  end

  # Stop message collection and retund the collected messages.
  def catch_messages_stop()
    @logdev.catch_messages_stop()
  end

  class LogDevice # :nodoc:

    # Define a String to collect messages.
    def catch_messages(level)
      @catchlevel = level
      @messages = ''
    end

    # Stop message collection and retund the collected messages.
    def catch_messages_stop()
      messages = @messages
      @messages = nil
      messages.empty? ? nil : messages
    end
    
    LEVELS = %w{debug info warn error fatal unknown}
    alias_method :old_write, :write
    #Store messages also in @messages if requested.
    def write(message)
      #check level with @catchlevel 
      if @messages 
        caller[1] =~ /`(.+?)'\Z/
        @messages << message if !@catchlevel  or @catchlevel <= LEVELS.index($1)
      end
      old_write(message)
    end
  end #LogDevice 
end
