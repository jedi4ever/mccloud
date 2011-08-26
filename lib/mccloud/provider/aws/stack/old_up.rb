filter=@session.config.mccloud.stackfilter

# http://allanfeid.com/content/using-amazons-cloudformation-cloud-init-chef-and-fog-automate-infrastructure
on_selected_stacks(selection) do |id,stack|
  stack_fullname="#{filter}#{stack.name}"
  stack_params=stack.params
  template_body=stack.json_rewrite

  provider=@session.config.providers[stack.provider]
  unless (stack.exists?)
    cf = Fog::AWS::CloudFormation.new(stack.provider_options)

    begin
      cf.validate_template({'TemplateBody' => template_body})
    rescue  Excon::Errors::BadRequest => e
      puts "[#{stack.name}] - Error validating template #{stack.jsonfile}:\n #{e.response.body}"
    end

    template_exists=false
    begin
      cf.get_template("#{stack_fullname}")
      template_exists=true
    rescue  Excon::Errors::BadRequest => e
      #            puts "[#{stack.name}] - Error getting the remote template:\n #{e.response.body}"
    end

    unless template_exists
      #DisableRollback, TemplateURL, TimeoutInMinutes
      begin
        cf.create_stack(stack_fullname, {'TemplateBody' => template_body, 'Parameters' => stack_params})
        puts "[#{stack.name}] - Stack creation started"
      rescue Excon::Errors::BadRequest => e
        puts "[#{stack.name}] - Error creating the stack:\n #{e.response.body}"
      end

      begin
        events=cf.describe_stack_events(stack_fullname).body
        sorted_events=events['StackEvents']
        sorted_events.reverse.each do |event|
          printf "  %-25s %-30s %-30s %-20s %-15s\n", event['Timestamp'],event['ResourceType'],event['LogicalResourceId'], event['ResourceStatus'],event['ResourceStatusReason']
        end
      rescue  Excon::Errors::BadRequest => e
        puts "[#{stack.name}] - Error fetching stack events:\n #{e.response.body}"
      end

    else
      puts "[#{stack.name}] - Already exists"

      events=cf.describe_stack_events(stack_fullname).body
      sorted_events=events['StackEvents']
      sorted_events.reverse.each do |event|
        printf "  %-25s %-30s %-30s %-20s %-15s\n", event['Timestamp'],event['ResourceType'],event['LogicalResourceId'], event['ResourceStatus'],event['ResourceStatusReason']
      end
    end

  end

end

