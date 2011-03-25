module Mccloud
  module Command
  def init(amiId=nil)
    load_config
    Mccloud::Generators.run_cli Dir.pwd, File.basename(__FILE__), Mccloud::VERSION, ARGV
  end
end
end
