require 'mccloud/util/rsync'
require 'mccloud/util/ssh'
module Mccloud
  module Provisioner
    class Puppet
      
            attr_accessor :manifest_file
            attr_accessor :manifests_path
            attr_accessor :module_path
            attr_accessor :pp_path
            attr_accessor :options

            def initialize
              @manifest_file = nil
              @manifests_path = "manifests"
              @module_path = nil
              @pp_path = "/tmp/vagrant-puppet"
              @options = []
            end
      
      def run(vm)
#        @module_paths.each do |from, to|
#            Mccloud::Util.rsync(path,vm,vm.instance)
#        end

#        @manifests_paths.each do |from, to|
#            Mccloud::Util.rsync(path,vm,vm.instance)
#        end
        vm.instance.ssh("mkdir -p #{@pp_path}")
        vm.instance.scp(@manifest_file,"#{@pp_path}/manifest.pp")      
        
        puts "Running puppet"
        options={ :port => 22, :keys => [ vm.private_key ], :paranoid => false, :keys_only => true}
        Mccloud::Util.ssh(vm.instance.public_ip_address,vm.user,options,"sudo puppet #{@pp_path}/manifest.pp")
        
      end
    end #Class
  end #Module Provisioners
end #Module Mccloud
