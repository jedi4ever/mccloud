module Mccloud
  module Configurator
    class MccloudConfigurator
      attr_accessor :prefix
      attr_accessor :loglevel
      
      def initialize()
          @prefix="mccloud"
          @loglevel=:info
      end      
    end
  end
end