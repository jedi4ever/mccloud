require 'mccloud/provider/core/ip'
require 'mccloud/provider/aws/ip/associate'

module Mccloud::Provider
  module Aws

    class Ip < ::Mccloud::Provider::Core::Ip

      #Inherits     :name
      #             :provider
      attr_accessor :vmname
      attr_accessor :address

      include Mccloud::Provider::Aws::IpCommand

      def initialize(env)
        super(env)
      end

      def raw
        if @raw.nil?
          rawname="#{@provider.filter}#{@name}"
          @raw=@provider.raw.addresses.all('public-ip' => self.address).first
          env.logger.info("IP found #{@raw.server_id} #{@raw.public_ip}")
        end
        return @raw
      end

    end #Class
  end #module Type
end #Module Mccloud
