require 'mccloud/util/platform'

module Mccloud
  module Provider
  module Core
    module VmCommand

        def ssh_commandline_options(options)
                 
          command_options = [
            "-q", #Suppress warning messages 
#            "-T", #Pseudo-terminal will not be allocated because stdin is not a terminal. 
            "-p #{@port}", 
            "-o UserKnownHostsFile=/dev/null",
            "-t -o StrictHostKeyChecking=no",
            "-o IdentitiesOnly=yes",
            "-o VerifyHostKeyDNS=no"
          ]
          unless @private_key_path.nil?
            command_options << "-i #{@private_key_path}"
            
          end
          commandline_options="#{command_options.join(" ")} ".strip
          
          user_option=@user.nil? ? "" : "-l #{@user}"
          
            return "#{commandline_options} #{user_option}"
        end
        
        def execute(command=nil,options={})
          ssh(command,options)
        end

        def fg_exec(ssh_command,options)
          # Some hackery going on here. On Mac OS X Leopard (10.5), exec fails
          # (GH-51). As a workaround, we fork and wait. On all other platforms,
          # we simply exec.
          pid = nil
          pid = fork if Mccloud::Util::Platform.leopard? || Mccloud::Util::Platform.tiger?
          
          Kernel.exec ssh_command if pid.nil?
          Process.wait(pid) if pid
        end
        
        def bg_exec(ssh_command,options)
          result=ShellResult.new("","",-1)

          IO.popen("#{ssh_command}") { |p| 
            p.each_line{ |l| 
              result.stdout+=l
              print l unless options[:mute]
            }   
            result.status=Process.waitpid2(p.pid)[1].exitstatus
            if result.status!=0
              puts "Exit status was not 0 but #{result.status}" unless options[:mute]
            end 
          }   
          return result
        end
        
        def ssh(command=nil,options={})

            # Command line options
            extended_command="#{command}"

            unless options.nil?
                extended_command="screen -R \\\"#{command}\\\"" unless options[:screen].nil?
            end

            host_ip=self.ip_address
            
            unless host_ip.nil? || host_ip==""
            ssh_command="ssh #{ssh_commandline_options(options)} #{host_ip} \"#{extended_command}\""
            
            unless options.nil? || options[:mute]
               puts "[#{@name}] - ssh -p #{@port} #{@user}@#{@name}(#{host_ip}) \"#{command}\""
             end              
            
            if command.nil? || command==""
              fg_exec(ssh_command,options)
            else
              bg_exec(ssh_command,options)
            end
                     
          else
              puts "Can't ssh into '#{@name} as we couldn't figure out it's ip-address"
          end
          end

      end #Module
    end #module
  end #Module
end #module
