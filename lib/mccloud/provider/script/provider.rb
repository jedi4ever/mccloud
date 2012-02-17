require 'mccloud/provider/script/vm'
require 'mccloud/util/platform'
require 'mccloud/provider/core/provider'

module Mccloud
  module Provider
    module Script
      class Provider  < ::Mccloud::Provider::Core::Provider

        attr_accessor :name
        attr_accessor :flavor

        attr_accessor :options

        attr_accessor :vms

        attr_accessor :script_dir
        attr_accessor :variables

        #include Mccloud::Provider::Script::ProviderCommand


        def initialize(name,options,env)

          super(name,options,env)

          @vms=Hash.new
          @variables=Hash.new

          @options=options
          @flavor=self.class.to_s.split("::")[-2]
          @name=name
        end

        def up(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            script_exec("up.sh",vm,options)
          end
        end

        def status(selection,options)
          unless selection.nil?
          on_selected_components("vm",selection) do |id,vm|
            script_exec("status.sh",vm,options)
          end
          else
            script_exec("status.sh",nil,options)
          end
        end

        def bootstrap(selection,script,options)
          on_selected_components("vm",selection) do |id,vm|
            script_exec("bootstrap.sh",vm,options)
          end

        end

        def destroy(selection,options)

          on_selected_components("vm",selection) do |id,vm|
            script_exec("destroy.sh",vm,options)
          end

        end

        def ssh(selection,command,options)

          on_selected_components("vm",selection) do |id,vm|
            script_exec("ssh.sh",vm,options)
          end

        end

        def provision(selection,options)

          on_selected_components("vm",selection) do |id,vm|
            script_exec("provision.sh",vm,options)
          end

        end

        def halt(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            script_exec("provision.sh",vm,options)
          end

        end

        private
        def script_exec(filename,vm,options)

          # Set provider variables
          unless vm.nil?
            vm.variables.each do |name,value|
              env.logger.info "setting environment: #{name}=#{value}"
              ENV["MC_"+name.to_s]=value
            end
          end

          # Set vm variables
          unless vm.nil?
            @variables.each do |name,value|
              env.logger.info "setting environment: #{name}=#{value}"
              ENV["MC_"+name.to_s]=value
            end
          end

          # Some hackery going on here. On Mac OS X Leopard (1.5), exec fails
          # (GH-51). As a workaround, we fork and wait. On all other platforms,
          # we simply exec.
          pid = nil
          pid = fork if ::Mccloud::Util::Platform.leopard? || ::Mccloud::Util::Platform.tiger?

          env.ui.info "Executing internal ssh command"
          script_command="#{File.join(self.script_dir,filename)}"
          env.ui.info script_command
          Kernel.exec "sh #{script_command}" if pid.nil?
          Process.wait(pid) if pid
        end

      end
    end
  end
end
