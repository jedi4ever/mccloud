module Mccloud
  module Provider
    module Core
      class Provider

        attr_reader :env

        attr_accessor :namespace

        def initialize(name,options,env)
          @env=env
        end

        def get_component(type,env)
          real_component=nil
          begin
            # Now that we know the actual provider, we can check if the provider has this type of component
            require_path='mccloud/provider/'+@type.to_s.downcase+"/"+type
            require require_path
            # Now we can create the real component

            env.logger.debug("provide #{@type} about to create component of type #{type}")

            real_component=Object.const_get("Mccloud").const_get("Provider").const_get(@type.to_s.capitalize).const_get(type.to_s.capitalize).new(env)

          rescue Error => e
            env.ui.error "Error getting component - #{e}"
          end
          return real_component
        end

        def on_selected_components(type,selection=nil)
          unless self.instance_variables.include?("@#{type}s".to_sym)
            env.logger.info "There are no #{type}s defined for provider #{@name}"
            # Nothing to do here
            return
          end

          components=self.instance_variable_get("@#{type}s")

          if selection.nil? || selection == "all"
            components.each do |name,component|
              if component.auto_selected?
                yield name,component
              else
                env.ui.info "[#{name}] Skipping because it has autoselection off"
              end
            end
          else # a specific component
            if components.has_key?(selection)
              yield name,components[selection]
            end
          end
        end

        def filter
          if @namespace.nil? || @namespace==""
            return ""
          else
            return "#{@namespace}-"
          end
        end

        #TODO this loading of gem , needs to be moved else where
        #This provider should only check what it needs

        def check_gem_availability(gems)

          gems.each do |gemname|
            availability_gem=false
            begin
              availability_gem=true unless Gem::Specification::find_by_name("#{gemname}").nil?
            rescue Gem::LoadError
              availability_gem=false
            rescue
              availability_gem=Gem.available?("#{gemname}")
            end
            unless availability_gem
              abort "The #{gemname} gem is not installed and is required by the #{@name.to_sym} provider"
              exit
            end
          end
        end

         def method_missing(m, *args, &block)
          env.logger.info "There's no method #{m} defined for provider #{@name}-- ignoring it"
         end

      end
    end
  end
end

