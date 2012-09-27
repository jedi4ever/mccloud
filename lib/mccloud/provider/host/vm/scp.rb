require 'net/scp'
module Mccloud::Provider
  module Host
    module VmCommand

      def transfer(src,dest,options = {})
        scp(src,dest,options)
      end

       def scp(src,dest,options = {})
         if options[:user]

           if options[:password]
             Net::SCP.start(ip_address,options[:user],:password => options[:password]) do |auth_scp|
               auth_scp.upload!(src,dest)
             end
           else
             Net::SCP.start(ip_address,options[:user]) do |auth_scp|
               auth_scp.upload!(src,dest)
             end
           end

         else
           Net::SCP.upload!(ip_address,@user,src,dest,options)
         end
      end

       end #module
      end #module
    end #module
