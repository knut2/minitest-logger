#encoding: utf-8
=begin rdoc
Tests for minitest-logger
=end
gem 'minitest'
require 'minitest/autorun'
  
$:.unshift('../lib')
#~ require 'logger'
#~ require 'minitest-logger'
require 'minitest/logger'

class Test_minitest_logger_with_Logger_format < MiniTest::Test
  
      def setup
        @log = Logger.new(IO.new(File::RDONLY,'w'))
        @log.level = Logger::INFO
        #Same format as Logger
        @log.formatter = proc{ |serverity, time, progname, msg|
            "%5s log: %s\n" % [serverity, msg]
        }
      end
      
      def test_silent
        assert_silent{ @log.debug("hello world") }
        assert_log(nil){ @log.debug("Hello World") }
      end
      def test_default_level
        assert_log(" INFO log: Hello World\n"){ @log.info("Hello World") }
        assert_log(" INFO log: Hello World\n WARN log: Hello World\n"){ 
          @log.debug("Hello World")
          @log.info("Hello World")
          @log.warn("Hello World")
        }
      end
      
      def test_warn
        assert_log(" WARN log: Hello World\n", :level => Logger::WARN){ 
          @log.debug("Hello World") #catched by logger-level
          @log.info("Hello World")
          @log.warn("Hello World")
        }
      end
      
      def test_regexp
        assert_log(/Hello World/){ @log.info("Hello World") }
        assert_log(/Hello/){ @log.info("Hello World") }
        assert_log(/World/){ @log.info("Hello World") }
      end

      def test_silent
        assert_silent_log(){@log.debug("Hello World") }
        assert_silent_log(:level => Logger::ERROR){@log.warn("Hello World") }
      end
      def test_not_silent      
        refute_silent_log(){ @log.info("Hello World") }
        refute_silent_log(){ @log.warn("Hello World") }
      end
  
end

=begin rdoc
Logger-messages contain the actual date/time.

So it may be a good idea to use regexp.
=end
class Test_minitest_logger < MiniTest::Test
  
      def setup
        @log = Logger.new(IO.new(File::RDONLY,'w'))
        @log.level = Logger::INFO
      end
      
      def test_silent
        assert_silent{ @log.debug("hello world") }
        assert_log(nil){ @log.debug("Hello World") }
      end
      def test_default_level
        assert_log(/I, \[.*\]  INFO -- : Hello World\n/){ @log.info("Hello World") }
        assert_log(/I, \[.*\]  INFO -- : Hello World\nW, \[.*\]  WARN -- : Hello World\n/){ 
          @log.debug("Hello World")
          @log.info("Hello World")
          @log.warn("Hello World")
        }
      end
      
      def test_warn
        assert_log(/W, \[.*\]  WARN -- : Hello World\n/, :level => Logger::WARN){ 
          @log.debug("Hello World") #catched by logger-level
          @log.info("Hello World")
          @log.warn("Hello World")
        }
      end

      def test_with_date_and_pid
        #This test may fail, if the processor is too slow.
        assert_log(
          Time.now.strftime("I, [%Y-%m-%dT%H:%M:%S.%6N ##{Process.pid}]  INFO -- : Hello World\n")
          ){ 
            @log.info("Hello World")
          }
      end
      
end


=begin
Same with Specifications
=end
describe Logger do
  before do
    @log = Logger.new(IO.new(File::RDONLY,'w'))
    @log.level = Logger::INFO
  end

  describe "When a debug-message is posted" do
    it "must not be reported" do
      lambda{ @log.debug('Hello World') }.must_log(nil)
    end
    it "must not be reported, even if we set the level to debug" do
      lambda{ @log.debug('Hello World')}.must_log( nil, :level => Logger::DEBUG)
    end
  end
  
  describe "When a info-message is posted" do
    it "must be reported (If the processor is fast enough to get the same system time)" do
      lambda{@log.info('Hello World')}.must_log(       
        Time.now.strftime("I, [%Y-%m-%dT%H:%M:%S.%6N ##{Process.pid}]  INFO -- : Hello World\n"))
      end
      
    it "must be not reported if we set the level to warn" do
      lambda{ @log.info('Hello World')}.must_log( nil, :level => Logger::WARN)
    end

    it "the logger must not be silent" do
      lambda{ @log.info('Hello World')}.must_not_silent_log()
    end
    
    it "the logger must be silent on level warn" do
      lambda{ @log.info('Hello World')}.must_silent_log(:level => Logger::WARN)
    end


  end

end
    