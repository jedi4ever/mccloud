require 'lib/mccloud/vm'
module Mccloud
  class Vms < Hash

    attr_reader :env

    def initialize(env)
      @env=env
    end

    def define(name,definitionname)
      # Check if definition  exists
      unless env.config.definitions.registered?(definitionname)
        raise ::Mccloud::Error, "Definition #{definitionname} does not exist"
      end
      # Create the vms dir if needed
      unless self.exists?
        self.create
      end

      vm=::Mccloud::Vm.new(name,env)
      unless vm.exists?
       vm.definition=env.config.definitions[definitionname]
       vm.create
      end
    end

    def load!
      if self.exists?
        Dir[File.join(self.path,"**.rb")].each do |dir|
          name=File.basename(dir,'.rb')
          vm=::Mccloud::Vm.new(name,env)
          vm.load!
        end
      else
        env.logger.info "Skipping loading of vms as the vm_path does exist"
      end
    end

    def path
      @env.config.mccloud.vm_path
    end

    def exists?
      File.directory?(self.path)
    end

    def create
     begin
      unless self.exists?
        env.logger.info "Creating the vms directory #{self.path} as it doesn't exist yet"
        FileUtils.mkdir(self.path)
      end
      rescue Exception => ex
         raise ::Mccloud::Error, "Error creating vms directory #{self.path}: \n#{ex}"
      end
    end

  end
end
