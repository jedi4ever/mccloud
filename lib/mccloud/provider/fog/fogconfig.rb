module Mccloud
  module Provider
    module Fog
      class FogConfig

        attr_reader :credential
        def initialize(credential)
          @credential=credential
        end

        def exists?
          return File.exists?(::Fog.credentials_path)
        end

        def missing_credentials(keynames)
          missing_credentials=Array.new
          ::Fog.credential=@credential

          keynames.each do |key|
            unless ::Fog.credentials.has_key?(key)
              #            missing_credentials << key
            end
          end
        end
      end
    end
  end
end
