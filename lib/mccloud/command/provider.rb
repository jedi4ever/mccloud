module Mccloud
  module EnvironmentCommand
    
     def boot(selection=nil,options=nil)
       @config.providers.each do |name,provider|
         provider.boot(selection,command,options)
       end
     end

     def bootstrap(selection=nil,options=nil)
       @config.providers.each do |name,provider|
         provider.bootstrap(selection,options)
       end
     end
     
     def halt(selection,options)
       @config.providers.each do |name,provider|
         provider.halt(selection,options)
       end
     end

     def rsync(selection,path,options)
       @config.providers.each do |name,provider|
         provider.rsync(selection,path,options)
       end
     end


  end
end
