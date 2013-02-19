module Mccloud::Provider
  module Libvirt
    module VmCommand

      def transfer(src,dest,options = {})
        scp(src,dest,options)
      end

       def scp(src,dest, options = {})
         raw.scp(src,dest,options)
      end

       end #module
      end #module
    end #module
