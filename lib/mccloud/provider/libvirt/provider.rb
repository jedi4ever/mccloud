require 'mccloud/provider/libvirt/provider/status'
require 'mccloud/provider/libvirt/vm'
require 'mccloud/provider/core/provider'

module Mccloud
  module Provider
    module Libvirt
    class Provider  < ::Mccloud::Provider::Core::Provider

      attr_accessor :name
      attr_accessor :type

      attr_accessor :options
      
      attr_accessor :vms

      include Mccloud::Provider::Libvirt::ProviderCommand


    def initialize(name,options)
      @vms=Hash.new
      
      @options=options    
      @type=self.class.to_s.split("::")[-2]
      @name=name

      required_gems=%w{ruby-libvirt fog}
      check_gem_availability(required_gems)
      require 'libvirt'
      require 'fog'
    end

    
    def raw
      if @raw.nil?
        begin
          @raw=Fog::Compute.new({:provider => "Libvirt"}.merge(@options))
        rescue ArgumentError => e
          puts "Error loading raw provider : #{e.to_s} #{$!}"
          @raw=nil
        end
      end
      return @raw
    end

    def up(selection,options)
      on_selected_components("vm",selection) do |id,vm|
        vm.up(options)
      end
    end

    def bootstrap(selection,options)
      on_selected_components("vm",selection) do |id,vm|
        vm.bootstrap(options)
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
