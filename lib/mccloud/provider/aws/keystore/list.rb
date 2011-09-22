module Mccloud::Provider
  module Aws
    module KeystoreCommand

      def list(options)
        
          provider.raw.key_pairs.each do |keypair|
            env.logger.info "#{keypair.name} - #{keypair.fingerprint}"
          end
          
      end

    end
  end
end
