require 'mccloud/generators'

module Mccloud
  module Command
  def self.init(amiId=nil,options=nil)
    Mccloud::Generators.run_cli Dir.pwd, File.basename(__FILE__), Mccloud::VERSION, ARGV
  end
end
end
