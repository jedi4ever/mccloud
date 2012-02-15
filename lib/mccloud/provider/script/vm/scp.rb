require 'net/scp'
module Mccloud::Provider
  module Script
    module VmCommand
         
      def transfer(src,dest)
        scp(src,dest)
      end
             
       def scp(src,dest) 
         Net::SCP.upload!(ip_address,@user,src,dest)
      end 
      
       end #module
      end #module
    end #module
