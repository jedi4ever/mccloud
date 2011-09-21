module Mccloud
  module Provider
    module Aws
      module ProviderCommand

        def image_list(selection=nil,options=nil)
          images=raw.images.all({"Owner" => "self"})
          env.logger.info("#{selection} - #{options}")
          images.each do |image|
            require 'pp'
            env.ui.info "Id: #{image.id} Name: #{image.name}, Description: #{image.description}"
          end
        end

      end
    end
  end

end
