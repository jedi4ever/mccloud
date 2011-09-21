module Mccloud::Provider
  module Vmfusion
    module ProviderCommand
  
    def status(selection=nil,options=nil)
      
      puts ""
      80.times { |i| printf "*"}; puts
      all_vms = ::Fission::VM.all
      all_running_vms = ::Fission::VM.all_running

      longest_vm_name = all_vms.max { |a,b| a.length <=> b.length }

      ::Fission::VM.all.each do |vm|
        status = all_running_vms.include?(vm) ? '[running]' : '[not running]'
        Fission.ui.output_printf "%-#{longest_vm_name.length}s   %s\n", vm, status
      end

    end
    
    end #module  
  end #module
end #module

