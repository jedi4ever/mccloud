module Mccloud::Provider::LIBVIRT::Command::
  module Vm
  
    def boot(selection=nil,options=nil)
      puts "Booting of libvirt here"
      require 'pp'
      pp @raw_provider.servers.all
    end
    
  end #module
end #module
