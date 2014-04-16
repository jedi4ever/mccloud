require 'erb'
require 'ostruct'
require 'tempfile'


module Mccloud
  module Provisioner
    class ErbBinding < OpenStruct
      def get_binding
        return binding()
      end
    end

    class ChefSolo

      attr_reader   :name
      attr_reader   :env

      attr_accessor :cookbooks_path
      attr_accessor :roles_path
      attr_accessor :provisioning_path
      attr_accessor :data_bags_path
      attr_accessor :encrypted_data_bag_secret_key_path
      attr_accessor :json
      attr_accessor :json_erb
      attr_accessor :clean_after_run
      attr_reader   :roles

      attr_accessor :node_name
      attr_accessor :log_level
      attr_accessor :http_proxy
      attr_accessor :http_proxy_user
      attr_accessor :http_proxy_pass
      attr_accessor :https_proxy
      attr_accessor :https_proxy_user
      attr_accessor :https_proxy_pass
      attr_accessor :no_proxy

      def initialize(env)
        @env=env
        @provisioning_path="/tmp/mccloud-chef"
        @json={ :instance_role => "mccloud"}
        @json_erb=true
        @name ="chef_solo"
        @log_level="info"
        @cookbooks_path =  []
        @run_list = []
        @clean_after_run = true
      end

      def mccloudconfig_to_json
      end

      def run(server)
        if @json_erb
          # http://stackoverflow.com/questions/1338960/ruby-templates-how-to-pass-variables-into-inlined-erb

          public_ips=Hash.new
          private_ips=Hash.new

          providers = Hash.new
          # Add all providers
          server.provider.vms.each do |name,vm|
            providers[vm.provider.name] = vm.provider if providers[vm.provider.name].nil?
          end

          providers.each do |providername,provider|
            hosts = providers[providername].hosts
            hosts.each do |name,host|
              public_ips[name]=host['public_ip_address']
              private_ips[name]=host['private_ip_address']
            end
          end

