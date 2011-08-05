require 'mccloud/util/iterator'

module Mccloud
  module Command

    def up(selection,options)

      @session.config.providers.each do |name,provider|
        provider.up(selection,options)
      end

    end

  end
end
