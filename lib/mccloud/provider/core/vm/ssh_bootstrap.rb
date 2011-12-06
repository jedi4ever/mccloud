require 'mccloud/util/platform'
require 'net/ssh'

module Mccloud
  module Provider
    module Core
      module VmCommand

        def ssh_bootstrap(command,options=nil)
          begin

            if raw.ready?
              scriptname=command.nil? ? @bootstrap : command
              unless scriptname.nil?
                env.logger.info "[#{@name}] - Using #{scriptname} as bootstrap script"
                full_scriptname=Pathname.new(scriptname).expand_path(env.root_path).to_s
                env.logger.info "[#{@name}] - Full #{full_scriptname} "
                env.ui.info "[#{@name}] - Uploading bootstrap code to machine #{@name}"

                unless !File.exists?(full_scriptname)
                  begin
                    raw.scp(full_scriptname,"/tmp/bootstrap.sh")
                  rescue Exception => ex
                    raise ::Mccloud::Error, "[#{@name}] - Error uploading file #{full_scriptname}\n"+ex
                  end
                  env.ui.info "[#{@name}] - Enabling the bootstrap code to run"
                  result=raw.ssh("chmod +x /tmp/bootstrap.sh")

                  sudo_cmd="sudo"
                  sudo_cmd=options["sudo"] unless options["sudo"].nil?

                  self.ssh("#{sudo_cmd} /tmp/bootstrap.sh",options)

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

