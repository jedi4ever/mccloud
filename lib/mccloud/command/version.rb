module Mccloud
  module Command
    class VersionCommand < Base

      register "version", "Prints the Mccloud version information"

      def execute
        env.ui.info "Version : #{Mccloud::VERSION} - use at your own risk"
      end

    end

  end
end
