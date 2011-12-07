require 'mccloud/provisioner/chef_solo'
require 'mccloud/provisioner/puppet'
require 'mccloud/provisioner/shell'

require 'mccloud/provider/core/forwarding'

require 'mccloud/provider/core/vm/ssh.rb'
require 'mccloud/provider/core/vm/ssh_bootstrap.rb'
require 'mccloud/provider/core/vm/ssh_forward.rb'
require 'mccloud/provider/core/vm/rsync.rb'

module Mccloud
  module Provider
    module Core

      class ShellResult
        attr_accessor :stdout
        attr_accessor :stderr
        attr_accessor :status

        def initialize(stdout,stderr,status)
          @stdout=stdout
          @stderr=stderr
          @status=status
        end
      end

    class Vm

      include Mccloud::Provider::Core::VmCommand

      attr_reader   :env

      attr_accessor :provider
      attr_accessor :definition

      attr_accessor :create_options
      attr_accessor :name
      attr_accessor :user
      attr_accessor :port
      attr_accessor :private_key_path
      attr_accessor :public_key_path
      attr_accessor :agent_forwarding

      attr_accessor :auto_selection

      attr_accessor :bootstrap
      attr_accessor :provisioners

      attr_accessor :forwardings
      attr_accessor :stacked
      attr_accessor :declared

      def initialize(env)
        @env=env
        @forwardings=Array.new
        @stacked=false
        @auto_selection=true
        @declared=true
        @provisioners=Array.new
        @port=22
        @agent_forwarding=false
        @create_options={}
        @definition=nil
      end

      def declared?
        return declared
      end

      def stacked?
        return stacked
      end

      def auto_selected?
        return auto_selection
      end

      def provisioner
        if provisioners.nil?
          return nil
        else
          provisioners.first
        end
      end

      # This function is swapped with the component provision function
      # while reading the configuration
      def provision(type)
        if block_given?
          case type
          when :chef_solo
            @provisioners<< Mccloud::Provisioner::ChefSolo.new(env)
          when :puppet
            @provisioners<<Mccloud::Provisioner::Puppet.new(env)
          when :shell
            @provisioners<<Mccloud::Provisioner::Shell.new(env)

          else
          end
          yield @provisioners.last
        end
      end

      def forward_port(name,local,remote)
        forwarding=Forwarding.new(name,local,remote)
        forwardings << forwarding
      end

      def method_missing(m, *args, &block)
          env.logger.info "There's no keyword #{m} defined for vm #{@name}-- ignoring it"
      end

    end #Class
  end #Module
  end #Module
end #Module Provider
