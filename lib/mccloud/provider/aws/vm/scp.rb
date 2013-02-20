module Mccloud::Provider
  module Aws
    module VmCommand

      def transfer(src,dest,options = {})
        scp(src,dest,options)
      end

      def scp(local_path, remote_path, scp_options = {})
        unless File.exists?(local_path)
          raise Mccloud::Error,"scp failed: #{local_path} does not exist"
        end

        #@raw.scp(src,dest)
        scp_options[:key_data] = [@raw.private_key] if @raw.private_key

        ::Fog::SCP.new(self.ip_address, @raw.username, sanitize(scp_options)).upload(local_path, remote_path, {})
      end

      #
      # sanitize the options by converting to a hash with
      # all keys converted to symbols as required by net/ssh
      #
      def sanitize(options)
        Hash[options.map{|(k,v)| [k.to_sym,v]}]
      end

    end #module
  end #module
end #module
