module Mccloud
  module Provisioner
    class ChefSolo
      attr_accessor :cookbooks_path 
      attr_accessor :role_path 
      attr_accessor :provisioning_path
      attr_accessor :json
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

      def initialize
        @provisioning_path="/tmp/mccloud-chef"
        @json={ :instance_role => "mccloud"}
      end
      # Returns the run list for the provisioning
      def run_list
        json[:run_list] ||= []
      end
      # Sets the run list to the specified value
      def run_list=(value)
        json[:run_list] = value
      end
      def add_role(name)
        name = "role[#{name}]" unless name =~ /^role\[(.+?)\]$/
        run_list << name
      end
      def add_recipe(name)
        name = "recipe[#{name}]" unless name =~ /^recipe\[(.+?)\]$/
        run_list << name
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
          :no_proxy => config.no_proxy
          }.merge(template_vars))

          # file_cache_path "/var/chef-solo"
          # cookbook_path "/var/chef-solo/cookbooks"

          #vm.ssh.upload!(StringIO.new(config_file), File.join(config.provisioning_path, filename))
        end

        def setup_json

          json = Mccloud::Config.config.chef.json.to_json
          #vm.ssh.upload!(StringIO.new(json), File.join(config.provisioning_path, "dna.json"))
	  return json
        end

        def prepare
          share_cookbook_folders
          share_role_folders
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

        def share_role_folders
          host_role_paths.each_with_index do |role, i|
            env.config.vm.share_folder("v-csr-#{i}", role_path(i), role)
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
            })
          end
          def run_chef_solo
            commands = ["cd #{config.provisioning_path}", "chef-solo -c solo.rb -j dna.json"]

            env.ui.info I18n.t("vagrant.provisioners.chef.running_solo")
            vm.ssh.execute do |ssh|
              ssh.sudo!(commands) do |channel, type, data|
                if type == :exit_status
                  ssh.check_exit_status(data, commands)
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
