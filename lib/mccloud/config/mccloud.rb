module Mccloud
  class Config
    class Mccloud

      attr_reader :env

      attr_accessor :prefix
      attr_accessor :environment
      attr_accessor :identity

      attr_accessor :delimiter
      attr_accessor :loglevel

      attr_accessor :template_path
      attr_accessor :definition_path
      attr_accessor :vm_path

      def initialize(config)
        @env=config.env

        @prefix="mccloud"
        @environment=""
        @identity=""

        @delimiter="-"
        @loglevel=:info

        @template_path=File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','templates'))
        @definition_path=File.join(@env.root_path,"definitions")
        @vm_path=File.join(@env.root_path,"vms")

        env.logger.debug("done loading the mccloud setting")

      end


    end #Class
  end #Module
end #Module
