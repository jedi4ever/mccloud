require 'mccloud/provider/core/vm'

require 'mccloud/provider/aws/vm/up'
require 'mccloud/provider/aws/vm/bootstrap'
require 'mccloud/provider/aws/vm/ssh'
require 'mccloud/provider/aws/vm/scp'
require 'mccloud/provider/aws/vm/rsync'
require 'mccloud/provider/aws/vm/halt'
require 'mccloud/provider/aws/vm/provision'
require 'mccloud/provider/aws/vm/destroy'
require 'mccloud/provider/aws/vm/reload'
require 'mccloud/provider/aws/vm/resume'
require 'mccloud/provider/aws/vm/suspend'
require 'mccloud/provider/aws/vm/forward'
require 'mccloud/provider/aws/vm/package'

module Mccloud::Provider
  module Aws

    class Vm < ::Mccloud::Provider::Core::Vm

      #Inherits user, name,port
      #         private_key_path, public_key_path
      #         bootstrap, auto_selection
      #         forwardings
      #         provider
      attr_accessor :ami
      attr_accessor :tags
      attr_accessor :key_name
      attr_accessor :zone
      attr_accessor :security_groups
      attr_accessor :user_data
      attr_accessor :flavor

      include Mccloud::Provider::Aws::VmCommand

      def initialize(env)
        # Todo calculate the best default based
        # On provider region
        super(env)
        @key_name = [ "mccloud"]
        # Todo calculate the best default based
        # On provider region
        @zone="eu-west-1a"
        @security_groups=[ "mccloud"]
        @flavor="t1.micro"
        # Todo calculate the ubuntu one based
        # on provider region and flavor
        @ami="ami-e59ca991"

        # Empty tags, but on up the name get's added
        @tags = {}

        @user = "root"
        @user_data = nil

      end

      def running?
        if raw.nil?
          return false
        else
          return raw.ready?
        end
      end

      def id
        unless raw.nil?
          return raw.id
        else
          return nil
        end
      end
      def ip_address
        # For VPC
        ip = self.public_ip_address
        return ip unless ip.nil?
        ip = self.private_ip_address
        return ip unless ip.nil?
        return nil
      end

      def public_ip_address
        unless raw.nil?
          ip=raw.public_ip_address
        else
          ip=nil
        end
        return ip
      end

      def private_ip_address
        unless raw.nil?
          ip=raw.private_ip_address
        else
          ip=nil
        end
        return ip
      end


      def raw
        if @raw.nil?
          rawname="#{@provider.filter}#{@name}"
          @provider.raw.servers.each do |vm|
            name=nil
            name=vm.tags["Name"].strip unless vm.tags["Name"].nil?
            if name==rawname
              @raw=vm

              # Add it to make scp work the first time
              @raw.private_key_path=@private_key_path
              @raw.username = @user
            end
          end
        else
            # Refresh this every time it is referenced
          @raw.private_key_path=@private_key_path
          @raw.username = @user
        end

        return @raw
      end

    end
  end
end
