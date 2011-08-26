
module Mccloud
  module Provider
    module Core
    class Provider

      attr_accessor :namespace
      
      def get_component(type)
        real_component=nil
        begin
      # Now that we know the actual provider, we can check if the provider has this type of component
        require_path='mccloud/provider/'+@type.to_s.downcase+"/"+type
        require require_path
  
        # Now we can create the real component
        real_component=Object.const_get("Mccloud").const_get("Provider").const_get(@type.to_s.capitalize).const_get(type.to_s.capitalize).new()
        rescue Error => e
          puts "Error getting component - #{e}"
        end
        return real_component
      end
      
      def on_selected_components(type,selection=nil)
        components=self.instance_variable_get("@#{type}s")

        if selection.nil? || selection == "all"
          components.each do |name,component|
            if component.auto_selected?
              yield name,component
            else
              puts "[#{name}] Skipping because it has autoselection off"
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
      
 end
 end
 end
 end
 