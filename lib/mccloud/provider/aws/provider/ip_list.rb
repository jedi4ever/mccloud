module Mccloud
  module Provider
    module Aws
      module ProviderCommand

        def ip_list(selection=nil,options=nil)
          env.logger.info("#{selection} - #{options}")
          raw.addresses.each do |address|
            env.ui.info "Ip-address #{address.public_ip} - Server-Id #{address.server_id}"
          end
        end

      end
    end
  end

end
