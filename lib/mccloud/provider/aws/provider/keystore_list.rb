module Mccloud
  module Provider
    module Aws
      module ProviderCommand

        def keystore_list(selection=nil,options=nil)

          if raw.key_pairs.empty?
            env.ui.info("No Keypairs found")
          else
            raw.key_pairs.each do |keypair|
              env.ui.info "KeyPair #{keypair.name} - #{keypair.fingerprint}"
            end
          end

        end

      end
    end
  end

end
