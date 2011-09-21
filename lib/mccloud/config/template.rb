require 'mccloud/config/component'
require 'mccloud/template'
require 'ostruct'

module Mccloud
  class Config
    class Template

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
        template_stub=OpenStruct.new
        template_stub.template=::Mccloud::Template.new(name,env)

        env.logger.debug("config template"){ "Start reading template"}

        yield template_stub

        env.logger.debug("config template"){ "End reading template #{template_stub.template.name}"}

        components[name.to_s]=template_stub.template
      end

    end
  end
end #Module Mccloud
