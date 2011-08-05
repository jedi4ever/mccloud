module Mccloud
  module Command
    def status(selection=nil,options=nil)
      
      @session.config.providers.each do |name,provider|
        provider.status(selection,options)
      end
        
    end #def
  end #module
end
