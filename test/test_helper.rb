require "rubygems"
dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"
$LOAD_PATH.unshift "../wrong/lib"

require "minitest/spec"
require "pp"
require "benchmark"

require "wrong"
require "wrong/adapters/minitest"
require "wrong/message/test_context"
require "wrong/message/string_diff"
Wrong.config[:color] = true

module Kernel
  alias_method :regarding, :describe
  
  def xregarding(str)
    puts "x'd out 'regarding \"#{str}\"'"
  end
end

class MiniTest::Spec
  class << self
    alias_method :test, :it
    
    def xtest(str)
      puts "x'd out 'test \"#{str}\"'"
    end

  end
end

def run_suite(wildcard)
  #simple way to make sure requires are isolated
  result = Dir[wildcard].collect{|test_file| system("ruby #{test_file}") }.uniq == [true]
  puts "suite " + (result ? "passed" : "FAILED")
  exit(result ? 0 : 1)
end

MiniTest::Unit.autorun
