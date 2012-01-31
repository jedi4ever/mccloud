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
               missing_credentials << key
            end
          end
          return missing_credentials
        end

        def missing_snippet(keynames)
          # Reading the existing file if needed
          path=::Fog.credentials_path
          keys={}
          if File.exists?(path)
            keys=YAML.load(File.read(path))
          end
          missing_credentials(keynames).each do |key|
            keys[@credential]=Hash.new if keys[@credential].nil?
            keys[@credential][key]="<your #{key}>"
          end
          return keys.to_yaml
        end
      end
    end
  end
end

