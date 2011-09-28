module Mccloud::Provider
  module Libvirt
    module VmCommand

      def up(options)

        env.ui.info "Upping of libvirt vm #{@name}"

        # There is no existing machine yet, so we create it
        if raw.nil?
          enhanced_create_options=@create_options
          enhanced_create_options[:name]="#{@provider.filter}#{@name}"
          env.ui.info "[#{@name}] - Creating machine #{@provider.namespace}::#{@name}"
          @raw=@provider.raw.servers.create(enhanced_create_options)
          raw.start

          env.ui.info "[#{@name}] - Waiting for the machine to become accessible"
          raw.wait_for { printf "."; STDOUT.flush;  ready?}

          # Wait for ssh to become available ...
          env.ui.info "[#{@name}] - Waiting for ip address"
          #env.ui.info instance.console_output.body["output"]
          raw.wait_for { printf "."; STDOUT.flush;  !public_ip_address.nil?}

          env.ui.info "[#{@name}] - Waiting for ssh on #{self.ip_address} to become available"
          Mccloud::Util.execute_when_tcp_available(self.ip_address, { :port => @port, :timeout => 6000 }) do
            env.ui.info "[#{@name}] - Ssh is available , proceeding with bootstrap"
          end

          # Because it's a new machine we bootstrap it to
          self._bootstrap(nil,options)

        else
          state=raw.state
          if state !="running"
            env.ui.info "Booting up machine #{@name}"
            raw.start
            raw.wait_for { printf ".";STDOUT.flush;  ready?}
            env.ui.info ""
          else
            unless raw.state == "shutting-down"
              env.ui.info "[#{@name}] - already running."
            else
              env.ui.info "[#{@name}] - can't start machine because it is in state #{raw.state}"
              return
            end
          end

        end

        unless options["noprovision"]
          env.ui.info "[#{@name}] - Waiting for ssh to become available"
          Mccloud::Util.execute_when_tcp_available(self.ip_address, { :port => @port, :timeout => 6000 }) do
            env.ui.info "[#{@name}] - Ssh is available , proceeding with provisioning"
          end

          env.ui.info "[#{@name}] - provision step #{@name}"
          self._provision(options)
        end

      end

    end #module
  end #module
end #module
