module Mccloud
  module Command
    def status(selection=nil,options=nil)

      printf "%-10s %-12s %-20s %-15s %-8s\n", "Name", "Instance Id", "IP", "Type","Status"
      80.times { |i| printf "=" } ; puts

      unless options.verbose?
        filter=@session.config.mccloud.prefix
      else
        filter=""
      end

      @session.config.providers.each  do |name,provider|
          provider.servers.each do |vm|
            name="<no name set>"
            if !vm.tags["Name"].nil?
              name=vm.tags["Name"].strip
            end #end if

            if name.start_with?(filter)
              unless filter==""
                name[filter+" - "]=""
              end
              printf "%-10s %-12s %-20s %-15s %-8s\n",name,vm.id, vm.public_ip_address, vm.flavor.name,vm.state
            end
          end #End 1 provider
        end #providers
    end #def
  end #module
end