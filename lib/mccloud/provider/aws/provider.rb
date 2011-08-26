require 'mccloud/provider/core/provider'

require 'mccloud/provider/aws/provider/status'
require 'mccloud/provider/aws/vm'
require 'mccloud/provider/aws/lb'
require 'mccloud/provider/aws/ip'

module Mccloud
  module Provider
    module Aws
    class Provider  < ::Mccloud::Provider::Core::Provider

      attr_accessor :name
      attr_accessor :type

      attr_accessor :options
      
      attr_accessor :vms
      attr_accessor :lbs
      attr_accessor :ips
      
      attr_accessor :check_keypairs
      attr_accessor :check_securitygroups

      include Mccloud::Provider::Aws::ProviderCommand


    def initialize(name,options)

      
      @check_securitygroups=true
      @check_keypairs=true
      
      @options=options    
      @type=self.class.to_s.split("::")[-2]
      @name=name

      # Initializing the components
      @vms=Hash.new
      @lbs=Hash.new
      @ips=Hash.new
      
      required_gems=%w{fog}
      check_gem_availability(required_gems)
      require 'fog'

    end

    
    def raw
      if @raw.nil?
        begin
          @raw=Fog::Compute.new({:provider => "Aws"}.merge(@options))
        rescue ArgumentError => e
          puts "Error loading raw provider : #{e.to_s} #{$!}"
          @raw=nil
        end
      end
      return @raw
    end
    
    def filter
      if @namespace.nil? || @namespace==""
        return ""
      else
        return "#{@namespace}-"
      end
    end

    def up(selection,options)
      on_selected_components("vm",selection) do |id,vm|
        vm.up(options)
      end
    end

    def bootstrap(selection,script,options)

      on_selected_components("vm",selection) do |id,vm|
        vm._bootstrap(script,options)
      end

    end
    
    def destroy(selection,options)

      on_selected_components("vm",selection) do |id,vm|
        vm.destroy(options)
      end

    end
    
    def ssh(selection,command,options)

      on_selected_components("vm",selection) do |id,vm|
        vm.ssh(command,options)
      end

    end

    def rsync(selection,path,options)

      on_selected_components("vm",selection) do |id,vm|
        vm.rsync(path,options)
      end

    end
    
    
    def provision(selection,options)

      on_selected_components("vm",selection) do |id,vm|
        vm._provision(options)
      end

    end
    
    def halt(selection,options)
      on_selected_components("vm",selection) do |id,vm|
        puts "Matched #{vm.name}"
        vm.halt(options)
      end

    end

  end
  end
  end
end
