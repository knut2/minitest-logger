#encoding: utf-8
=begin rdoc
Tests for minitest-logger
=end 
$:.unshift('../lib')

require 'log4r'
require 'logger'
require 'minitest-logger'

=begin
Log4r::Logger
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
      lambda{ @log.info('Hello World')}.must_log( " INFO log: Hello World\n", :level => Log4r::INFO)
    end
    
    it "must be not reported if we set the level to warn" do
      lambda{ @log.info('Hello World')}.must_log( nil, :level => Log4r::WARN)
    end
  end

end

=begin
Logger
=end
describe Logger do
  before do
    @log = Logger.new('log')
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
    it "must be reported" do
      lambda{ @log.info('Hello World')}.must_log( /I, \[.*\]  INFO -- : Hello World\n/, :level => Logger::INFO)
    end
    
    it "must be not reported if we set the level to warn" do
      lambda{ @log.info('Hello World')}.must_log( nil, :level => Logger::WARN)
    end
  end

end