require 'net/scp'
module Mccloud::Provider
  module Host
    module VmCommand

      def transfer(src,dest,options = {})
        scp(src,dest,options)
      end

       def scp(src,dest,options = {})
         Net::SCP.upload!(ip_address,@user,src,dest,options)
      end

       end #module
      end #module
    end #module
