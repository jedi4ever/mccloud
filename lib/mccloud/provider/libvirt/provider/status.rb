module Mccloud::Provider
  module Libvirt
    module ProviderCommand
  
    def status(selection=nil,options=nil)

      puts
      puts "Server(s) - provider #{@name}"
        
      printf "%-10s %-12s %-20s %-15s %-8s\n", "Name", "Instance Id", "IP", "Type","Status"
      80.times { |i| printf "=" } ; puts
      
      raw.servers.each do |vm|
        if vm.name.start_with?(self.filter)
          unless self.filter==""
            vm.name[self.filter]=""
            printf "%-10s %-12s %-20s %-20s %-15s %-8s\n",vm.name,vm.mac, vm.public_ip_address, vm.cpus,vm.memory_size,vm.state
          else
            puts "Name: #{vm.name}"
            puts "Instance Id: #{vm.uuid}"
            puts "Public Ip: #{vm.public_ip_address}"
            puts "Cpus: #{vm.cpus}"
            puts "State: #{vm.state}"
            80.times { |i| printf "=" } ; puts
          end
        end
      end


      puts "Volume(s) - provider #{@name}"
      80.times { |i| printf "=" } ; puts
        volume_list=raw.volumes.all() 
        volume_list.each do |volume|
            printf "%-20s: %-10s %-10s \n",volume.name,volume.id,volume.key
            printf "%-20s: %-10s %-20s %-10s\n","",volume.pool_name, volume.path, volume.format_type
            printf "%-20s: %-10s %-10s\n","",volume.capacity,volume.allocation
        end
        
    end
    
    end #module  
  end #module
end #module

