module Mccloud
  module Command
    def command(selection=nil,command="who am i")
      unless options.parallel?
      on_selected_machines(selection) do |id,vm|
        server=PROVIDER.servers.get(id)
        server.private_key_path=vm.private_key
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
