#encoding: utf-8
=begin rdoc
Tests for minitest-logger
=end
gem 'minitest'
require 'minitest/autorun'
  
$:.unshift('../lib')
#~ require 'log4r'
#~ require 'minitest-logger'
require 'minitest/log4r'

class Test_minitest_log4r < MiniTest::Test
      def setup
        @log = Log4r::Logger.new('log')
        @log.level = Log4r::INFO
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
        assert_log(" WARN log: Hello World\n", :level => Log4r::WARN){ 
          @log.debug("Hello World") #catched by logger-level
          @log.info("Hello World")    #catched by outputter-level
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
        assert_silent_log(:level => Log4r::ERROR){@log.warn("Hello World") }
      end
      def test_not_silent      
        refute_silent_log(){ @log.info("Hello World") }
        refute_silent_log(){ @log.warn("Hello World") }
      end
  
end

=begin
Same with Specifications
=end
describe Log4r::Logger do
  before do
    @log = Log4r::Logger.new('log')
    @log.level = Log4r::INFO
  end

  describe "When a debug-message is posted" do
    it "must not be reported" do
      lambda{ @log.debug('Hello World') }.must_log(nil)
    end
    it "must not be reported, even if we set the level to debug" do
      lambda{ @log.debug('Hello World')}.must_log( nil, :level => Log4r::DEBUG)
    end
  end
  
  describe "When a info-message is posted" do
    it "must be reported" do
      lambda{ @log.info('Hello World')}.must_log( " INFO log: Hello World\n")
    end
    
    it "must be not reported if we set the level to warn" do
      lambda{ @log.info('Hello World')}.must_log( nil, :level => Log4r::WARN)
    end
    
    it "the logger must not be silent" do
      lambda{ @log.info('Hello World')}.must_not_silent_log()
    end
    
    it "the logger must be silent on level warn" do
      lambda{ @log.info('Hello World')}.must_silent_log(:level => Log4r::WARN)
    end
    
  end

end