require 'mccloud/util/platform'

module Mccloud::Provider
  module LIBVIRT
    module Command

      class Vm

        def initialize(vm,provider)
          @vm=vm
          @provider=provider
        end


        def ssh(command=nil,options=nil)

          instance=@provider.raw_provider.servers.all(:name => @vm.name).first
          if options.screen?
            extra_command="\"screen -R \\\"#{command}\\\"\""
          else
            extra_command="\"#{command}\""
          end

#          vm=@session.config.vms[name]
#          if vm.instance.nil?
#            puts "#{name} is not available anymore"
#            return
#          end
#          if vm.instance.state != "running"
#            puts "#{name} is not running, move along"
#            return
#          end

          @vm.user="veewee"
          #https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/ssh.rb
          options={ :port => 22, :private_key_path => @vm.private_key, 
            :username => @vm.user , :host => instance.public_ip_address , :password => "veewee" }
            # Command line options
            command_options = ["-p #{options[:port]}", "-o UserKnownHostsFile=/dev/null",
            "-t -o StrictHostKeyChecking=no", "-o IdentitiesOnly=yes","-o VerifyHostKeyDNS=no",
            "-i #{options[:private_key_path]}"]
            # Some hackery going on here. On Mac OS X Leopard (10.5), exec fails
            # (GH-51). As a workaround, we fork and wait. On all other platforms,
            # we simply exec.
            pid = nil
            pid = fork if Mccloud::Util::Platform.leopard? || Mccloud::Util::Platform.tiger?

            command_exec="ssh #{command_options.join(" ")} #{options[:username]}@#{options[:host]} #{extra_command}".strip

            puts "Executing - #{command_exec}"
            puts
            Kernel.exec command_exec if pid.nil?
            Process.wait(pid) if pid
 
          end



      end #clas
    end #module
  end #Module
end #module
