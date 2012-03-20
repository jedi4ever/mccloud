require 'mccloud/util/rsync'
require 'mccloud/util/ssh'
require 'erb'
require 'tempfile'

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
      attr_accessor :remote_environment

      attr_reader   :server

      def initialize(env)
        @env=env
        @manifest_file = nil
        @manifests_path = "manifests"
        @module_paths = []
        @pp_path = "/tmp/mccloud-puppet"
        @name="puppet"
        @options = []
        @remote_environment={}
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
          server.execute("test -d '#{remote_path}' || mkdir -p '#{remote_path}'")
          server.share_folder("modules-#{i}",path,remote_path,{:mute => false})
          i=i+1
        end
      end

      def share_manifests
        i=0
        expanded_manifests_paths.each do |path|
          remote_path=File.join(pp_path,"manifests-#{i}")
          env.ui.info "Sharing manifest dir #{path}"
          server.execute("test -d '#{remote_path}' || mkdir -p '#{remote_path}'")
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
        if @manifest_file.nil?
          # Nothing to do here
          return
        end

        full_path=Pathname.new(File.join(manifests_path,@manifest_file)).expand_path(env.root_path).to_s

        # These are the default
        dest=File.join(@pp_path,File.basename(@manifest_file))
        src=full_path

        # ERB file
        if is_erb?(full_path)
          env.ui.info "Interpreting ERB puppet manifest"

          # Correct the src path
          temp_file = Tempfile.new("puppet_erb")
          src=temp_file.path
          result=erbify(full_path)
          File.open(temp_file,'w') { |f| f.write(result)}

          # Correct the dest path
          dest=File.join(@pp_path,File.basename(@manifest_file,".erb"))

          # Immediately unlink it
          #temp_file.close(true)
        end

        env.ui.info "Synching manifest #{src} -> #{dest}"
        server.transfer(src,dest)
      end

      def is_erb?(filename)
        result=File.extname(filename) == ".erb"
        puts result
        return result
      end

      def erbify(filename)

        # Fill the array to pass to the ERB
        public_ips=Hash.new
        private_ips=Hash.new
        server.provider.vms.each do |name,vm|
          public_ips[name] = vm.public_ip_address
          private_ips[name] = vm.private_ip_address
        end

        data = { :public_ips => public_ips, :private_ips => private_ips}
        vars = ErbBinding.new(data)

        template = File.read(filename)
        erb = ERB.new(template)

        vars_binding = vars.send(:get_binding)
        result=erb.result(vars_binding)
        return result

      end

      def prepare
        share_manifests
        share_modules
        share_manifest
        set_module_paths
      end

      def cleanup
      end

      def run(server)
        @server=server
        if @manifest_file.nil?
          env.ui.info "No specific manifestfile specified defaulting to site.pp in the manifest dir"
        end

        env.logger.info "Starting puppet run"
        server.execute("mkdir -p #{@pp_path}")
        prepare

        env.ui.info "Running puppet"

        pre_options=[]
        unless @remote_environment.empty?
          @remote_environment.each do |key,value|
            pre_options << "#{key.to_s}=\"#{value}\""
          end
        end

        puppet_options=[ "apply"]
        @options.each do |o|
          puppet_options << o
        end


        unless @module_paths.empty?
          puppet_options << "--modulepath=#{@module_paths.values.join(':')}"
        end

        manifestdir="#{File.join(@pp_path,'manifests-0')}"
        puppet_options << "--manifestdir=#{manifestdir}"

        if @manifest_file.nil?
          puppet_options << File.join(manifestdir,"site.pp")
        else
          if is_erb?(@manifest_file)
            puppet_options << File.join(@pp_path,File.basename(@manifest_file,".erb"))
          else
            puppet_options << File.join(@pp_path,File.basename(@manifest_file))
          end
        end

        server.sudo("#{pre_options.join(" ")} puppet #{puppet_options.join(' ')}")
      end
    end #Class
  end #Module Provisioners
end #Module Mccloud
