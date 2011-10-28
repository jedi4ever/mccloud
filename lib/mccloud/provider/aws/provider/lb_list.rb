module Mccloud
  module Provider
    module Aws
      module ProviderCommand

        def lb_list(selection=nil,options=nil)
          env.logger.info("#{selection} - #{options}")

          env.logger.info("Looking for loadbalancers in region #{@region}")
          elb=Fog::AWS::ELB.new({:region => @region}.merge(@options))
          elb.load_balancers.each do |lb|
            env.ui.info "Id #{lb.id} - DNS #{lb.dns_name} - Zones: #{lb.availability_zones.join(',')} - Instances #{lb.instances.join(',')} "
          end
        end

      end
    end
  end

end
