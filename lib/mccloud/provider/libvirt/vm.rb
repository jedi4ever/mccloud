require 'mccloud/provider/core/vm'

require 'mccloud/provider/libvirt/vm/up'
require 'mccloud/provider/libvirt/vm/bootstrap'
require 'mccloud/provider/libvirt/vm/ssh'
require 'mccloud/provider/libvirt/vm/scp'
require 'mccloud/provider/libvirt/vm/rsync'
require 'mccloud/provider/libvirt/vm/halt'
require 'mccloud/provider/libvirt/vm/provision'
require 'mccloud/provider/libvirt/vm/destroy'
require 'mccloud/provider/libvirt/vm/reload'
require 'mccloud/provider/libvirt/vm/forward'


module Mccloud::Provider
  module Libvirt

    class Vm < ::Mccloud::Provider::Core::Vm

      include Mccloud::Provider::Libvirt::VmCommand

      def ip_address
        return self.public_ip_address
      end

      def public_ip_address
        unless raw.nil?
          ip=raw.public_ip_address
        else
          ip=nil
        end
        return ip
      end

      def running?
        if raw.nil?
          return false
        else
          return raw.ready?
        end
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
          found=@provider.raw.servers.all(:name => "#{@provider.filter}#{@name}")
          unless found.nil?
            @raw=found.first
          end
        else
          @raw.private_key_path=@private_key_path
          @raw.username = @user
        end

        return @raw
      end
    end
  end
end
