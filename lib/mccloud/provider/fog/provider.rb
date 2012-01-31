require 'mccloud/provider/core/provider'
require 'mccloud/provider/fog/fogconfig'

module Mccloud
  module Provider
    module Fog
      class Provider  < ::Mccloud::Provider::Core::Provider

        attr_accessor :credentials_path

        def initialize(name,options,env)
          super(name,options,env)
          required_gems=%w{fog}
          check_gem_availability(required_gems)
          require 'fog'
          @credentials_path=::Fog.credentials_path
        end

        def check_fog_credentials(keynames)
          ::Fog.credentials_path=@credentials_path

          errormsgs=["Missing Credentials"]
          fogconfig=::Mccloud::Provider::Fog::FogConfig.new(@credential)

          missing_credentials=fogconfig.missing_credentials(keynames)
          unless missing_credentials.empty?

            unless fogconfig.exists?
              errormsgs<<"Create the file #{::Fog.credentials_path} with the following content:"
            else
              errormsgs<<"Add the following snippet to #{::Fog.credentials_path}:"
            end

            errormsgs<< "=====================  snippet begin ====================="
            errormsgs<< fogconfig.missing_snippet(keynames)
            errormsgs<< "=====================  snippet end   ====================="
            errormsg=errormsgs.join("\n")

            raise Mccloud::Error, "#{errormsg}"
          end
        end

      end
    end
  end
end
