module Mccloud::Provider
  module LIBVIRT
    module Command
      
    class Vm
  
    def initialize(vm,provider)
      @vm=vm
      @provider=provider
    end

    def up
      if  @vm.server_id.nil?
        puts "machine #{@vm.name} does not yet exit"
        enhanced_create_options=@vm.create_options
        enhanced_create_options[:template_options][:name]=@vm.name
        newvm=@provider.raw_provider.servers.create(enhanced_create_options)
        @vm.server_id=newvm.name
#        @provider.raw_provider.servers.create
      end
      
      puts "Upping of libvirt vm #{@vm.server_id}"

      server=@provider.raw_provider.servers.all(:name => @vm.server_id).first
      server.start()
    end
  end

end #module
end #module
end #module
