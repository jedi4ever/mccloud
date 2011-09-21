require 'mccloud/provider/core/provider'

require 'mccloud/provider/aws/provider/status'
require 'mccloud/provider/aws/provider/ip_list'
require 'mccloud/provider/aws/provider/lb_list'
require 'mccloud/provider/aws/provider/image_list'
require 'mccloud/provider/aws/provider/image_destroy'
require 'mccloud/provider/aws/vm'
require 'mccloud/provider/aws/lb'
require 'mccloud/provider/aws/ip'

module Mccloud
  module Provider
    module Aws
      class Provider  < ::Mccloud::Provider::Core::Provider

        attr_accessor :name
        attr_accessor :type

        attr_accessor :options
        attr_accessor :region

        attr_accessor :vms
        attr_accessor :lbs
        attr_accessor :ips

        attr_accessor :check_keypairs
        attr_accessor :check_securitygroups

        include Mccloud::Provider::Aws::ProviderCommand


        def initialize(name,options,env)

          super(name,options,env)

          @check_securitygroups=true
          @check_keypairs=true

          @options=options
          @type=self.class.to_s.split("::")[-2]
          @name=name
          @region="us-east-1"

          # Initializing the components
          @vms=Hash.new
          @lbs=Hash.new
          @ips=Hash.new

          required_gems=%w{fog}
          check_gem_availability(required_gems)
          require 'fog'

          self.verify

        end


        def raw
          if @raw.nil?
            begin
              @raw=Fog::Compute.new({:provider => "Aws", :region => @region}.merge(@options))
            rescue ArgumentError => e
              puts "Error loading raw provider : #{e.to_s} #{$!}"
              @raw=nil
            end
          end
          return @raw
        end

        def verify
          # We want to check the keyname "mccloud" exists
          #list_keypairs
          #list_flavors
          #list_zones
        end

        def list_keypairs
          raw.key_pairs.each do |keypair|
            env.logger.info "#{keypair.name} - #{keypair.fingerprint}"
          end

          raw.security_groups.each do |sg|
            env.logger.info "#{sg.name} - #{sg.description}"
          end
        end

        # We should check to see if 22 is enabled for that zone
        #(AWS.security_groups.get("JMETER").ip_permissions[0]["fromPort"]..AWS.security_groups.get("JMETER").ip_permissions[0]["toPort"]) === 22
        # make sure port 22 is open in the first security group
        #    security_group = connection.security_groups.get(server.groups.first)
        #    authorized = security_group.ip_permissions.detect do |ip_permission|
        #      ip_permission['ipRanges'].first && ip_permission['ipRanges'].first['cidrIp'] == '0.0.0.0/0' &&
        #      ip_permission['fromPort'] == 22 &&
        #      ip_permission['ipProtocol'] == 'tcp' &&
        #      ip_permission['toPort'] == 22
        #    end
        #    unless authorized
        #      security_group.authorize_port_range(22..22)
        #    end
        def create_sg(name,comment="Securitygroup created by Mccloud")
          sg=raw.security_groups.new
          sg.name=name
          sg.description=comment
          sg.save
          sg.authorize_port_range(22..22)
        end

        def destroy_keypair(name)
          old_pair=raw.key_pairs.get(name)
          unless old_pair.nil?
            old_pair.destroy()
          end
        end

        def create_key_pair(name,key)
          provider_keypair=raw.key_pairs.create(
            :name => name,
            :public_key => rsa_key.ssh_public_key )
        end

        def create_fog
          snippet=":default:\n"
          for fog_option in required_options do
            #  snippet=snippet+"  :#{fog_option}: #{answer[fog_option.to_sym]}\n"
          end

          fogfilename="#{File.join(ENV['HOME'],".fog")}"
          fogfile=File.new(fogfilename,"w")
          FileUtils.chmod(0600,fogfilename)
          fogfile.puts "#{snippet}"
          fogfile.close
        end

        def list_flavors
          raw.flavors.each do |flavor|
            env.logger.info "#{flavor.name} - #{flavor.id} - #{flavor.cores} cores#{flavor.bits}"
          end
        end

        def list_zones
          raw.describe_availability_zones.body["availabilityZoneInfo"].each do |region|
            env.logger.info "Zone: #{region['zoneName']} - #{region['regionName']}"
          end
        end

        def filter
          if @namespace.nil? || @namespace==""
            return ""
          else
            return "#{@namespace}-"
          end
        end

        def up(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            vm.up(options)
          end
        end

        def bootstrap(selection,script,options)
          on_selected_components("vm",selection) do |id,vm|
            vm._bootstrap(script,options)
          end
        end

        def shutdown(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            vm.shutdown(options)
          end
        end

        def resume(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            vm.resume(options)
          end
        end

        def reload(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            vm.reload(options)
          end
        end

        def destroy(selection,options)

          on_selected_components("vm",selection) do |id,vm|
            vm.destroy(options)
          end

        end

        def ssh(selection,command,options)

          on_selected_components("vm",selection) do |id,vm|
            vm.ssh(command,options)
          end

        end

        def rsync(selection,path,options)

          on_selected_components("vm",selection) do |id,vm|
            vm.rsync(path,options)
          end

        end

        def package(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            vm.package(options)
          end
        end

        def provision(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            vm._provision(options)
          end
        end

        def halt(selection,options)
          on_selected_components("vm",selection) do |id,vm|
            puts "Matched #{vm.name}"
            vm.halt(options)
          end

        end

      end
    end
  end
end
