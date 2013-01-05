module Mccloud::Provider
  module Vagrant
    module ProviderCommand

    def status(selection=nil,options=nil)

      self.raw.cli(['status',selection])

    end

    end #module
  end #module
end #module

