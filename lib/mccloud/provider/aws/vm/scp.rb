module Mccloud::Provider
  module Aws
    module VmCommand

      def transfer(src,dest)
        scp(src,dest)
      end

       def scp(local_path, remote_path, scp_options = {})
         unless File.exists?(local_path)
          raise Mccloud::Error,"scp failed: #{local_path} does not exist"
         end
         #@raw.scp(src,dest)
         scp_options[:key_data] = [@raw.private_key] if @raw.private_key

         ::Fog::SCP.new(self.ip_address, @raw.username, scp_options).upload(local_path, remote_path, {})
      end

       end #module
      end #module
    end #module
