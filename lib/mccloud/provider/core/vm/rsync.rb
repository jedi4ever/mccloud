module Mccloud::Provider
  module Core
    module VmCommand

      def share_folder(name , dest,src,options={})
        new_options={:mute => false}.merge(options)
        @shared_folders << { :name => name, :dest => dest, :src => src, :options => new_options}
      end

      def share
        @shared_folders.each do |folder|
          self.execute("test -d '#{folder[:dest]}' || mkdir -p '#{folder[:dest]}' ")
          clean_src_path=File.join(Pathname.new(folder[:src]).expand_path.cleanpath.to_s,'/')
          rsync(clean_src_path,folder[:dest],folder[:options])
        end
      end

      def share_sync(src, dest, options = {})
        clean_src_path=File.join(Pathname.new(src).cleanpath.to_s,'/')
        rsync(clean_src_path,dest,options)
      end

      def windows_client?
        RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
      end

      # cygwin rsync path must be adjusted to work
      def adjust_rsync_path(path)
        return path unless windows_client?
        path.gsub(/^(\w):/) { "/cygdrive/#{$1}" }
      end

      # see http://stackoverflow.com/questions/5798807/rsync-permission-denied-created-directories-have-no-permissions
      def rsync_permissions
        '--chmod=ugo=rwX' if windows_client?
      end

      # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/185404
      # This should work on windows too now
      # This will result in a ShellResult structure with stdout, stderr and status
      def rsync(src,dest="tmp",options = {})
        unless !File.exists?(src)
          env.ui.info "[#{@name}] - rsyncing #{src}"
          mute="-v" 
          mute="-q -t" if  options[:mute]

          if Pathname.new(dest).absolute?
            dest_path = dest
          else
            dest_path = File.join(File::Separator,dest)
          end

          if dest_path == File::Separator
            puts "no way we gonna rsync --delete the root filesystem"
            exit -1
          end

          command="rsync #{rsync_permissions} --exclude '.DS_Store' --exclude '.hg' --exclude '.git' #{mute} --delete-excluded --delete  -az -e 'ssh #{ssh_commandline_options(options)}' '#{adjust_rsync_path(src)}' '#{@user}@#{self.ip_address}:#{dest_path}'"
        else
          env.ui.info "[#{@name}] - rsync error: #{src} does no exist"
          exit
        end

        result=ShellResult.new("","",-1)
        env.logger.info "#{command}" unless options[:mute]
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

