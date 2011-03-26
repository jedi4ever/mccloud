require 'mccloud/util/iterator'

module Mccloud
  module Command
  def boot(selection=nil,options=nil)
    on_selected_machines(selection) do |id,vm|
      puts "starting #{id}"
      vm.instance.start
    end
  end
end
end