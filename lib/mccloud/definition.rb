module Mccloud

  class Definition

    attr_accessor :name
    attr_reader :env
    attr_reader :provider

    def initialize(name,env)
      @name=name
      @env=env
      @type="vm"
    end

    def provider=(name)
      @provider=name
      @raw=env.config.providers[name].get_component(@type.capitalize,env)
    end

    def method_missing(m, *args, &block)
      #puts  "There's no method called #{m} here -- please try again."
      @raw.send(m,*args)
    end

    def valid?
      File.exists?(self.definition_path)
    end

    def exists?
      File.directory?(self.path)
    end

    def path
      File.join(@env.config.mccloud.definition_path,@name)
    end

    def definition_path
      File.join(self.path,"mccloud.rb")
    end

    def load!
      self.validate

      content=File.read(self.definition_path)
      mccloud_configurator=env.config
      content.gsub!("Mccloud::Config.run","mccloud_configurator.define")

      begin
        env.config.instance_eval(content)
      rescue Error => ex
        raise ::Mccloud::Error, "Error reading definition from file #{definition_file}#{ex}"
      end
    end

    def to_vm(name)
      vm=@raw.dup
      vm.name=name
      return vm
    end

    def validate
      raise ::Mccloud::Error, "Definition #{@name} does not yet exist" unless self.exists?
    end


    def copy_template(templatename)
      raise ::Mccloud::Error, "Definition #{@name} already exists" if self.exists?
      raise ::Mccloud::Error, "Template #{templatename} does not exist" unless @env.config.templates[templatename].exists?

      begin
        t=@env.config.templates[templatename]
        @env.logger.info "Copying template #{t.path} to definition #{self.path}"
        FileUtils.cp_r(t.path,self.path)
        save_mccloud_rb
        FileUtils.rm(File.join(self.path,"mccloud.erb"))
      rescue Exception => ex
        raise ::Mccloud::Error, "Error copying template #{templatename} to definition #{@name}:\n#{ex}"
      end

    end

    def save_mccloud_rb
      begin
        unless File.exists?(self.definition_path)
          File.open(self.definition_path,'w'){ |f| f.write(self.to_template(@name))}
        else
          raise ::Mccloud::Error, "Definition file #{self.definition_path} already exists"
        end
      rescue Error => ex
        raise ::Mccloud::Error, "Error writing mccloud.rb"
      end
    end

    def to_template(templatename)
      result=""
      t=@env.config.templates[templatename]
      filename=File.join(self.path,'mccloud.erb')
      env.logger.info "Opening vm template file #{@file}"
      template=File.new(filename).read
      result=ERB.new(template).result(binding)
      return result
    end
  end
end
