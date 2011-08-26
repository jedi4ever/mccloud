class Forwarding
  attr_accessor :name
  attr_accessor :local
  attr_accessor :remote
  
  def initialize(name,local,remote)
    @name=name
    @local=local
    @remote=remote
  end
end