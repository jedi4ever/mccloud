module Mccloud
  module Provider
    module Aws
      module ProviderCommand

        def image_destroy(imageId,options=nil)
            begin
              image=raw.images.get(imageId)
              if image.nil?
                env.ui.info "[#{name}] - ImageId #{imageId} not found"
              else
                env.ui.info "[#{name}] - ImageId #{imageId} found"
                env.ui.info "[#{name}] - Deregistering #{imageId} now"
                begin
                  raw.deregister_image(imageId)
                rescue Fog::Service::Error => fogerror
                  env.ui.error "[Error] #{fogerror}"
                end
              end
          end
        end

      end
    end
  end

end
