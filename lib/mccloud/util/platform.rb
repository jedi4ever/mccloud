require 'rbconfig'

#Shameless copy of Vagrant code
module Mccloud
  module Util
    # This class just contains some platform checking code.
    class Platform
      class << self
        def tiger?
          platform.include?("darwin8")
        end

        def leopard?
          platform.include?("darwin9")
        end

        [:darwin, :bsd, :linux].each do |type|
          define_method("#{type}?") do
            platform.include?(type.to_s)
          end
        end

        def platform
          RbConfig::CONFIG["host_os"].downcase
        end
      end
    end
  end
end
