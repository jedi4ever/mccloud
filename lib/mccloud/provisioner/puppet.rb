require 'mccloud/util/rsync'
require 'mccloud/util/ssh'
module Mccloud
  module Provisioner
    class Puppet

      attr_accessor :name
      attr_accessor :env

      attr_accessor :manifest_file
      attr_accessor :manifests_path
      attr_accessor :module_path
      attr_accessor :pp_path

      attr_accessor :options

      def initialize(env)
        @env=env
        @manifest_file = nil
        @manifests_path = "manifests"
        @module_path = nil
        @pp_path = "/tmp/vagrant-puppet"
        @name="puppet"
        @options = []
      end

      def run(server)
        @module_paths.each do |from, to|
          server.share(path)
        end

        @manifests_paths.each do |from, to|
          server.share(path)
        end
        server.execute("mkdir -p #{@pp_path}")
        env.ui.info "Synching manifest #{@manifest_file}"
        server.transfer(@manifest_file,"#{@pp_path}/manifest.pp")

        env.ui.info "Running puppet"
        if server.user=="root"
          server.execute("puppet #{@pp_path}/manifest.pp")
        else
          server.execute("sudo -i puppet #{@pp_path}/manifest.pp")
        end
      end
    end #Class
  end #Module Provisioners
end #Module Mccloud
