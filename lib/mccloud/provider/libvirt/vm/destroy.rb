module Mccloud::Provider
  module Libvirt
    module VmCommand

        def destroy(options)
          fullname="#{@provider.filter}#{@name}"
          server=@provider.raw.servers.all(:name => fullname)  
          volname="#{fullname}.img"  
          #TODO use the creation options
          volume=@provider.raw.volumes.all(:name => volname)    
          
          unless server.nil?
            puts "[#{@name}] - Destroying machine #{@provider.namespace}::#{@name}"
            
            server.first.destroy
          else
            puts "[#{@name}] - Server #{@provider.namespace}::#{@name} does not exist"
          end
          
          unless volume.nil?
            puts "[#{@name}] - Destroying volume #{@provider.namespace}::#{@name}.img"
            
            volume.first.destroy
          else
            puts "[#{@name}] - Volume #{@provider.namespace}::#{@name}.img does not exist"

          end
          
        end
 
    end #module
  end #module
end #module
