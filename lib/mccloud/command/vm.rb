module Mccloud
  module Command
    class VmCommand < Mccloud::Command::GroupBase
      register "vm", "Subcommand to manage vms"

      desc "define [VM-NAME] [DEFINITION-NAME]", "define a new vm based on a definition"
      def define(vm_name,definition_name)
        env.config.vms.define(vm_name,definition_name)
      end

    end #Class

  end #Module
end # Module
