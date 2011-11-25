require 'mccloud/provider/core/lb'
require 'mccloud/provider/aws/lb/associate'
require 'mccloud/provider/aws/lb/sorry'

module Mccloud::Provider
  module Aws

    class Lb < ::Mccloud::Provider::Core::Lb

      #Inherits     :name
      #             :provider
      attr_accessor :members
      attr_accessor :sorry_members

      include Mccloud::Provider::Aws::LbCommand

      def initialize(env)
        members=Array.new
        sorry_members=Array.new
        super(env)
      end

      def raw
        if @raw.nil?
          rawname="#{@name}"
          #rawname="#{@provider.filter}#{@name}"
          @raw=Fog::AWS::ELB.new({:region => provider.region}.merge(provider.options)).load_balancers.get(@name)
          env.logger.info("LB found #{@raw}")
        end
        return @raw
      end

    end

  end
end #Module Mccloud
