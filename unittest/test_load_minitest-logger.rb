#encoding: utf-8
=begin rdoc
Tests for minitest-logger
=end
gem 'minitest'
require 'minitest/autorun'
  
$:.unshift('../lib')

class Test_minitest_logger < MiniTest::Test
  def test_load
    assert_raises(LoadError){ require 'minitest-logger'}
  end
end
