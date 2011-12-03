module Mccloud::Provider
  module Aws
    module VmCommand

      def transfer(src,dest)
        scp(src,dest)
      end

       def scp(src,dest)
         unless File.exists?(src)
          raise Mccloud::Error,"scp failed: #{src} does not exist"
         end
         @raw.scp(src,dest)
      end

       end #module
      end #module
    end #module
