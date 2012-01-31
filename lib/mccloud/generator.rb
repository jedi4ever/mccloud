require 'mccloud/mccloudfile'
require 'mccloud/keypair'

module Mccloud

  # This takes care of initializing a new Mccloud project
  class Generator

    attr_accessor :env

    def initialize(env)
      @env=env
      @generators=[:aws,:kvm,:host]
    end

    def generate(options={})
      defaults={ :provider => :aws, :force => false}
      options=defaults.merge(options)
      provider=options[:provider].to_sym
      raise ::Mccloud::Error, "Unsupported provider #{provider}" unless @generators.include?(provider)
      generate_mccloudfile(options)
      generate_mccloud_sshkey(options)
    end

    def generate_mccloudfile(options)
      begin
        f=Mccloud::Mccloudfile.new(File.join(env.root_path,"Mccloudfile"))
        if f.exists?
          env.ui.error "Mccloudfile already exists"
        else
          env.ui.info "Creating a new Mccloudfile"
          f.generate(options)
        end
      rescue Error => ex
        raise ::Mccloud::Error, "Error creating Mccloudfile.\n#{ex}"
      end
    end

    def generate_mccloud_sshkey(options)
      k=Mccloud::Keypair.new("mccloud",env)
      if k.exists?
          env.ui.info "Re-using existing mccloud RSA key in #{k.public_key_path}"
      else
        k.generate(options)
      end
    end

  end
end
