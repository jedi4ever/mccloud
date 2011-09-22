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

  end
end
