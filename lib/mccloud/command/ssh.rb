module Mccloud
  module Command
  def ssh(selection=nil,command=nil)
    load_config
    if options.screen?
      extra_command="\"screen -R \\\"#{command}\\\"\""
    else
      extra_command="\"#{command}\""
    end
    
    if selection.nil?
      Mccloud::Config.config.vms
      selection=Mccloud::Config.config.vms.first[0]
    end
    name=selection
    prefix=Mccloud::Config.config.mccloud.prefix
    id=all_servers["#{prefix} - #{name}"]

    instance=PROVIDER.servers.get(id)
    if instance.state != "running"
      puts "#{name} is not running, move along"
      return
    end
    vm=Mccloud::Config.config.vms[name]

    #https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/ssh.rb
    options={ :port => 22, :private_key_path => vm.key, 
      :username => vm.user , :host => instance.public_ip_address }
      # Command line options
      command_options = ["-p #{options[:port]}", "-o UserKnownHostsFile=/dev/null",
      "-t -o StrictHostKeyChecking=no", "-o IdentitiesOnly=yes",
      "-i #{options[:private_key_path]}"]
      # Some hackery going on here. On Mac OS X Leopard (10.5), exec fails
      # (GH-51). As a workaround, we fork and wait. On all other platforms,
      # we simply exec.
      pid = nil
      pid = fork if Mccloud::Util::Platform.leopard? || Mccloud::Util::Platform.tiger?

      command_exec="ssh #{command_options.join(" ")} #{options[:username]}@#{options[:host]} #{extra_command}".strip
      puts "#{command_exec}"
      Kernel.exec command_exec if pid.nil?
      Process.wait(pid) if pid
    end

    desc "command [NAME] [COMMAND]", "exec a command on a box"
    method_options :parallel => :boolean
    def command(selection=nil,command="who am i")
      load_config
      unless options.parallel?
      on_selected_machines(selection) do |id,vm|
        server=PROVIDER.servers.get(id)
        server.private_key_path=vm.key
        server.username = vm.user
          if server.state == "running"
            result=server.ssh(command)
        puts result[0].stdout
      else
          puts "not running so what's the point"
      end
      end
     else
       invoke :multi , [selection, command]
      end
    end
  end
end
