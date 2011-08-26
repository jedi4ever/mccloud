require 'erb'
require 'ostruct'



module Mccloud
  module Provisioner

    class Shell

      attr_reader   :name

      attr_accessor :path
      attr_accessor :inline
      attr_accessor :nosudo

      def initialize
        @sudo=false
        @name ="shell"
        @inline="who am i"
        @log_level="info"
      end

      def run(server)
        server.transfer(StringIO.new(@inline),"/tmp/shell-provisioner.sh") unless @inline.nil?
        server.transfer(path,"/tmp/shell-provisioner.sh") unless @path.nil?
        
        server.execute("chmod +x /tmp/shell-provisioner.sh",{:mute => true})
        
                puts "[#{server.name}] - [#{@name}] - running shell"
                puts "[#{server.name}] - [#{@name}] - login as #{server.user}"
      
                begin
                  if !@sudo || server.user=="root"
                    server.execute("/tmp/shell-provisioner.sh")
                  else
                    server.execute("sudo /tmp/shell-provisioner.sh")
                  end
                rescue Exception
                ensure
                  puts "[#{server.name}] - [#{@name}] - Cleaning up script"
                  server.execute("rm /tmp/shell-provisioner.sh",{:mute => true})
                end
      end
 
    end
  end #Module Provisioners
end #Module Mccloud