module Mccloud::Provider
  module Aws
    module ProviderCommand

      def status(selection=nil,options=nil)

        env.ui.info ""
        env.ui.info "Server(s) - provider #{@name}"

        printf "%-10s %-12s %-20s %-15s %-8s\n", "Name", "Instance Id", "IP", "Type","Status"
        80.times { |i| printf "=" } ; env.ui.info ""

        # List servers
        raw.servers.each do |vm|
          name="<no name set>"
          if !vm.tags["Name"].nil?
            name=vm.tags["Name"].strip
          end #end if

          if name.start_with?(self.filter)
            unless self.filter==""
              name[self.filter]=""
              printf "%-10s %-12s %-20s %-20s %-15s %-8s\n",name,vm.id, vm.public_ip_address, vm.private_ip_address,vm.flavor_id,vm.state
            else
              env.ui.info "Name: #{name}"
              env.ui.info "Instance Id: #{vm.id}"
              env.ui.info "Public Ip: #{vm.public_ip_address}"
              env.ui.info "Flavor: #{vm.flavor.name}"
              env.ui.info "State: #{vm.state}"
              80.times { |i| printf "=" } ; env.ui.info ""
            end
          end
        end #End 1 provider

        # List images
        env.ui.info ""
        env.ui.info "Image(s) - provider #{@name}"
        80.times { |i| printf "=" } ; env.ui.info ""
        images_list=raw.images.all({"Owner" => "self"})
        images_list.each do |image|
          printf "%-10s %-10s %-10s %-20s\n",image.id,image.name.gsub(/"#{filter}"/,''),image.state, image.description.to_s[0..20]
        end

        # List volumes
        env.ui.info ""
        env.ui.info "Volume(s) - provider #{@name}"
        80.times { |i| printf "=" } ; env.ui.info ""
        volume_list=raw.volumes.all()
        volume_list.each do |volume|
          printf "%-10s %-10s %-10s %-20s\n",volume.id,volume.device,volume.server_id, volume.size
        end
        env.ui.info ""

      end

    end #module
  end #module
end #module
