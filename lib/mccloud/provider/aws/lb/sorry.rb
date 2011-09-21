require 'mccloud/provider/aws/lb/associate'

module Mccloud::Provider
  module Aws
    module LbCommand

      def sorry(options)
        balance(@sorry_members,options)
      end

    end
  end
end

