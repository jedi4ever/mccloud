module Mccloud
  module Provider
    module Core
      module VmCommand


        def ssh_forward(options=nil)
          return ssh_tunnel_start(@forwardings)
        end

        def ssh_tunnel_start(forwardings)
          unless forwardings.empty?
            ssh_options={ :paranoid => false, :keys_only => true}
            ssh_options[:keys]= [ @private_key_path ] unless @private_key_path.nil?
            @forward_threads<< Thread.new(self) { |vm|
              env=vm.env
              begin
                Net::SSH.start(vm.ip_address, vm.user, ssh_options) do |ssh_session|
                  vm.forwardings.each do |f|
                    begin
                      env.ui.info "Forwarding remote port #{f.remote} from #{@name} to localhost port #{f.local}"
                      ssh_session.forward.local(f.local, "127.0.0.1",f.remote)
                    rescue Errno::EACCES
                      env.ui.error "Error - Access denied to forward remote port #{f.remote} from #{@name} to localhost port #{f.local}"
                    end
                  end
                  ssh_session.loop {true}
                end
              rescue IOError
                env.ui.error "IOError - maybe there is no listener on the port (yet?)"
              end
            }
          end
            return @forward_threads
          end

          def ssh_tunnel_stop
            @forward_threads.each do |thread|
              Thread.kill(thread)
            end
          end

        end #Module
      end #module
    end #Module
  end #module
