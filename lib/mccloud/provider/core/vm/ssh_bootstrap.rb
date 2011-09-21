require 'mccloud/util/platform'

module Mccloud
  module Provider
    module Core
      module VmCommand

        def ssh_bootstrap(command,options=nil)
          begin
            scriptname=command.nil? ? @bootstrap : command
            env.logger.info "[#{@name}] - Using #{scriptname} as bootstrap script"

            if raw.ready?
              unless scriptname.nil?
                env.ui.info "[#{@name}] - Uploading bootstrap code to machine #{@name}"

                unless !File.exists?(scriptname)
                  raw.scp(scriptname,"/tmp/bootstrap.sh")
                  env.ui.info "[#{@name}] - Enabling the bootstrap code to run"
                  result=raw.ssh("chmod +x /tmp/bootstrap.sh")

                  sudo_cmd="sudo"
                  sudo_cmd=options["sudo"] unless options["sudo"].nil?

                  self.ssh("#{sudo_cmd} /tmp/bootstrap.sh",options)

                else
                  env.ui.info "[#{@name}] - Error: bootstrap file #{scriptname} does not exist"
                  exit -1
                end

              else
                env.ui.info "[#{@name}] - You didn't specify a bootstrap, hope you know what you're doing."
              end
            else
              env.ui.info "[#{@name}] - Server is not running, so bootstrapping will do no good"
            end
          rescue Net::SSH::AuthenticationFailed => ex
            env.ui.info "[#{@name}] - Authentication failure #{ex.to_s}"
          end
        end

      end #Module
    end #module
  end #Module
end #module

