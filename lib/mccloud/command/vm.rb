module Mccloud
  module Command
    class VmCommand < Mccloud::Command::GroupBase
      register "vm", "Subcommand to manage vms"

      desc "define [VM-NAME] [DEFINITION-NAME]", "define a new vm based on a definition"
      def define(vm_name,definition_name)
        env.config.vms.define(vm_name,definition_name)
      end

      desc "list", "list all known vms"
      def list
        printf("%-30s|%-20s|%-10s\n","alias","provider","ip-address")
        env.config.vms.sort.each do |name,vm|
          printf("%-30s|%-20s|%-10s\n",name,vm.provider.name,vm.ip_address)
        end
      end

    end #Class

  end #Module
end # Module
