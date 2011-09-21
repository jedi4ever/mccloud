module Mccloud::Provider
  module Libvirt
    module VmCommand
      def reload(options)
         env.logger.info "Checking if #{@name} is running: #{self.running?}"
        if self.running?
          self.halt(options)
        end
        self.up(options)
      end
    end
  end
end
