module Mccloud::Provider
  module Aws
    module VmCommand

     def security_group_has_ssh_open?(group)
      return false
     end

     def security_group_exists?(group)
      return !@provider.raw.security_groups.get(group).nil?
     end

    def security_group_is_managed_by_mccloud?(group)
        return /^1mccloud/ =~ group
    end

     def check_security_groups(groups)
        if @provider.check_security_groups
          # Iterate over all groups
          groups.each do |group|

            if security_group_exists?(group)
              env.logger.info "security group #{group} exists"
            else
              env.logger.info "security group #{group} doest not exist"
              if security_group_is_managed_by_mccloud?(group)
                # Managed by mccloud
                env.logger.info "security group #{group} starts with mccloud"
                env.ui.info "Creating security group #{group}"
                @provider.create_sg(group)
              else
                # Not managed by mccloud
                raise Mccloud::Error, "security group #{group} does not exits. And we only managed security groups with prefix mccloud"
              end
            end

            unless security_group_has_ssh_open?(group)
            end
          end
        end
      end

      def check_key(key_name)
        if @provider.raw.key_pairs.get(key_name).nil?
          raise Mccloud::Error, "keypair #{key_name} does not exist"
        end
      end

      def up(options)


        if raw.nil? || raw.state =="terminated"

          create_options= {
            :private_key_path => @private_key_path ,
            :public_key_path => @public_key_path,
            :availability_zone => @zone,
            :image_id => @ami,
            :flavor_id => @flavor,
            :key_name => @key_name,
            :groups => @security_groups
          }.merge(@create_options)

          check_security_groups(create_options[:groups])
          check_key(create_options[:key_name])

          env.ui.info "Creating new vm #{@name} for provider #{@provider.name}"
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



