module Mccloud
	class Configuration
		attr_accessor :ami
	end
	module Config
		class << self; attr_accessor :config end
		def self.run
			@config=Configuration.new
			yield @config
		end
	end
end
