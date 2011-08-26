require 'mccloud/util/iterator'

module Mccloud
  module Command
    def deregister(imageId=nil,options=nil)

      if imageId.nil?
        puts "[Error] We need at least need an imageId."
        exit
      end


      #f=Fog::Compute.new({ :region => "eu-west-1", :provider => "AWS"})
      # i=f.create_image("i-c1ac2bb7","name","description")
      # f.images.all({ "Owner" => "self"})
      # f.deregister_image("ami-796d5b0d")

      puts "Looking for imageId: #{imageId}"
      @session.config.providers.each do |name,provider|
        begin
          image=provider.images.get(imageId)
          if image.nil?
            puts "[#{name}] - ImageId #{imageId} not found"
          else
            puts "[#{name}] - ImageId #{imageId} found"
            puts "[#{name}] - Deregistering #{imageId} now"
            begin
              provider.deregister_image(imageId)
            rescue Fog::Service::Error => fogerror
              puts "[Error] #{fogerror}"
            end
          end
        end
      end


    end #def
  end #module
end #module
