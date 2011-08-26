require 'mccloud/util/platform'

module Mccloud::Provider
  module Libvirt
    module VmCommand

        def _bootstrap(options=nil)
            begin 
              puts "We are bootstrapped"
            if raw.ready?
              
              puts "[#{@name}] - Waiting for an ip-address "
              
              raw.wait_for {   printf "."; STDOUT.flush; !public_ip_address.nil? }
              puts
              unless @bootstrap.nil?
                puts "[#{@name}] - Uploading bootstrap code"
                unless !File.exists?(@bootstrap)
                  raw.scp(@bootstrap,"/tmp/bootstrap.sh")
                  puts "[#{@name}] - Enabling the bootstrap code to run"
                  result=raw.ssh("chmod +x /tmp/bootstrap.sh")
                  
                  sudo_cmd="sudo"
                  sudo_cmd=options["sudo"] unless options["sudo"].nil?
                  
                  self.ssh("#{sudo_cmd} /tmp/bootstrap.sh",options)
  #                multi(selection,"/tmp/bootstrap.sh",options.merge({ "sudo" => true}))

                else
                  puts "[#{@name}] - Error: bootstrap file #{@bootstrap} does not exist"
                  exit -1
                end
              else
                puts "[#{@name}] - You didn't specify a bootstrap, hope you know what you're doing."
              end
            else
              puts "[#{@name}] - server is not running, so bootstrapping will do no good"
            end
          rescue Net::SSH::AuthenticationFailed => ex
            puts "[#{@name}] - Authentication failure #{ex.to_s}"
          end
          end

    end #module
  end #Module
end #module
