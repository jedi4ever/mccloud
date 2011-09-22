module Mccloud
  module Provider
    module Core

     class Keystore
        attr_reader :env
        attr_accessor :provider
        attr_accessor :name
        attr_accessor :auto_selection

        def initialize(env)
          @auto_selection=true
          @env=env
        end

        def auto_selected?
          return auto_selection
        end

     end
    end
  end
end
