require 'mccloud/provider/aws/command/status'

module Mccloud::Provider
  class Aws
    attr_accessor :provider_options
    attr_accessor :raw_provider
    attr_accessor :raw_provider_options
    attr_accessor :name
    attr_accessor :type
    attr_accessor :session
    
    include Mccloud::Provider::AWS::Command
    
    def initialize(provider_options)
      @provider_options=provider_options
      @type=self.class.to_s.split("::").last
      @name="#{@type}-#{@provider_options[:region].to_s}"
      @raw_provider_options={}
      
    end
    
    def load(session)
      @session=session
      if @session.config.providers[@name].nil?
        @session.logger.info "Loading provider #{@name}"
        
        @raw_provider_options={:provider => "AWS"}
        @raw_provider_options.merge!(@provider_options)
        @session.logger.debug "#{@type} options: #{@raw_provider_options}"
        begin
          @raw_provider=Fog::Compute.new(@raw_provider_options)
          @session.config.providers[@name]=self
        rescue ArgumentError => e
          handle_error(e)
        end
      else
          @session.logger.debug "#{@name} already loaded"        
      end     
      
    end

    def load_resources(filter)
    end
    
    include Mccloud::Util
    
    def up(selection,options)
      on_selected_stacks(selection) do |id,stack|
      end

      on_selected_machines(selection) do |id,vm|
      end
   
    end
    
    def handle_error(e)      
          #  Missing required arguments: 
          required_string=e.message
          required_string["Missing required arguments: "]=""
          required_options=required_string.split(", ")
          puts "Please provide credentials for provider [#{vm.provider}]:"
          answer=Hash.new
          for fog_option in required_options do 
            answer["#{fog_option}".to_sym]=ask("- #{fog_option}: ") 
            #{ |q| q.validate = /\A\d{5}(?:-?\d{4})?\Z/ }
          end
          puts "\nThe following snippet will be written to #{File.join(ENV['HOME'],".fog")}"

          snippet=":default:\n"
          for fog_option in required_options do
            snippet=snippet+"  :#{fog_option}: #{answer[fog_option.to_sym]}\n"
          end

          puts "======== snippit start ====="
          puts "#{snippet}"
          puts "======== snippit end ======="
          confirmed=agree("Do you want to save this?: ")

          if (confirmed)
            fogfilename="#{File.join(ENV['HOME'],".fog")}"
            fogfile=File.new(fogfilename,"w")
            fogfile.puts "#{snippet}"
            fogfile.close
            FileUtils.chmod(0600,fogfilename)
          else
            puts "Ok, we won't write it, but we continue with your credentials in memory"
            exit -1
          end
          begin
            answer[:provider]= vm.provider
            session.config.providers[vm.provider]=Fog::Compute.new(answer)
          rescue
            puts "We tried to create the provider but failed again, sorry we give up"
            exit -1
          end
      
    end

  end # End Class
end # End Module
