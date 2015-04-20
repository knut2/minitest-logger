#encoding: utf-8
=begin rdoc
Gem Minitest-Logger-Gem is the result of a question at Stackoverflow:
http://stackoverflow.com/questions/29392292/how-can-i-test-logger-messages-with-minitest

It extends Minitest::Test by Minitest::Assertion#assert_log.

With Minitest::Assertion#assert_log you can check,
if you get the Logger-messages you expect.


=Usage
==Load the gem
There are 3 methods to load the gem:

If you use Log4r:

  require 'minitest/log4r'

If you use Logger:

  require 'minitest/logger'

Alterative you can use - after you required log4r and/or logger:

  require 'minitest-logger'

==Make a testcase

During Test#setup you must define @log, then you can test the logs.

  class Test_log4r < MiniTest::Test
    def setup
      @log = Log4r::Logger.new('log')
      @log.level = Log4r::INFO
    end
    
    def test_logger
      assert_log(" INFO log: Hello World\n"){ @log.info("Hello World") }
    end
  end
  
More details see examples/example_minitest-logger.rb and the unit tests.

==Make Specifications
Example:

  describe Log4r::Logger do
    before do
      @log = Log4r::Logger.new('log')
      @log.level = Log4r::INFO
    end

    describe "When a info-message is posted" do
      it "must be reported" do
        lambda{ @log.info('Hello World')}.must_log( " INFO log: Hello World\n", :level => Log4r::INFO)
      end
      
      it "must be not reported if we set the level to warn" do
        lambda{ @log.info('Hello World')}.must_log( nil, :level => Log4r::WARN)
      end
    end
  end

More details see examples and the unit tests.

=Related stuff

You may also be interested in:
* http://9astronauts.com/code/rails-plugins/testable-logger/
=end

gem 'minitest'
require 'minitest/autorun'

=begin rdoc
Check if Log4r or Logger is available.

If yes, load the corresponding minitest version.
=end
if Object.const_defined? 'Log4r'
  require_relative 'minitest/log4r'
end
if Object.const_defined? 'Logger'
  require_relative 'minitest/logger'
end

if ! ( Object.const_defined? 'Log4r' or Object.const_defined? 'Logger')
  raise LoadError, <<msg
No Logger defined. 
Load first log4r/logger or use
  require 'minitest/log4r'
or
  require 'minitest/logger"
msg
end

module Minitest
=begin rdoc
It is recommended to define the logger in Minitest::Test#setup:

Example:

  class Test_logger < MiniTest::Test
    def setup # :nodoc:
      @testee = Testee.new(...)
      @log = @testee.log
      # @formatter = Log4r::StdoutOutputter
    end
    ...
  end
=end  
  class Test
      #Define the logger for Assertions#assert_log.
      #It is recommended to define the logger in #setup or as an option of Assertions#assert_log
      attr_accessor :log
      #Define a formatter for the temporary logger Log4r::StdoutOutputter
      attr_accessor :formatter
  end
    
  Logger_VERSION = '0.1.1'
  module Assertions
=begin rdoc
Evaluate block and collect the messages of a logger.

==Argument level:
This enables you to test less messages (e.g. only errors) without the need
of adapt the logger itself.

Attention: The level of the logger has a higher priority the the level of the outputter.
If the logger logs no DEBUG-messages, the output will also be empty, 
independent of the value of this parameter.

==Argument formatter
If you want to test with a special formatter you can define it 
with this parameter.
=end
    def logger_evaluation(log, level=nil, formatter = nil)
      raise ArgumentError unless defined? log
      raise ArgumentError unless block_given?
      
      case log.class.to_s
        when 'Log4r::Logger'
          log.outputters << outputter = Log4r::StringOutputter.new('stringoutputter') 
          outputter.level = level if level
          outputter.formatter = formatter if formatter
        when 'Logger'
          log.catch_messages(level)
        end
      yield #call block to get messages
      case log.class.to_s
        when 'Log4r::Logger'
          logtext = outputter.flush
        when 'Logger'
          logtext = log.catch_messages_stop()
        end      
      return logtext
    end #logger_evaluation
=begin rdoc
Define new assertion assert_log

==Options
===Define test logger (:log)
With option :log you can define or replace the logger to test.

It is recommended to define the logger during setup in Minitest::Test.

===Define log level (:level)
With option :level you can set an alternative level for the test.

See also #logger_evaluation for more information

==Examples

    assert_log(" INFO log: Hello World\n"){ @log.info("Hello World") }
    assert_log(" INFO log: Hello World\n", :log => @log){ @log.info("Hello World") }
    assert_log(" INFO log: Hello World\n", :level => Log4r::INFO){ @log.info("Hello World") }
    assert_log(nil, :level => Log4r::WARN){ @log.info("Hello World") }
    

      msg = message(msg, E) { diff exp, act }
      assert exp == act, msg

==Define a formatter (Only Log4r)
If you want to test with a special formatter you can define it 
with this parameter.

The default can be set with #formatter and during the setup.

=end
    def assert_log(expected, msg=nil, options = {}, &block)
      if msg.is_a?(Hash)
        options = msg
        msg = nil
      end

      logtext = logger_evaluation(options[:log] || @log, 
                                    options[:level], 
                                    options[:formatter] || @formatter, 
                                    &block)
        
      err_msg = Regexp === expected ? :assert_match : :assert_equal
      send err_msg, expected, logtext, message(msg) { "Logger #{options[:log] || @log} logs unexpected messages" } 
    end
=begin rdoc
Test for silent log (No messages are returned).

For details on options see #assert_log and #logger_evaluation
=end
    def assert_silent_log(msg=nil, options = {}, &block)
      if msg.is_a?(Hash)
        options = msg
        msg = nil
      end
      
      logtext = logger_evaluation(options[:log] || @log, options[:level], &block)
      assert !logtext, message(msg) { "Expected #{options[:log] || @log} to be silent, but returned\n #{mu_pp(logtext)}" }
    end
=begin rdoc
Test for silent log (No messages are returned)

For details on options see #assert_log and #logger_evaluation
=end
    def refute_silent_log(msg=nil, options = {}, &block)
      if msg.is_a?(Hash)
        options = msg
        msg = nil
      end
      logtext = logger_evaluation(options[:log] || @log, options[:level], &block)
      
      assert logtext, message(msg) { "Expected #{options[:log] || @log} not to be silent" }
    end #assert_silent_log
    
  end #module Assertions

=begin rdoc
Tests via Specs.
=end
  module Expectations
    ##
    # See Minitest::Assertions#assert_log
    #
    # Usage:
    #    lambda { ... }.must_log( messagestring [, options])
    #
    # :method: must_log
    infect_an_assertion :assert_log, :must_log
    ##
    # See Minitest::Assertions#assert_silent_log
    #
    # Usage:
    #    lambda { ... }.must_silent_log( messagestring [, options])
    #
    # :method: must_silent_log
    infect_an_assertion :assert_silent_log, :must_silent_log
    ##
    # See Minitest::Assertions#refute_silent_log
    #
    # Usage:
    #    lambda { ... }.must_not_silent_log( messagestring [, options])
    #
    # :method: must_not_silent_log
    infect_an_assertion :refute_silent_log, :must_not_silent_log
  end #module Expectations
end #Minitest

