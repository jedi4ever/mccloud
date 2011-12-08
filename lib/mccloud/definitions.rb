require 'mccloud/definition.rb'

module Mccloud
  class Definitions < Hash

    attr_reader :env

    def initialize(env)
      @env=env
    end

    def define(name,templatename)
      # Check if template exists
      unless env.config.templates.registered?(templatename)
        raise ::Mccloud::Error, "Template #{templatename} does not exist"
      end
      # Create the definitions dir if needed
      unless self.exists?
        self.create
      end

      definition=::Mccloud::Definition.new(name,env)
      unless definition.exists?
        definition.copy_template(templatename)
      end
    end

    def load!
      if self.exists?
        Dir[File.join(self.path,"**")].each do |dir|
          definition_name=File.basename(dir)
          d=Definition.new(definition_name,env)
          d.load!
        end
      else
        env.logger.info "Skipping loading of definitions as the definition_path does exist"
      end
    end

    def path
      @env.config.mccloud.definition_path
    end

    def exists?
      File.directory?(self.path)
    end

    def registered?(name)
      return self.has_key?(name)
    end

    def create
     begin
      unless self.exists?
        env.logger.info "Creating the definitions directory #{self.path} as it doesn't exist yet"
        FileUtils.mkdir(self.path)
      end
      rescue Exception => ex
         raise ::Mccloud::Error, "Error creating definitions directory #{self.path}: \n#{ex}"
      end
    end

  end
end

## Checking for name already defined
#          env.ui.warn "#{name} was already defined" unless env.config.vms[name].nil?
#          t=env.config.templates[template]
#  
#          # Template was not found
#          unless t.nil?
#            unless File.exists?("vms") && File.directory?("vms")
#>>            env.logger.info ("Creating the vms directory as it doesn't exist yet")
#              FileUtils.mkdir("vms")
#            end 
#            filename=File.join("vms","#{name}.rb")
#            unless File.exists?(filename)
#              File.open(filename,'w'){ |f| f.write(t.to_template(name))}
#            else
#              env.ui.error "Definition #{name} already exists. Undefine it first:"
#              env.ui.error "mccloud undefine '#{name}'"
#  
#            end 
#          else
#            env.ui.error "Template #{template} does not exist"
#          end 
#
