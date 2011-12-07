require 'lib/mccloud/template.rb'
module Mccloud
   class Templates < Hash
    attr_reader :env

    def initialize(env)
      @env=env
    end

    def load!
      if self.exists?
        Dir[File.join(self.path,"**")].each do |dir|
          template_name=File.basename(dir)
          t=Template.new(template_name,env)
          self[template_name]=t
        end
      else
        env.logger.info "Skipping loading of definitions as the definition_path does exist"
      end
    end

    def path
      @env.config.mccloud.template_path
    end

    def exists?
      File.directory?(self.path)
    end

    def registered?(name)
      return self.has_key?(name)
    end
   end
end
