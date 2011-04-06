require 'net/ssh/multi'

module Mccloud
  module Command
    #http://stackoverflow.com/questions/1383282/netsshmulti-using-the-session-exec-how-do-you-get-the-output-straight-away
    #https://gist.github.com/700730
    def multi(selection=nil,command="who am i",options=nil)
      trap("INT") { puts "we hit CTRL_C"; exit }
      
      Net::SSH::Multi.start do |session|
         # Connect to remote machines
         ip2name=Hash.new
         on_selected_machines(selection) do |id,vm|
           instance=vm.instance
           if instance.state == "running"
             ip2name[instance.public_ip_address]=vm.name
             session.use "#{instance.public_ip_address}", { :user => vm.user , :keys => [ vm.private_key ], :paranoid => false, :keys_only => true}
           end
         end

        puts "Executing #{command}"
        begin
         session.exec("#{command}") do |ch, stream, data|
         #exit code
         #http://groups.google.com/group/comp.lang.ruby/browse_thread/thread/a806b0f5dae4e1e2
         
         ch.on_request("exit-status") do |ch, data|
           exit_code = data.read_long
           @status=exit_code
           if exit_code > 0
             puts "ERROR: exit code #{exit_code}"
           else
             puts "Successfully executed"
           end
         end
            if (ip2name.count > 1) || options.verbose?
              puts "[#{ip2name[ch[:host]]}] #{data}"
            else
              print "#{data}"              
            end
           # puts "[#{ch[:host]} : #{stream}] #{data}"

         end
       rescue Errno::ECONNREFUSED
         puts "oops - no connection"
       end
         # Tell Net::SSH to wait for output from the SSH server
         session.loop  
      end
      
    end
  end
end