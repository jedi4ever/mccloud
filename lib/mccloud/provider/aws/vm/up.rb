module Mccloud::Provider
  module Aws
    module VmCommand

        def up(options)
          
          puts "Upping of aws vm #{@name}"

            if raw.nil? || raw.state =="terminated"
              puts "[#{@name}] - Spinning up a new machine"

              create_options=@create_options.merge({ :private_key_path => @private_key_path , :public_key_path => @public_key_path, :username => @user})

              @raw=@provider.raw.servers.create(create_options)

              puts "[#{@name}] - Waiting for the machine to become accessible"
              raw.wait_for { printf "."; STDOUT.flush;  ready?}
              puts
              @provider.raw.create_tags(raw.id, { "Name" => "#{@provider.filter}#{@name}"})

              # Wait for ssh to become available ...
              puts "[#{@name}] - Waiting for ssh to become available"
              #puts instance.console_output.body["output"]

              Mccloud::Util.execute_when_tcp_available(self.ip_address, { :port => @port, :timeout => 6000 }) do
                puts "[#{@name}] - Ssh is available , proceeding with bootstrap"
              end

              self._bootstrap(options)

            else
              state=raw.state
              if state =="stopped"
                puts "Booting up machine #{@name}"
                raw.start
                raw.wait_for { printf ".";STDOUT.flush;  ready?}
                puts
              else
                unless raw.state == "shutting-down" || raw.state =="terminated"
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



