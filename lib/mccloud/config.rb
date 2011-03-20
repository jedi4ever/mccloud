module Mccloud
	class Vm
		attr_accessor :ami
		attr_accessor :provider
		attr_accessor :provider_options
		attr_accessor :name
		attr_accessor :user
		attr_accessor :key
		attr_accessor :bootstrap
		def define(name)
			config=Configuration.new
			yield config
			config.vm.name=name
			Mccloud::Config.config.vms[name.to_s]=config.vm
		end
		def forward_port(local,remote,host)
		end
	end
  	class MccloudSettings
		attr_accessor :prefix
	end
	class Configuration
		attr_accessor :vms
		attr_reader :vm
		attr_accessor :mccloud

		def initialize
			@vm=Vm.new	
			@vms=Hash.new
			@mccloud=MccloudSettings.new	
		end
	end
	module Config
		class << self; attr_accessor :config end
		def self.run
			@config=Configuration.new
			yield @config
		end
	end
end
