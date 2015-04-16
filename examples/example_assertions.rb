#encoding: utf-8
=begin rdoc
Example for usage of gem minitest-logger.

See also the unit tests for more variants.
=end

=begin
You may use two different loggers:
=end
require 'log4r'
require 'logger'

$:.unshift('../lib')
require 'minitest-logger'

=begin rdoc
Example of the usage of Minitest-Logger-Gem.

Module TestExamples defined testcases to be used with Logger and Log4r::Logger-instances.

The methods expect an attribute @log.
=end
module TestExamples
    
  #Test if logger output is made
  #
  #The Methods #test_output_1, #test_output_2 and #test_output_3 are the same test 
  #with different method to define a string
  def test_output_1 
    assert_log(" INFO log: Hello World\n"){ @log.info("Hello World") }
  end
  #See #test_output_1
  def test_output_2
    assert_log(<<LOG  ){ @log.info("Hello World") }
 INFO log: Hello World
LOG
  end
  #See #test_output_1
  def test_output_3
    assert_log(<<LOG
 INFO log: Hello World
LOG
      ){ @log.info("Hello World") }
  end
  #Test the logger message with a regexp.
  #
  #This may be usefull for logger messages with timestamps.
  def test_output_regex
    assert_log(/Hello World/){ @log.info("Hello World") }
  end

  def test_output_with_comment
    assert_log(" INFO log: Hello World\n"){ @log.info("Hello World") }
    assert_log(" INFO log: Hello World\n", 'This Logger logs unexpected messages'){ @log.info("Hello World") }
  end


  def test_no_message # :nodoc:
    assert_log(nil){ @log.debug("Hello World") }
    assert_log(nil, 'Log is not silent'){ @log.debug("Hello World")}
  end

  #test for (non) silent logger
  def test_silent
    assert_silent_log(){
      @log.debug("Hello World")
      #~ @log.info("Hello World")     #uncomment this to see a failure
    }
    refute_silent_log(){
      @log.warn("Hello World")     #comment this to see a failure
    }
  end

=begin rdoc
Make tests of Module TestExamples with Log4r::Logger-instance.
=end
  class Test_log4r < MiniTest::Test
    include TestExamples
    def setup # :nodoc:
      @log = Log4r::Logger.new('log')
      @log.level = Log4r::INFO
      #~ @log.level = Log4r::WARN
    end    
  end

=begin rdoc
Make tests of Module TestExamples with Logger-instance.
=end
  class Test_logger < MiniTest::Test
    include TestExamples
    def setup # :nodoc:
      #~ @log = Logger.new(STDOUT)
      @log = Logger.new(IO.new(File::RDONLY,'w'))
      @log.level = Logger::INFO
      #Adapt logger output to Log4r-format. So we can reuses the testcases in TestExamples
      @log.formatter = proc{ |serverity, time, progname, msg|
          "%5s log: %s\n" % [serverity, msg]
      }
    end
  end
end #module TestExamples

__END__
