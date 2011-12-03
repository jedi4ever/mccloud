module Mccloud::Provider
  module Core
    module VmCommand


      def share_folder(name,src,dest="tmp",options={})
        new_options={:mute => false}.merge(options)
        rsync(src,dest,new_options)
      end

      # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/185404
      # This should work on windows too now
      # This will result in a ShellResult structure with stdout, stderr and status
      def rsync(src,dest="tmp",options = {})
        unless !File.exists?(src)
          env.ui.info "[#{@name}] - rsyncing #{src}"
          mute="-v" 
          mute="-q -t" if  options[:mute]

          command="rsync --exclude '.DS_Store' #{mute} --delete  -az -e 'ssh #{ssh_commandline_options(options)}' '#{src}/' '#{@user}@#{self.ip_address}:/#{File.join(dest,File.basename(src))}/'"
        else
          env.ui.info "[#{@name}] - rsync error: #{src} does no exist"
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

