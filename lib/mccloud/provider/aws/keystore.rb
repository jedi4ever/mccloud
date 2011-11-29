require 'mccloud/provider/core/keystore'

module Mccloud::Provider
  module Aws

    class Keystore < ::Mccloud::Provider::Core::Keystore

      #Inherits
      #attr_accesor  :name,:provider
      attr_accessor :keypairs

     # include Mccloud::Provider::Aws::KeystoreCommand

      def initialize(env)
        super(env)
        @keypairs=Array.new
      end

    end #Class
  end #module Type
end #Module Mccloud
