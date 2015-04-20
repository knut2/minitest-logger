#encoding: utf-8
=begin
Create gem minitest-logger

Idea for further development:
Collect only errors/warnings....:
+ assert_error
+ assert_warn

=end
$:.unshift('c:/usr/script/knut/knut-testtask/lib')
$:.unshift('c:/usr/script/knut/knut-gempackager/lib')
require 'knut-gempackager'  

require '../knut_pw.rb'
$:.unshift('lib')
require 'minitest-logger'
$minitest_logger_version = "0.1.1.beta"
Minitest::Logger_VERSION = $minitest_logger_version #while it is beta


#http://docs.rubygems.org/read/chapter/20
gem_minitest_logger = Knut::Gem_packer.new('minitest-logger', $minitest_logger_version){ |gemdef, s|
  s.name = "minitest-logger"
  s.version =  $minitest_logger_version
  s.author = "Knut Lickert"
  s.email = "knut@lickert.net"
  #~ s.homepage = "http://ruby.lickert.net/minitest-logger"
  #~ s.homepage = "http://gems.rubypla.net/minitest-logger"
  #~ s.rubyforge_project = 'minitest-logger'
  s.platform = Gem::Platform::RUBY
  #~ s.required_ruby_version = '>= 1.9'
  #~ s.license = '?'
  s.summary = "Extend minitest by assert_log"
  s.description = <<-DESCR
Extend minitest by assert_log and enable minitest to test log messages.
Supports Logger and Log4r::Logger.
  DESCR
  s.require_path = "lib"
  s.files = %w{
    rakefile_minitest-logger.rb
    lib/minitest-logger.rb
    lib/minitest/log4r.rb
    lib/minitest/logger.rb
    examples/example_assertions.rb
    examples/example_specification.rb
  }
  s.test_files    = %w{
    unittest/test_load_minitest-logger.rb
    unittest/test_minitest-logger.rb
    unittest/test_minitest-log4r.rb
  }
  #~ s.test_files   << Dir['unittest/expected/*']
  s.test_files.flatten!

  #~ s.bindir = "bin"
  #~ s.executables << 'minitest-logger.rb'

  s.rdoc_options << '--main lib/minitest-logger.rb'
  s.rdoc_options << '--title "Rdoc: Minitest-logger"'
  s.extra_rdoc_files = %w{
    examples/example_assertions.rb
    examples/example_specification.rb
  }
  
  #~ s.add_dependency('') 
  s.add_dependency('minitest','>= 0') #tested with "5.5.1" (rb1.9.3 + rb 2.1.5)
  #~ s.add_dependency('log4r')
  
  #~ s.add_development_dependency()
  s.requirements << 'Log4r or Logger'

  gemdef.public = true
  #~ gemdef.add_ftp_connection('ftp.rubypla.net', Knut::FTP_RUBYPLANET_USER, Knut::FTP_RUBYPLANET_PW, "/Ruby/gemdocs/minitest-logger/#{$minitest_logger_version}")

  gemdef.define_test( 'unittest', FileList['test_load*.rb'])
  gemdef.define_test( 'unittest', FileList['test_minitest*.rb'])
  gemdef.versions << Minitest::Logger_VERSION 

}

#generate rdoc
task :rdoc_local do
  FileUtils.rm_r('doc') if File.exist?('doc')
  cmd = ["rdoc -f hanna"]
  cmd << gem_minitest_logger.spec.lib_files
  cmd << gem_minitest_logger.spec.extra_rdoc_files
  cmd << gem_minitest_logger.spec.rdoc_options
  `#{cmd.join(' ')}`
end

#~ desc "Gem minitest-logger"
#~ task :default => :check
task :default => :test
#~ task :default => :gem
#~ task :default => :install
#~ task :default => :hanna
#~ task :default => :rdoc_local
#~ task :default => :links
#~ task :default => :ftp_rdoc
#~ task :default => :push


if $0 == __FILE__
  app = Rake.application
  app[:default].invoke
end
__END__

Versions:
0.1.0 2015-04-16 https://rubygems.org/gems/minitest-logger/versions/0.1.0
* Initial version

0.1.1
* Add option formatter for log4r