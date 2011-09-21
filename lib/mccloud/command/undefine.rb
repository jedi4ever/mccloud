require 'fileutils'
module Mccloud
  module Command
    class UnDefineCommand < Base

      register "undefine NAME", "Undefines a machine"
      argument :name, :type => :string, :optional => false, :default => nil

      def execute
        env.ui.info "Undefine machine #{name}"
        filename=File.join("vms","#{name}.rb")
        if File.exists?(filename)
          env.ui.info "Removing #{filename}"
          FileUtils.rm(filename)
        else
          env.ui.info "Machine #{name} has not yet defined"
        end
      end

    end

  end
end