=begin

          # For each provider , get the ip-addresses
          providers.each do |providername, provider|
            #namespace = provider.namespace
            filter = provider.filter

            provider.raw.servers.each do |s|
              name = s.tags["Name"].sub(/^#{filter}/,'')
              public_ips[name]=s.public_ip_address
              private_ips[name]=s.private_ip_address
            end
          end
=end

          # http://www.techques.com/question/1-3242470/Problem-using-OpenStruct-with-ERB
          # We only want specific variables for ERB
          data = { :public_ips => public_ips, :private_ips => private_ips}

          vars = ErbBinding.new(data)

          # Added vmname in mccloud
          @json.merge!({ :mccloud => {
            :name => server.name,
            :private_ips => private_ips,
            :public_ips => public_ips
          } })

          template = @json.to_json.to_s
          erb = ERB.new(template)

          vars_binding = vars.send(:get_binding)
          result=erb.result(vars_binding)

          #Result = String
          #JSON.parse result = Hash
          #.to_json = String containing JSON formatting of Hash

          @json.merge!(JSON.parse(result))

        else
        end

        @json.merge!({:run_list => @run_list })
        json=@json.to_json

        cooks=Array.new
        @cookbooks_path.each do |cook|
          cooks << File.join("/tmp/"+File.basename(cook))
        end

        # Prepare solo.rb
        configfile=['file_cache_path "/var/chef-solo"']
        configfile << "cookbook_path [\""+cooks.join("\",\"")+"\"]"
        configfile << "log_level #{log_level}"
        configfile << "role_path \"/tmp/#{File.basename(roles_path)}\"" unless roles_path.nil?
        configfile << "data_bag_path \"/tmp/#{File.basename(data_bags_path)}\"" unless data_bags_path.nil?
        configfile << "encrypted_data_bag_secret \"/tmp/#{File.basename(encrypted_data_bag_secret_key_path)}\"" unless encrypted_data_bag_secret_key_path.nil?

        #convert string to Tempfile (instead of StringIO), as server.transfer expects a file with a filename
        temp_file_json = Tempfile.new("dna_json")
        temp_file_json.write(json)
        temp_file_json.close

        temp_file_solo = Tempfile.new("solo_rb")
        temp_file_solo.write(configfile.join("\n"))
        temp_file_solo.close

        server.transfer(temp_file_json.path,"/tmp/dna.json")
        server.transfer(temp_file_solo.path,"/tmp/solo.rb")

        # Share the cookbooks
        i=0
        cookbooks_path.each do |path|
          server.share_folder("cookbook_path-#{i}","/tmp/" + File.basename(path),path,{:mute => true})
          i=i+1
        end

        unless roles_path.nil?
          server.share_folder("roles_path","/tmp/" + File.basename(roles_path),roles_path,{:mute => true})
        end

        unless data_bags_path.nil?
          server.share_folder("databags_path","/tmp/" + File.basename(data_bags_path),data_bags_path,{:mute => true})
        end

        unless encrypted_data_bag_secret_key_path.nil?
          server.share_file("encrypted_databag_secret","/tmp/" + File.basename(encrypted_data_bag_secret_key_path),encrypted_data_bag_secret_key_path,{:mute => true})
        end

        server.share

        env.ui.info "[#{server.name}] - [#{@name}] - running chef-solo"
        env.ui.info "[#{server.name}] - [#{@name}] - login as #{server.user}"

        exec_results = ''

        begin
          if server.user=="root"
            exec_results = server.execute("chef-solo --force-formatter -c /tmp/solo.rb -j /tmp/dna.json -l #{@log_level}")
          else
            exec_results = server.execute("sudo -i chef-solo --force-formatter -c /tmp/solo.rb -j /tmp/dna.json -l #{@log_level}")

            #server.execute("sudo chef-solo -c /tmp/solo.rb -j /tmp/dna.json -l #{@log_level}")
          end
        rescue Exception
        ensure
          if @clean_after_run == true
            env.ui.info "[#{server.name}] - [#{@name}] - Cleaning up dna.json"
            server.execute("rm /tmp/dna.json",{:mute => true})
            env.ui.info "[#{server.name}] - [#{@name}] - Cleaning up solo.json"
            server.execute("rm /tmp/solo.rb", {:mute => true})
            cookbooks_path.each do |path|
              env.ui.info "[#{server.name}] - [#{@name}] - Cleaning cookbook_path #{path}"
              server.execute("rm -rf /tmp/#{File.basename(path)}",{:mute => true})
            end

            unless roles_path.nil?
                env.ui.info "[#{server.name}] - [#{@name}] - Cleaning roles_path #{roles_path}"
                server.execute("rm -rf /tmp/#{File.basename(roles_path)}",{:mute => true})
            end

            unless data_bags_path.nil?
                env.ui.info "[#{server.name}] - [#{@name}] - Cleaning data_bags_path #{data_bags_path}"
                server.execute("rm -rf /tmp/#{File.basename(data_bags_path)}",{:mute => true})
            end

            unless encrypted_data_bag_secret_key_path.nil?
                env.ui.info "[#{server.name}] - [#{@name}] - Cleaning encrypted_databag_secret #{encrypted_data_bag_secret_key_path}"
                server.execute("rm -rf /tmp/#{File.basename(encrypted_data_bag_secret_key_path)}",{:mute => true})
            end
          end

          if (exec_results.status != 0)
            raise ::Mccloud::Error,"Chef solo exit with a non-zero exitcode #{exec_results.status}"
          end
        end

        #Cleaning up

      end
      # Returns the run list for the provisioning
      def run_list
        json[:run_list] ||= []
      end
      def add_role(name)
        name = "role[#{name}]" unless name =~ /^role\[(.+?)\]$/
        @run_list << name
      end
      def add_recipe(name)
        name = "recipe[#{name}]" unless name =~ /^recipe\[(.+?)\]$/
        @run_list << name
      end

      def setup_config(template, filename, template_vars)
        config_file = TemplateRenderer.render(template, {
          :log_level => config.log_level.to_sym,
          :http_proxy => config.http_proxy,
          :http_proxy_user => config.http_proxy_user,
          :http_proxy_pass => config.http_proxy_pass,
          :https_proxy => config.https_proxy,
          :https_proxy_user => config.https_proxy_user,
          :https_proxy_pass => config.https_proxy_pass,
          :data_bag_path => config.data_bag_path,
          :roles_path => config.roles_path,
          :no_proxy => config.no_proxy
        }.merge(template_vars))

        # file_cache_path "/var/chef-solo"

        #server.execute.upload!(StringIO.new(config_file), File.join(config.provisioning_path, filename))
      end

      def setup_json

        json = Mccloud::Config.config.chef.json.to_json
        #server.execute.upload!(StringIO.new(json), File.join(config.provisioning_path, "dna.json"))
        return json
      end

      def prepare
        share_cookbook_folders
        share_role_folder
      end

      def provision!
        verify_binary("chef-solo")
        chown_provisioning_folder
        setup_json
        setup_solo_config
        run_chef_solo
      end

      def share_cookbook_folders
        host_cookbook_paths.each_with_index do |cookbook, i|
          env.config.vm.share_folder("v-csc-#{i}", cookbook_path(i), cookbook)
        end
      end

      def share_role_folder
        host_roles_path.each_with_index do |role, i|
          env.config.vm.share_folder("v-csr-#{i}", roles_path(i), role)
        end
      end

      def setup_solo_config
        setup_config("chef_solo_solo", "solo.rb", {
          :node_name => config.node_name,
          :provisioning_path => config.provisioning_path,
          :cookbooks_path => cookbooks_path,
          :log_level        => :debug,
          :recipe_url => config.recipe_url,
          :roles_path => roles_path,
          :data_bags_path => data_bags_path,
          :encrypted_data_bag_secret_key_path => encrypted_data_bag_secret_key_path
        })
      end
      def run_chef_solo
        commands = ["cd #{config.provisioning_path}", "chef-solo -c solo.rb -j dna.json"]

        server.execute.execute do |execute|
          execute.sudo!(commands) do |channel, type, data|
            if type == :exit_status
              execute.check_exit_status(data, commands)
            else
              env.ui.info("#{data}: #{type}")
            end
          end
        end
      end
    end
  end #Module Provisioners
end #Module Mccloud


#cookbook_path     "/etc/chef/recipes/cookbooks"
#log_level         :info
#file_store_path  "/etc/chef/recipes/"
#file_cache_path  "/etc/chef/recipes/"
