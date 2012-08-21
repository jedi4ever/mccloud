module Mccloud
  module Util
    def self.rsync(path,vm,instance)
      unless !File.exists?(path)
        env.logger.info "[#{vm.name}] - rsyncing #{path}"
        command="rsync  --exclude='.DS_Store' --exclude='.git' --exclude='.hg' --delete --delete-excluded  -az -e 'ssh -p 22 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i \"#{vm.private_key}\"' '#{path}/' '#{vm.user}@#{instance.public_ip_address}:/tmp/#{File.basename(path)}/'"
        Kernel.exec(command)
      else
        raise Mccloud::Error, "[#{vm.name}] - rsync error: #{path} does no exist"
      end
    end
  end
end

