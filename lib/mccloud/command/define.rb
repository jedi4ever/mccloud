require 'fileutils'
module Mccloud
  module Command
    class DefineCommand < Base

      register "define NAME TEMPLATE-NAME", "Defines a new machine based on a tempate"
      argument :name, :type => :string, :optional => false, :default => nil
      argument :template, :type => :string, :optional => false, :default => nil

      def execute
        env.ui.info "Define #{name} with template #{template}"

        # Checking for name already defined
        env.ui.warn "#{name} was already defined" unless env.config.vms[name].nil?
        t=env.config.templates[template]

        # Template was not found
        unless t.nil?
          unless File.exists?("vms") && File.directory?("vms")
            env.logger.info ("Creating the vms directory as it doesn't exist yet")
            FileUtils.mkdir("vms")
          end
          filename=File.join("vms","#{name}.rb")
          unless File.exists?(filename)
            File.open(filename,'w'){ |f| f.write(t.to_template(name))}
          else
            env.ui.error "Machine #{name} already exists. Undefine it first:"
            env.ui.error "mccloud undefine '#{name}'"

          end
        else
          env.ui.error "Template #{template} does not exist"
        end
      end

    end

  end
end
