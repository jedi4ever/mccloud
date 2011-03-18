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
      mccloud init
      DESC

      first_argument :ami_id, :required => true, :desc => 'AMI ID'
 
      template :mccloudfile, 'Mccloudfile'
                
    end
    
    desc "Generators to simplify the creation of a Mccloud Project"
    add :init, InitGenerator
    
  end
end

