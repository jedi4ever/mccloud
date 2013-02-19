require 'net/scp'
module Mccloud::Provider
  module Host
    module VmCommand

      def transfer(src,dest,options = {})
        scp(src,dest,options)
      end

      def scp(src,dest,options = {})

        # override options from Mccloudfile with parameter options
        ssh_options = mccloudfile_options.merge(options)
        
        Net::SCP.start(ip_address,ssh_options[:user],ssh_options) do |auth_scp|
          auth_scp.upload!(src,dest)
        end
      end

      def mccloudfile_options
        opts = Hash.new
        (opts[:user] = @user) if @user
        (opts[:keys] = @private_key_path) if @private_key_path
        (opts[:port] = @port) if @port
        opts
      end

   end #module
  end #module
end #module
