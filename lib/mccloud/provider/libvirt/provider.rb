require 'mccloud/provider/libvirt/provider/status'
require 'mccloud/provider/libvirt/vm'
require 'mccloud/provider/fog/provider'

module Mccloud
  module Provider
    module Libvirt
      class Provider  < ::Mccloud::Provider::Fog::Provider

        attr_accessor :name
        attr_accessor :flavor

        attr_accessor :options

        attr_accessor :vms

        include Mccloud::Provider::Libvirt::ProviderCommand


        def initialize(name,options,env)

          super

          @vms=Hash.new

          @options=options
          @flavor=self.class.to_s.split("::")[-2]
          @name=name

          required_gems=%w{ruby-libvirt fog}
          check_gem_availability(required_gems)
          require 'libvirt'
          require 'fog'
        end


        def raw
          if @raw.nil?
            begin
              @raw=::Fog::Compute.new({:provider => "Libvirt"}.merge(@options))
            rescue ArgumentError => e
              env.ui.error "Error loading raw provider : #{e.to_s} #{$!}"
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



        def provision(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            vm._provision(options)
          end
        end

        def halt(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            vm.halt(options)
          end
        end

        def reload(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            vm.reload(options)
          end
        end

      end
    end
  end
end
