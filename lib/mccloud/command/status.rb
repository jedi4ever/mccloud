module Mccloud
  module Command
    def status
      load_config
      Kernel.load File.join(Dir.pwd,"Mccloudfile")
      unless options.verbose?
        puts "only mccloud stuff"
      else
        printf "%-40s %-41s %-12s %-20s %-10s\n", "Name", "Public Name", "Instance Id", "IP", "Type"
        159.times { |i| printf "=" } ; puts
        PROVIDER.servers.each do |vm|
          name="<no name set>"
          if !vm.tags["Name"].nil?
            name=vm.tags["Name"].strip
          end
          printf "%-40s %-41s %-12s %-20s %-10s %-10s\n",name, vm.dns_name,vm.id, vm.public_ip_address, vm.flavor.name,vm.state
        end
      end
    end
  end
end