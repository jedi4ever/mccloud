module Mccloud
  module Command
    class InitCommand < Base
      argument :box_name, :type => :string, :optional => false ,:default => nil
      argument :template_name, :type => :string, :optional => true ,:default => nil

      register "init NAME TEMPLATE-NAME", "Creates a new Mccloud project based on a template"

      def execute
         require 'mccloud/mccloudfile'
         f=Mccloud::Mccloudfile.new(File.join(env.root_path,"Mccloudfile"))
         f.vm_name=@box_name
         if f.exists?
           env.ui.error "Mccloudfile already exists"
         else
           f.save
         end
      end

    end #Class
  end #Module
end #Module
