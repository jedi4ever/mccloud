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

      attr_reader   :server

      def initialize(env)
        @env=env
        @manifest_file = "manifest.pp"
        @manifests_path = "manifests"
        @module_paths = []
        @pp_path = "/tmp/mccloud-puppet"
        @name="puppet"
        @options = []
      end

      # Returns the manifests path expanded relative to the root path of the
      # environment.
      def expanded_manifests_path
        Pathname.new(manifests_path).expand_path(env.root_path)
      end


      # Returns the module paths as an array of paths expanded relative to the
      # root path.
      def expanded_module_paths
        return [] if !module_path

        # Get all the paths and expand them relative to the root path, returning
        # the array of expanded paths
        paths = module_path
        paths = [paths] if !paths.is_a?(Array)
        paths.map do |path|
          Pathname.new(path).expand_path(env.root_path)
        end
      end

      # Returns the manifests paths as an array of paths expanded relative to the
      # root path.
      def expanded_manifests_paths
        return [] if !manifests_path

        # Get all the paths and expand them relative to the root path, returning
        # the array of expanded paths
        paths = manifests_path
        paths = [paths] if !paths.is_a?(Array)
        paths.map do |path|
          Pathname.new(path).expand_path(env.root_path)
        end
      end

      def share_modules
        i=0
        expanded_module_paths.each do |path|
          remote_path=File.join(pp_path,"modules-#{i}")
          env.ui.info "Sharing module dir #{path}"
          server.execute("test ! -d '#{remote_path}' && mkdir -p '#{remote_path}'")
          server.share_folder("modules-#{i}",path,remote_path,{:mute => false})
          i=i+1
        end
      end

      def share_manifests
        i=0
        expanded_manifests_paths.each do |path|
          remote_path=File.join(pp_path,"manifests-#{i}")
          env.ui.info "Sharing manifest dir #{path}"
          server.execute("test ! -d '#{remote_path}' && mkdir -p '#{remote_path}'")
          server.share_folder("manifests-#{i}",path,remote_path,{:mute => false})
          i=i+1
        end
      end

      def set_module_paths
        @module_paths = {}
        expanded_module_paths.each_with_index do |path, i|
          @module_paths[path] = File.join(@pp_path, "modules-#{i}")
        end
      end

      def share_manifest
        env.ui.info "Synching manifest #{@manifest_file}"
        server.transfer(File.join(manifests_path,@manifest_file),"#{File.basename(@manifest_file)}")
      end

      def prepare
        share_manifests
        share_modules
        share_manifest
      end

      def cleanup
      end

      def run(server)
        @server=server

        options=[]
        options << "--modulepath '#{@module_paths}'"
        env.logger.info "Starting puppet run"
        server.execute("mkdir -p #{@pp_path}")
        prepare

        env.ui.info "Running puppet"

        server.sudo("puppet apply #{@pp_path}/manifest.pp")

      end
    end #Class
  end #Module Provisioners
end #Module Mccloud
