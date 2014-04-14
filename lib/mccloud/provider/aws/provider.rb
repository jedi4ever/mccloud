require 'mccloud/provider/fog/provider'

require 'mccloud/provider/aws/provider/status'
require 'mccloud/provider/aws/provider/ip_list'
require 'mccloud/provider/aws/provider/lb_list'
require 'mccloud/provider/aws/provider/keystore_list'
require 'mccloud/provider/aws/provider/keystore_sync'
require 'mccloud/provider/aws/provider/image_list'
require 'mccloud/provider/aws/provider/image_destroy'
require 'mccloud/provider/aws/vm'
require 'mccloud/provider/aws/lb'
require 'mccloud/provider/aws/ip'

module Mccloud
  module Provider
    module Aws
      class Provider  < ::Mccloud::Provider::Fog::Provider

        attr_accessor :name
        attr_accessor :flavor

        attr_accessor :options
        attr_accessor :region

        attr_accessor :vms
        attr_accessor :lbs
        attr_accessor :ips
        attr_accessor :credential

        attr_accessor :keystores

        attr_accessor :check_keypairs
        attr_accessor :check_security_groups

        include Mccloud::Provider::Aws::ProviderCommand


        def initialize(name,options,env)

          super(name,options,env)

          # Default fog credential pair
          @credential=:default

          @check_security_groups=true
          @check_keypairs=true

          @options={}
          unless options.nil?
            @options.merge!(options)
          end
          @flavor=self.class.to_s.split("::")[-2]
          @name=name
          @region="us-east-1"

          # Initializing the components
          @vms=Hash.new
          @lbs=Hash.new
          @ips=Hash.new
          @keystores=Hash.new

        end

        def raw
          check_fog_credentials([:aws_access_key_id,:aws_secret_access_key])
          if @raw.nil?
            begin
              @raw=::Fog::Compute.new({:provider => "Aws", :region => @region}.merge(@options))
            rescue ArgumentError => e
              @raw=nil
              raise Mccloud::Error, "Error loading Aws provider : #{e.to_s} #{$!}"
            end
          end
          return @raw
        end

        def verify
          # We want to check the keyname "mccloud" exists
          #list_keypairs
          #list_flavors
          #list_zones
          #list_securitygroups
          #check port 22 is open
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
          env.logger.info "Creating security group #{name}"
          sg=raw.security_groups.new
          sg.name=name
          sg.description=comment
          sg.save
          sg.authorize_port_range(22..22)
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
          raise ::Mccloud::Error,"#{selection} did not match any defined vms" unless vm_defined?(selection)
          self.verify
          on_selected_components("vm",selection) do |id,vm|
            vm.up(options)
          end
        end

        def bootstrap(selection,script,options)
          raise ::Mccloud::Error,"#{selection} did not match any defined vms" unless vm_defined?(selection)
          self.verify
          on_selected_components("vm",selection) do |id,vm|
            vm._bootstrap(script,options)
          end
        end

        def shutdown(selection,options)
          raise ::Mccloud::Error,"#{selection} did not match any defined vms" unless vm_defined?(selection)
          self.verify
          on_selected_components("vm",selection) do |id,vm|
            vm.shutdown(options)
          end
        end

        def resume(selection,options)
          raise ::Mccloud::Error,"#{selection} did not match any defined vms" unless vm_defined?(selection)
          self.verify
          on_selected_components("vm",selection) do |id,vm|
            vm.resume(options)
          end
        end

        def reload(selection,options)
          raise ::Mccloud::Error,"#{selection} did not match any defined vms" unless vm_defined?(selection)
          self.verify
          on_selected_components("vm",selection) do |id,vm|
            vm.reload(options)
          end
        end

        def destroy(selection,options)
          raise ::Mccloud::Error,"#{selection} did not match any defined vms" unless vm_defined?(selection)
          self.verify
          on_selected_components("vm",selection) do |id,vm|
            vm.destroy(options)
          end

        end

        def ssh(selection,command,options)
          raise ::Mccloud::Error,"#{selection} did not match any defined vms" unless vm_defined?(selection)
          self.verify
          on_selected_components("vm",selection) do |id,vm|
            vm.ssh(command,options)
          end
        end

        def vm_defined?(selection)
          env.config.vms.keys.include?(selection)
        end

        def package(selection,options)
          raise ::Mccloud::Error,"#{selection} did not match any defined vms" unless vm_defined?(selection)
          self.verify
          on_selected_components("vm",selection) do |id,vm|
            vm.package(options)
          end
        end

        def provision(selection,options)
          raise ::Mccloud::Error,"#{selection} did not match any defined vms" unless vm_defined?(selection)
          self.verify
          on_selected_components("vm",selection) do |id,vm|
            vm._provision(options)
          end
        end

        def halt(selection,options)
          raise ::Mccloud::Error,"#{selection} did not match any defined vms" unless vm_defined?(selection)
          self.verify
          on_selected_components("vm",selection) do |id,vm|
            env.ui.info "Matched #{vm.name}"
            vm.halt(options)
          end

        end

        def hosts
          hostentries = Hash.new
          filter = self.filter

          self.raw.servers.each do |s|
            name_tag = s.tags["Name"]
            if name_tag.start_with?(filter)
              servername = name_tag.sub(/^#{filter}/,'')
              h = Hash.new
              h['public_ip_address']=s.public_ip_address
              h['private_ip_address']=s.private_ip_address
              hostentries[servername] = h
            end
          end

          return hostentries
        end

      end
    end
  end
end
