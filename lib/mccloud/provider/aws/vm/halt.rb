module Mccloud::Provider
  module Aws
    module VmCommand

      def halt(options)

        if self.running?
          env.ui.info "Halting machine #{@name}(#{@raw.id})"
          raw.stop
          raw.wait_for { printf "."; STDOUT.flush; state=="stopped"}
          env.ui.info ""
        else
          unless @raw.nil?
            env.ui.info "#{@name}(#{@raw.id}) is already halted."
          else
            env.ui.info "#{@name} is not yet created or was terminated"
          end
        end

      end

    end #module
  end #module
end #module
