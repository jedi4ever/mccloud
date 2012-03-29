class Forwarding
  attr_accessor :name
  attr_accessor :local
  attr_accessor :remote

  attr_accessor :namespace


  def initialize(name,remote,local)
    @name=name
    @local=local
    @remote=remote
  end
end
