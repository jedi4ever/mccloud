require 'mccloud/util/iterator'

module Mccloud
  module Command

    def ssh(selection,command,options)

      @session.config.providers.each do |name,provider|
        provider.ssh(selection,command,options)
      end

    end

  end
end
