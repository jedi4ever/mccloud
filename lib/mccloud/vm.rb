module Mccloud

  class Vm

    attr_accessor :name
    attr_reader :env
    attr_accessor :definition

    def initialize(name,env)
      @name=name
      @env=env
    end

    def exists?
      File.exists?(self.path)
    end

    def path
      File.join(@env.config.mccloud.vm_path,@name+".rb")
    end

    def load!
      self.validate

      content=File.read(self.path)
      mccloud_configurator=env.config
      content.gsub!("Mccloud::Config.run","mccloud_configurator.define")

      begin
        env.config.instance_eval(content)
      rescue Error => ex
        raise ::Mccloud::Error, "Error reading vm from file #{definition_file}#{ex}"
      end
    end

    def create
      begin
        unless self.exists?
          File.open(self.path,'w'){ |f| f.write(self.to_template)}
        else
          raise ::Mccloud::Error, "VM file #{self.path} already exists"
        end
      rescue Error => ex
        raise ::Mccloud::Error, "Error writing vm file"
      end
    end

    def to_template
      result=""
      filename=File.expand_path(File.join(File.dirname(__FILE__),'templates','vm.erb'))
      env.logger.info "Opening vm template file #{@file}"
      template=File.new(filename).read
      result=ERB.new(template).result(binding)
      return result
    end

    def validate
      raise ::Mccloud::Error, "Vm #{@name} does not yet exist" unless self.exists?
    end
  end
end

