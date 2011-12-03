require 'mccloud/provider/host/provider/status'
require 'mccloud/provider/host/vm'
require 'mccloud/provider/core/provider'

module Mccloud
  module Provider
    module Host
      class Provider  < ::Mccloud::Provider::Core::Provider

        attr_accessor :name
        attr_accessor :flavor

        attr_accessor :options

        attr_accessor :vms

        include Mccloud::Provider::Host::ProviderCommand


        def initialize(name,options,env)

          super(name,options,env)

          @vms=Hash.new

          @options=options
          @flavor=self.class.to_s.split("::")[-2]
          @name=name
        end

        def raw
          # We don't use this
          @raw=nil
        end
        def up(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            vm.up(options)
          end
        end

        def bootstrap(selection,script,options)
          on_selected_components("vm",selection) do |id,vm|
            vm.bootstrap(script,options)
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
            env.ui.info "Matched #{vm.name}"
            vm.halt(options)
          end

        end

      end
    end
  end
end
