module Mccloud::Provider
  module LIBVIRT
    module Command
  
    def status(selection=nil,options=nil)
      puts "Status of libvirt here"
      require 'pp'
      pp @raw_provider.servers.all

      pp @raw_provider.volumes.all

    end
    
    end #module  
  end #module
end #module