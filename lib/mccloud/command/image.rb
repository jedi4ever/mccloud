module Mccloud
  module Command
    class ImageCommand < Mccloud::Command::GroupBase
      register "image", "Subcommand to manage images"

      desc "list [IMAGE-NAME]", "List Images"
      def list(selection=nil)
        env.load!
      	
        env.config.providers.each do |name,provider|
            env.logger.debug("Asking provider #{name} to list image #{selection}")
            provider.image_list(selection,options)
        end
      end

      desc "create [SERVER-NAME]", "Create Image from Server"
      def create(selection=nil)
        env.load!
      	
        env.ui.error "Not yet implemented"
      end

      desc "destroy IMAGE-NAME","Destroy image"
      def destroy(selection)
        env.load!
      	
        env.config.providers.each do |name,provider|
            env.logger.debug("Asking provider #{name} to destroy image #{selection}")
            provider.image_destroy(selection,options)
        end

      end

    end #Class

  end #Module
end # Module
