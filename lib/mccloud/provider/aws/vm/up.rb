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
        return /^mccloud/ =~ group
    end

     def check_security_groups(groups)
        if @provider.check_security_groups
          # Iterate over all groups
          groups.each do |group|

            if security_group_exists?(group)
              env.logger.info "security group #{group} exists"
            else
              env.logger.info "security group #{group} does not yet exist"
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

    def key_is_managed_by_mccloud?(keyname)
        return /^mccloud/ =~ keyname
    end

      def check_key(key_name)
        if @provider.check_keypairs
          raw_keypair=@provider.raw.key_pairs.get(key_name)
          if raw_keypair.nil?
                raise Mccloud::Error, "keypair #{key_name} does not exits. And we only managed keys with prefix mccloud"
            raise Mccloud::Error, "keypair #{key_name} does not exist"
          end
        end
      end

      def up(options={})

        if raw.nil? || raw.state =="terminated"

          create_options= {
            :private_key_path => @private_key_path ,
            :public_key_path => @public_key_path,
            :availability_zone => @zone,
            :image_id => @ami,
            :flavor_id => @flavor,
            :key_name => @key_name,
            :user_data => @user_data,
            :groups => @security_groups,
            :tags  => @tags
          }.merge(@create_options)

          # Always add the name tag
          create_options[:tags]["Name"] = "#{@provider.filter}#{@name}"

          check_security_groups(create_options[:groups])
          check_key(create_options[:key_name])

          env.ui.info "Creating new vm #{@name} for provider #{@provider.name}"
          begin
            @raw=@provider.raw.servers.create(create_options)
          rescue ::Fog::Compute::AWS::NotFound => ex
            raise ::Mccloud::Error, "Error creating the new server: #{ex}"
            return
          end

          env.ui.info "[#{@name}] - Waiting for the machine to become accessible"
          raw.wait_for { printf "."; STDOUT.flush;  ready?}
          env.ui.info ""

          # Wait for ssh to become available ...
          env.ui.info "[#{@name}] - Waiting for ssh port to become available"

          Mccloud::Util::Ssh.execute_when_tcp_available(self.ip_address, { :port => @port, :timeout => 6000 }) do
            env.ui.info "[#{@name}] - Ssh Port is available"
          end

          Mccloud::Util::Ssh.when_ssh_login_works(self.ip_address, { :user => @user, :port => @port, :timeout => 6000 ,:keys => [@private_key_path]}) do
            env.ui.info "[#{@name}] - Ssh login works , proceeding with bootstrap"
          end
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
          Mccloud::Util::Ssh.execute_when_tcp_available(self.ip_address, { :port => @port, :timeout => 6000 }) do
            env.ui.info "[#{@name}] - Ssh is available , proceeding with provisioning"
          end

          env.ui.info "[#{@name}] - provision step #{@name}"
          self._provision(options)
        end


      end

    end #module
  end #module
end #module
