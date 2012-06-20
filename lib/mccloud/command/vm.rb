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
        vms = env.config.vms.sort
        printf("%-30s|%-20s|%-15s|%-15s\n","alias","provider","ip-address","private-address")
        80.times do 
          print '-'
        end
        puts
        vms.each do |name,vm|
          printf("%-30s|%-20s|%-15s|%-15s\n",name,vm.provider.name,vm.ip_address,vm.private_ip_address)
        end
      end

    end #Class

  end #Module
end # Module
