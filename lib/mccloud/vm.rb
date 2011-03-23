module Mccloud
  class Vm
    attr_accessor :ami
    attr_accessor :provider
    attr_accessor :provider_options
    attr_accessor :name
    attr_accessor :user
    attr_accessor :key
    attr_accessor :bootstrap
    def define(name)
      config=Configuration.new
      yield config
      config.vm.name=name
      Mccloud::Config.config.vms[name.to_s]=config.vm
    end
    def provision(type)
      provisioner=ChefSolo.new
      yield provisioner
      Mccloud::Config.config.chef=provisioner
    end
    def forward_port(local,remote,host)
    end
  end
end #Module Mccloud