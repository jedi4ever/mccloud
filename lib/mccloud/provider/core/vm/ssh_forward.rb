module Mccloud
  module Provider
    module Core
      module VmCommand


        def ssh_forward(options=nil)
          return ssh_tunnel_start(@forwardings)
        end

        def ssh_tunnel_start(forwardings)
          unless forwardings.empty?
            @forward_threads<< Thread.new(self) { |vm|
              env=vm.env
              begin
                ssh_options={ :paranoid => false, :keys_only => true}
                ssh_options[:keys]= [ vm.private_key_path ] unless vm.private_key_path.nil?
                Net::SSH.start(vm.ip_address, vm.user, ssh_options) do |ssh_session|
                  vm.forwardings.each do |f|
                    begin
                      env.ui.info "Forwarding remote port #{f.remote} on #{vm.ip_address} from #{@name} to localhost port #{f.local}"
                      ssh_session.forward.local(f.local.to_i, "127.0.0.1",f.remote.to_i)
                      #ssh_session.forward.local(f.local.to_i, vm.ip_address,f.remote.to_i)
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
