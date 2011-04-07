require 'templater'

module Mccloud
  module Generators
    extend Templater::Manifold

    class InitGenerator < Templater::Generator
      def self.source_root
        File.join(File.dirname(__FILE__), 'templates')
      end

      desc <<-DESC
      Initialize a mccloud environment 
      mccloud init [ --imageId=ID]
      DESC

      option :mcPrefix, :required => true, :desc => 'Mccloud Prefix'
      option :mcEnvironment, :required => true, :desc => 'Mccloud Environment'
      option :mcIdentity, :required => true, :desc => 'Mccloud Identity'

      option :imageId, :required => true, :desc => 'Image ID'
      option :userName, :required => true, :desc => 'User Name'
      option :flavorId, :required => true, :desc => 'Flavor Id'
      option :providerId, :required => true, :desc => 'Provider Id'
      option :securityGroup, :required => true, :desc => 'Security Group' 
      option :keyName, :required => true, :desc => 'Key Name' 
      option :publicKeyPath, :required => false, :desc => 'Path to Public Key' 
      option :privateKeyPath, :required => true, :desc => 'Path to Private Key' 

      option :availabilityZone, :required => true, :desc => 'Availability Zone' 
       
      template :mccloudfile, 'Mccloudfile'
                
    end
    
    desc "Generators to simplify the creation of a Mccloud Project"
    add :init, InitGenerator
    
  end
end

