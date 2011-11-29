require 'mccloud/config/component'
require 'ostruct'

module Mccloud
  class Config
    class Provider

      attr_accessor :components
      attr_reader :env

      def initialize(config)
        @env=config.env
        @components=Hash.new
      end

      def define(name)
        # We do this for vagrant syntax
        # Depending on type, we create a variable of that type
        # f.i. component_stub.vm or component_stub.lb
        provider_stub=OpenStruct.new
        provider_stub.provider=OpenStruct.new

        env.logger.debug("config provider"){ "Start stubbing provider"}

        # Now we can 'execute' the config file using our stub component
        # For guessing the provider type
        yield provider_stub

        env.logger.debug("config provider"){ "End stubbing provider"}

        # After processing we extract the provider type and options again
        provider_type=provider_stub.provider.flavor
        env.logger.debug("config provider"){ "Found provider of type #{provider_type}"}
        provider_options=provider_stub.provider.options

        begin
          # Now that we know the actual provider, we can check if the provider has this type of component
          require_path='mccloud/provider/'+provider_type.to_s.downcase+"/provider"
          require require_path

          # Now we can create the real provider
          real_provider=Object.const_get("Mccloud").const_get("Provider").const_get(provider_type.to_s.capitalize).const_get("Provider").new(name,provider_options,env)
          provider_stub.provider=real_provider
          yield provider_stub

          env.logger.debug("config provider"){ "Instantiating provider #{name.to_s}"}
          components[name.to_s]=provider_stub.provider
        rescue Error => e
          env.ui.error "Error loading provider with #{name},#{$!}"
        end
      end

    end
  end
end #Module Mccloud
