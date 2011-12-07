require 'fileutils'
module Mccloud
  module Command
    class DefineCommand < Base

      register "define NAME TEMPLATE-NAME", "Creates a new definition based on a tempate"
      argument :name, :type => :string, :optional => false, :default => nil
      argument :template, :type => :string, :optional => false, :default => nil

      def execute
        env.ui.info "Define #{name} with template #{template}"
        env.config.definitions.define(name,template)
      end

    end

  end
end
