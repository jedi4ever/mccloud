module Mccloud
  module Command
    class InitCommand < Base

      register "init", "Initializes a new Mccloud project"
      class_option :provider, :type => :string , :default => "aws", :aliases => "-p"

      def execute
        env.generator.generate(options)
      end

    end #Class
  end #Module
end #Module
