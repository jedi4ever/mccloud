module Mccloud::Provider
  module Libvirt
    module VmCommand
         
      def transfer(src,dest)
        scp(src,dest)
      end
             
       def scp(src,dest) 
         raw.scp(src,dest)
      end 
      
       end #module
      end #module
    end #module
