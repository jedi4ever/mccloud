require 'mccloud/util/iterator'

module Mccloud
  module Command
    def destroy(selection=nil,options=nil)

      on_selected_stacks(selection) do |id,stack|
        stackfilter=@environment.config.mccloud.stackfilter        
        stack_fullname="#{stackfilter}#{stack.name}"

        stack_exists=false
        provider=@environment.config.providers[stack.provider]         
        cf = Fog::AWS::CloudFormation.new(stack.provider_options)

        begin
          cf.get_template("#{stack_fullname}")
          stack_exists=true
        rescue   Exception => e
          #puts "[#{stack.name}] - Error\n #{e}"
        end

        if stack_exists
          begin
            puts "[#{stack.name}] - Deleting stack"
            cf.delete_stack(stack_fullname)
            events=cf.describe_stack_events(stack_fullname).body
            sorted_events=events['StackEvents']
            sorted_events.reverse.each do |event|
              printf "  %-25s %-30s %-30s %-20s %-15s\n", event['Timestamp'],event['ResourceType'],event['LogicalResourceId'], event['ResourceStatus'],event['ResourceStatusReason']
            end
          rescue Excon::Errors::BadRequest => e
            puts "[#{stack.name}] - Error deleting the stacks:\n #{e.response.body}"
          end    
        else
          puts "[#{stack.name}] - Stack does not exist"
        end


      end

    end
  end
end
