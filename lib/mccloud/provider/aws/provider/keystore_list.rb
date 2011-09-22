module Mccloud
  module Provider
    module Aws
      module ProviderCommand

        def keystore_list(selection=nil,options=nil)

          env.logger.info("#{selection} - #{options}")          
          raw.key_pairs.each do |keypair|
            env.logger.info "KeyPair #{keypair.name} - #{keypair.fingerprint}"
          end

        end

      end
    end
  end

end
