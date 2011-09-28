module Mccloud::Provider
  module Core
    module VmCommand


      def share(path,options={})
        options[:mute]=true
        rsync(path,options)
      end

      # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/185404
      # This should work on windows too now
      # This will result in a ShellResult structure with stdout, stderr and status
      def rsync(path,options = {})
        unless !File.exists?(path)
          env.ui.info "[#{@name}] - rsyncing #{path}"
          command="rsync -q --exclude '.DS_Store' --delete  -az -e 'ssh #{ssh_commandline_options(options)}' '#{path}/' '#{@user}@#{self.ip_address}:/tmp/#{File.basename(path)}/'"
        else
          env.ui.info "[#{@name}] - rsync error: #{path} does no exist"
          exit
        end

        result=ShellResult.new("","",-1)
        env.ui.info "#{command}" unless options[:mute]
        IO.popen("#{command}") { |p|
          p.each_line{ |l|
            result.stdout+=l
            print l unless options[:mute]
          }
          result.status=Process.waitpid2(p.pid)[1].exitstatus
          if result.status!=0
            env.ui.info "Exit status was not 0 but #{result.status}" unless options[:mute]
          end
        }
        return result
      end

    end #module
  end #module
end #module

