require 'mccloud/config/component'
require 'mccloud/definition'
require 'ostruct'

module Mccloud
  class Config
    class Definition

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
        definition_stub=OpenStruct.new
        definition_stub.definition=::Mccloud::Definition.new(name,env)

        env.logger.debug("config definitions"){ "Start reading definitions"}

        yield definition_stub

        env.logger.debug("config definitions"){ "End reading definition #{definition_stub.definition.name}"}

        components[name.to_s]=definition_stub.definition
      end

    end
  end
end #Module Mccloud
