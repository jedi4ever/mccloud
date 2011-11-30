require 'mccloud/util/sshkey'

module Mccloud
  class Keypair
    attr_accessor :public_key_path
    attr_accessor :private_key_path
    attr_accessor :name
    attr_accessor :env

    def initialize(name,env)
      @name=name
      @env=env
      @private_key_path=nil
      @public_key_path=nil
      return self
    end

    def exists?
      return false unless File.exists?(@public_key_path)
      return false unless File.exists?(@private_key_path)
      return true
    end

    def generate
      if exists?
        env.ui.info "Keypair: #{@name} already exists"
        env.ui.info "- #{@public_key_path}"
        env.ui.info "- #{@private_key_path}"
      end
        env.ui.info "Generating Keypair: #{@name}"
        env.ui.info "- #{@public_key_path}"
        env.ui.info "- #{@private_key_path}"
        env.ui.info ""
        env.ui.warn "Make sure you make a backup!!"
        rsa_key=::Mccloud::Util::SSHKey.generate({ :comment => "Generate #{@name}"})
        begin
          File.open(@public_key_path,'w'}{|f| f.write(rsa_key.ssh_public_key)}
          File.open(@private_key_path,'w'}{|f| f.write(rsa_key.rsa_private_key)}
        rescue Exception => ex
          env.ui.error "Error generating keypair : #{ex}"
        end
    end

  end
end
