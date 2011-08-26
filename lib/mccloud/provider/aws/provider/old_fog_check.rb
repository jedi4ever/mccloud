
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
