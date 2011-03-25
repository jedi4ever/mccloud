module Mccloud
  module Command
  def boot(selection=nil)
    load_config
    on_selected_machines(selection) do |id,vm|
      puts "starting #{id}"
      PROVIDER.servers.get(id).start
    end
  end
end
end