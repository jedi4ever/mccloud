require 'mccloud/util/platform'
require 'pp'

module Mccloud
  module Command
  def ssh(selection=nil,command=nil,options=nil)
    if options.screen?
      extra_command="\"screen -R \\\"#{command}\\\"\""
    else
      extra_command="\"#{command}\""
    end
    
    if selection.nil?
      @session.config.vms
      selection=@session.config.vms.first[0]
    end
    
    name=selection
    vm=@session.config.vms[name]
    if vm.instance.nil?
      puts "#{name} is not available anymore"
      return
    end
    if vm.instance.state != "running"
      puts "#{name} is not running, move along"
      return
    end

    #https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/ssh.rb
    options={ :port => 22, :private_key_path => vm.private_key, 
      :username => vm.user , :host => vm.instance.public_ip_address }
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

 
  end
end
