module Mccloud::Provider
  module Aws
    module VmCommand

      def up(options)

        env.ui.info "Upping of aws vm #{@name}"

        if raw.nil? || raw.state =="terminated"
          env.ui.info "[#{@name}] - Spinning up a new machine"

          create_options= {
            :private_key_path => @private_key_path ,
            :public_key_path => @public_key_path,
            :availability_zone => @zone,
            :image_id => @ami,
            :flavor_id => @flavor,
            :key_name => @key_name,
            :groups => @security_groups
          }.merge(@create_options)

          env.logger.info "Creating new vm for provider AWS with options #{create_options}"
          begin
            @raw=@provider.raw.servers.create(create_options)
          rescue Fog::Compute::AWS::NotFound => ex
            #Oh we got an error
            #Let's see if we need to create keypair mccloud

            env.ui.error "Error creating the new server: #{ex}"
            return
          end

          env.ui.info "[#{@name}] - Waiting for the machine to become accessible"
          raw.wait_for { printf "."; STDOUT.flush;  ready?}
          env.ui.info ""
          @provider.raw.create_tags(raw.id, { "Name" => "#{@provider.filter}#{@name}"})

          # Wait for ssh to become available ...
          env.ui.info "[#{@name}] - Waiting for ssh port to become available"
          #env.ui.info instance.console_output.body["output"]

          Mccloud::Util.execute_when_tcp_available(self.ip_address, { :port => @port, :timeout => 6000 }) do
            env.ui.info "[#{@name}] - Ssh Port is available"
          end

          #TODO: check for ssh to really work
          env.ui.info "Waiting for the ssh service to become available"
          sleep 5
          env.ui.info "[#{@name}] - Ssh Service is available , proceeding with bootstrap"
          # No bootstrap to provide
          self._bootstrap(nil,options)

        else
          state=raw.state
          if state =="stopped"
            env.ui.info "Booting up machine #{@name}"
            raw.start
            raw.wait_for { printf ".";STDOUT.flush;  ready?}
            env.ui.info ""
          else
            unless raw.state == "shutting-down" || raw.state =="terminated"
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



