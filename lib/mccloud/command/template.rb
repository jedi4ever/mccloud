module Mccloud
  module Command
    class TemplateCommand < Mccloud::Command::GroupBase
      register "template", "Subcommand to manage templates"

      desc "list [TEMPLATE-NAME]", "List templates"
      def list(selection=nil)
          env.config.templates.each do |name,template|
            env.ui.info template.to_s
          end
      end

    end

  end
end
