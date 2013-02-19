require 'mccloud/template'
require 'mccloud/templates'
require 'mccloud/vms'
require 'mccloud/definition'
require 'mccloud/definitions'
require 'mccloud/keypair'
require 'mccloud/config/mccloud'
require 'mccloud/config/provider'
require 'mccloud/config/template'
require 'mccloud/config/keypair'
require 'mccloud/config/definition'
require 'mccloud/config/collection'


module Mccloud
  class Config

    #    include ::Mccloud::Logger

    attr_accessor :mccloud

    attr_reader :env

    attr_accessor :vms,:lbs,:stacks,:ips,:keystores,:keypairs
    attr_accessor :providers

    attr_accessor :templates,:definitions

    def initialize(options)
      @env=options[:env]
      env.logger.info("config") { "Initializing empty list of vms,lbs,stacks, ips in config" }

      @lbs=Hash.new;@stacks=Hash.new;@ips=Hash.new; @keystores=Hash.new; @keypairs=Hash.new;

      @providers=Hash.new; 
      @templates=::Mccloud::Templates.new(env)
      @definitions=::Mccloud::Definitions.new(env)
      @vms=::Mccloud::Vms.new(env)
    end

    def define()
      config=OpenStruct.new

      # These don't depend on a provider
      config.mccloud=::Mccloud::Config::Mccloud.new(self)
      @mccloud=config.mccloud

      # Assign templates
      config.template=::Mccloud::Config::Template.new(self)
      config.template.components=@templates

      # Assign definitions
      config.definition=::Mccloud::Config::Definition.new(self)
      config.definition.components=@definitions

      # Assign keypairs
      config.keypair=::Mccloud::Config::Keypair.new(self)
      config.keypair.components=@keypairs

      # Assign providers
      config.provider=::Mccloud::Config::Provider.new(self)
      config.provider.components=@providers

      # These components depend on a provider, so we try to guess it frst
      # This will access self's variables like :
      #         vms,lbs, ips, etc by simply putting an 's' after the type
      config.vm=::Mccloud::Config::Collection.new("vm",self)
      config.lb=::Mccloud::Config::Collection.new("lb",self)
      config.ip=::Mccloud::Config::Collection.new("ip",self)
      config.stack=::Mccloud::Config::Collection.new("stack",self)
      config.keystore=::Mccloud::Config::Collection.new("keystore",self)

      # Process config file
      yield config

    end

    # We put a long name to not clash with any function in the Mccloud file itself
    def load_mccloud_config()
      mccloud_configurator=self
      begin
        mccloud_file=File.read(File.join(env.root_path,env.mccloud_file))
        env.logger.info("Reading #{mccloud_file}")
        mccloud_file.gsub!("Mccloud::Config.run","mccloud_configurator.define")
        #        http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
        instance_eval(mccloud_file)
      rescue LoadError => e
        raise ::Mccloud::Error, "Error loading configfile - Sorry: #{e.message}"
      rescue NoMethodError => e
        raise ::Mccloud::Error, "Some method got an error in the configfile - Sorry\n#{$!}\n#{e.message}"
      rescue Errno::ENOENT => e
        raise ::Mccloud::Error, "You need a Mccloudfile to be able to run mccloud, run mccloud init to create one, #{e}"
      rescue ::Mccloud::Error => e
        raise ::Mccloud::Error, "#{e}"
      rescue Error => e
        raise ::Mccloud::Error, "Error processing configfile - Sorry"
      end
      return self
    end



    def stackfilter
      vmfilter=self.filter
      filter=vmfilter.gsub!(/[^[:alnum:]]/, '')
      return filter
    end

    def filter()
      mcfilter=Array.new
      if !@prefix.nil?
        mcfilter << @prefix
      end
      if @environment!=""
        mcfilter << @environment
      end
      if @identity!=""
        mcfilter << @identity
      end
      full_filter=mcfilter.join(@delimiter)
      if full_filter.length>0
        full_filter=full_filter+@delimiter
      end
      return full_filter

    end



  end #End Class
end #End Module
