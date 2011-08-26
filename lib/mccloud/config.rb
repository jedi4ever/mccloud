require 'mccloud/config/mccloud'
require 'mccloud/config/provider'
require 'mccloud/config/collection'

module Mccloud
  class Config

    include ::Mccloud::Logger
    
    attr_accessor :mccloud
    
    attr_accessor :vms,:lbs,:stacks,:ips
    attr_accessor :providers

    def initialize(options={})
      @logger=options[:logger] unless options[:logger].nil?
      @vms=Hash.new;@lbs=Hash.new;@stacks=Hash.new;@ips=Hash.new
    end
    
    def define()
      config=OpenStruct.new
      
      # These two don't depend on a provider
      config.mccloud=::Mccloud::Config::Mccloud.new
           
      config.provider=::Mccloud::Config::Provider.new
      @providers=config.provider.components
      
      
      # These components depend on a provider, so we try to guess it frst
      config.vm=::Mccloud::Config::Collection.new("vm",self)
      config.lb=::Mccloud::Config::Collection.new("lb",self)
      config.ip=::Mccloud::Config::Collection.new("ip",self)
      config.stack=::Mccloud::Config::Collection.new("stack",self)
      
      yield config

      @mccloud=config.mccloud
#      pp @vms
#      @vms=config.vm.components
#      @lbs=config.lb.components
#      @ips=config.ip.components
#      @stacks=config.stack.components
      
    end
    
    # We put a long name to not clash with any function in the Mccloud file itself
    def load_mccloud_config(options=nil)
      mccloud_configurator=self
      begin
        mccloudfile=File.read(File.join(Dir.pwd,"Mccloudfile"))
        mccloudfile["Mccloud::Config.run"]="mccloud_configurator.define"
#        http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
        instance_eval(mccloudfile)
      rescue LoadError => e
        logger.error "Error loading configfile - Sorry"
        logger.error e.message  
        exit -1
      rescue NoMethodError => e
        logger.error "Some method got an error in the configfile - Sorry"
        logger.error $!
        logger.error e.message  
        exit -1
      rescue Error => e
        logger.error "Error processing configfile - Sorry"
        logger.error e.message  
        exit -1
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