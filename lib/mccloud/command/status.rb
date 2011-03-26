module Mccloud
  module Command
    def status(selection=nil,options=nil)
      unless options.verbose?
        puts "only mccloud stuff"
      else
        printf "%-40s %-41s %-12s %-20s %-10s\n", "Name", "Public Name", "Instance Id", "IP", "Type"
        159.times { |i| printf "=" } ; puts

        @session.config.providers.each  do |name,provider|
          provider.servers.each do |vm|
            name="<no name set>"
            if !vm.tags["Name"].nil?
              name=vm.tags["Name"].strip
            end #end if

            printf "%-40s %-41s %-12s %-20s %-10s %-10s\n",name, vm.dns_name,vm.id, vm.public_ip_address, vm.flavor.name,vm.state

          end #End 1 provider
        end #providers
      end #unless
    end #def
  end #module
end