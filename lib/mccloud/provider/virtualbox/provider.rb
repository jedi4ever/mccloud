require 'mccloud/provider/virtualbox/provider/status'
require 'mccloud/provider/virtualbox/vm'
require 'mccloud/provider/core/provider'

module Mccloud
  module Provider
    module Virtualbox
      class Provider  < ::Mccloud::Provider::Core::Provider

        attr_accessor :name
        attr_accessor :flavor

        attr_accessor :options

        attr_accessor :vms

        include Mccloud::Provider::Virtualbox::ProviderCommand


        def initialize(name,options,env)

          super(name,options,env)
          @options=options
          @flavor=self.class.to_s.split("::")[-2]
          @name=name
          @vms=Hash.new

          required_gems=%w{vagrant}
          check_gem_availability(required_gems)
          require 'vagrant'
          require 'vagrant/cli'

        end

        #We use this to get access to the logger attribute
        class LogEnvironment < ::Vagrant::Environment
          def logger=(logger)
            @logger=logger
          end
        end

        def raw
          if @raw.nil?
            begin
              @raw=LogEnvironment.new(:cwd => ".")
              require 'logger'
              vlogger=::Logger.new(STDOUT)
              vlogger.formatter=Proc.new do |severity, datetime, progname, msg|
                "#{datetime} - #{progname} - #{msg}\n"
                #" [#{resource}] #{msg}\n"
              end
              #          @raw.ui=Vagrant::UI.new(@raw)
              #          @raw.ui.logger=
              @raw.logger=vlogger

              @raw.load!
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

        def bootstrap(selection,command,options)
          on_selected_components("vm",selection) do |id,vm|
            vm.bootstrap(command,options)
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
            env.ui.info  "Matched #{vm.name}"
            vm.halt(options)
          end

        end

      end
    end
  end
end
