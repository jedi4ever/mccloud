require 'mccloud/util/platform'
require 'net/ssh'

module Mccloud
  module Provider
    module Core
      module VmCommand

        def ssh_bootstrap(command,bootstrap_options= {})
          begin
            options = Hash.new

            options[:port] = @port

            unless @bootstrap_user.nil?
              options[:user] = @bootstrap_user
            end

            unless @bootstrap_password.nil?
              options[:password] = @bootstrap_password
            end

            if self.running?
              scriptname=command.nil? ? @bootstrap : command
              unless scriptname.nil?
                env.logger.info "[#{@name}] - Using #{scriptname} as bootstrap script"
                full_scriptname=Pathname.new(scriptname).expand_path(env.root_path).to_s
                env.logger.info "[#{@name}] - Full #{full_scriptname} "
                env.ui.info "[#{@name}] - Uploading bootstrap code to machine #{@name}"

                unless !File.exists?(full_scriptname)
                  begin
                    self.transfer(full_scriptname,"/tmp/bootstrap.sh",options)
                  rescue Net::SSH::AuthenticationFailed
                    raise ::Mccloud::Error, "[#{@name}] - Authentication problem \n"
                  rescue Exception => ex
                    raise ::Mccloud::Error, "[#{@name}] - Error uploading file #{full_scriptname} #{ex.inspect}\n"
                  end
                  env.ui.info "[#{@name}] - Enabling the bootstrap code to run"
                  result=self.execute("chmod +x /tmp/bootstrap.sh && #{self.sudo_string("/tmp/bootstrap.sh",options)}",options)


                else
                  raise ::Mccloud::Error, "[#{@name}] - Error: bootstrap file #{scriptname} does not exist"
                end

              else
                env.ui.warn "[#{@name}] - You didn't specify a bootstrap, hope you know what you're doing."
              end
            else
              env.ui.warn "[#{@name}] - Server is not running, so bootstrapping will do no good"
            end
          rescue ::Net::SSH::AuthenticationFailed => ex
            raise ::Mccloud::Error, "[#{@name}] - Authentication failure #{ex.to_s}"
          end
        end

      end #Module
    end #module
  end #Module
end #module

