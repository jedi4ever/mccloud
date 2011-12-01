require 'mccloud/provider/core/provider'

require 'mccloud/provider/fog/fogconfig'

module Mccloud
  module Provider
    module Fog
      class Provider  < ::Mccloud::Provider::Core::Provider

        def initialize(name,options,env)
          super(name,options,env)
        end

        def check_fog_credentials(keynames)
          fogconfig=::Mccloud::Provider::Fog::FogConfig.new(@credential)
          unless fogconfig.exists?
            raise Mccloud::Error, "No Fog configfile #{::Fog.credentials_path}"
          end

          missing_credentials=fogconfig.missing_credentials(keynames)
          errormsg="Missing Credentials\n"
          unless missing_credentials.empty?
            missing_credentials.each do |key|
               errormsg+="-key #{key}\n"
            end
          end
          raise Mccloud::Error, "#{errormsg}"
        end


      end
    end
  end
end
