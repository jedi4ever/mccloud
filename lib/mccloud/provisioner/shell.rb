require 'erb'
require 'ostruct'

module Mccloud
  module Provisioner

    class Shell

      attr_reader   :name
      attr_reader   :env

      attr_accessor :path
      attr_accessor :inline
      attr_accessor :nosudo

      def initialize(env)
        @env=env
        @sudo=false
        @name ="shell"
        @inline="who am i"
        @log_level="info"
      end

      def run(server)
        server.transfer(StringIO.new(@inline),"/tmp/shell-provisioner.sh") unless @inline.nil?
        server.transfer(path,"/tmp/shell-provisioner.sh") unless @path.nil?

        server.execute("chmod +x /tmp/shell-provisioner.sh",{:mute => true})

                env.ui.info "[#{server.name}] - [#{@name}] - running shell"
                env.ui.info "[#{server.name}] - [#{@name}] - login as #{server.user}"

                begin
                  if !@sudo || server.user=="root"
                    server.execute("/tmp/shell-provisioner.sh")
                  else
                    server.execute("sudo /tmp/shell-provisioner.sh")
                  end
                rescue Exception
                ensure
                  env.ui.info "[#{server.name}] - [#{@name}] - Cleaning up script"
                  server.execute("rm /tmp/shell-provisioner.sh",{:mute => true})
                end
      end

    end
  end #Module Provisioners
end #Module Mccloud
