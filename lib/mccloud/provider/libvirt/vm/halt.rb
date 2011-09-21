module Mccloud::Provider
  module Libvirt
    module VmCommand

      def halt(options)

        if self.running?
          env.ui.info "Halting machine #{@name}(#{@raw.id})"
          raw.shutdown
          raw.wait_for { printf "."; STDOUT.flush; state=="stopped"||state=="crashed"}
          env.ui.info ""
        else
          env.ui.info "#{@name}(#{raw.id}) is already halted."
        end

      end

    end #module
  end #module
end #module
