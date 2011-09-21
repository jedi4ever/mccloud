module Mccloud::Provider
  module Libvirt
    module VmCommand

      def up(options)

        puts "Upping of libvirt vm #{@name}"

        # There is no existing machine yet, so we create it
        if raw.nil?
          enhanced_create_options=@create_options
          enhanced_create_options[:name]="#{@provider.filter}#{@name}"
          puts "[#{@name}] - Creating machine #{@provider.namespace}::#{@name}"
          @raw=@provider.raw.servers.create(enhanced_create_options)
          raw.start

          puts "[#{@name}] - Waiting for the machine to become accessible"
          raw.wait_for { printf "."; STDOUT.flush;  ready?}

          # Wait for ssh to become available ...
          puts "[#{@name}] - Waiting for ssh to become available"
          #puts instance.console_output.body["output"]

          Mccloud::Util.execute_when_tcp_available(self.ip_address, { :port => @port, :timeout => 6000 }) do
            puts "[#{@name}] - Ssh is available , proceeding with bootstrap"
          end

          # Because it's a new machine we bootstrap it to
          self._bootstrap(nil,options)

        else
          state=raw.state
          if state !="running"
            puts "Booting up machine #{@name}"
            raw.start
            raw.wait_for { printf ".";STDOUT.flush;  ready?}
            puts
          else
            unless raw.state == "shutting-down"
              puts "[#{@name}] - already running."
            else
              puts "[#{@name}] - can't start machine because it is in state #{raw.state}"
              return
            end
          end

        end

        unless options["noprovision"]
          puts "[#{@name}] - Waiting for ssh to become available"
          Mccloud::Util.execute_when_tcp_available(self.ip_address, { :port => @port, :timeout => 6000 }) do
            puts "[#{@name}] - Ssh is available , proceeding with provisioning"
          end

          puts "[#{@name}] - provision step #{@name}"
          self._provision(options)
        end

      end

    end #module
  end #module
end #module
