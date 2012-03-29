module Mccloud
  module Command
    class ForwardCommand < Base

      register "forward [NAME]", "Forwards ports from a machine to localhost"
      argument :selection, :type => :string, :optional => true, :default => nil

      def execute
        env.load!
        threads=Array.new
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to forward ports from #{selection} to localhost")
          trap("INT") { puts "You've hit CTRL-C . Stopping server now"; exit }
          provider.on_selected_components("vm",selection) do |id,vm|
            fwds=vm.forward(options)
            unless fwds.nil?
              fwds.each do |f|
                threads << f
              end
            end
            threads.each { |thr| thr.join}
          end

        end

      end
    end
  end
end
