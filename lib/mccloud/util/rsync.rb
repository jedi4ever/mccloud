require "pty"
module Mccloud
  module Util
    def self.rsync(path,vm,instance)
      unless !File.exists?(path)
        env.logger.info "[#{vm.name}] - rsyncing #{path}"
        command="rsync  --exclude '.DS_Store' --delete  -az -e 'ssh -p 22 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i \"#{vm.private_key}\"' '#{path}/' '#{vm.user}@#{instance.public_ip_address}:/tmp/#{File.basename(path)}/'"
      else
        raise Mccloud::Error, "[#{vm.name}] - rsync error: #{path} does no exist"
      end
    begin
      PTY.spawn( command ) do |r, w, pid|
        begin
          r.each { |line| print line;}
       rescue Errno::EIO
       end
     end
   rescue PTY::ChildExited => e
      puts "The child process exited!"
         end
      #Kernel.exec(command)
    end
  end
end

