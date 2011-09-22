require 'mccloud/config/component'
require 'mccloud/keypair'
require 'ostruct'

module Mccloud
  class Config
    class Keypair

      attr_accessor :components
      attr_reader :env

      def initialize(config)
        @env=config.env
        @components=Hash.new
        env.logger.debug("initalizing keypair")
      end

      def define(name)
        # We do this for vagrant syntax
        # Depending on type, we create a variable of that type
        # f.i. component_stub.vm or component_stub.lb
        keypair_stub=OpenStruct.new
        keypair_stub.keypair=::Mccloud::Keypair.new(name,env)

        env.logger.debug("config keypair"){ "Start reading keypair"}

        yield keypair_stub

        env.logger.debug("config keypair"){ "End reading keypair #{keypair_stub.keypair.name}"}

        components[name.to_s]=keypair_stub.keypair
      end

    end
  end
end #Module Mccloud
