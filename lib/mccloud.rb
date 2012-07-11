require 'json'

require 'i18n'
require 'openssl'
require 'pathname'

module Mccloud
  # The source root is the path to the root directory of
  # the Mccloud gem.
  def self.source_root
    @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end
end

# # Default I18n to load the en locale
I18n.load_path << File.expand_path("templates/locales/en.yml", Mccloud.source_root)

# Load the things which must be loaded before anything else
require 'mccloud/cli'
require 'mccloud/ui'
require 'mccloud/command'
require 'mccloud/error'
#require 'mccloud/logger'
require 'mccloud/environment'
require 'mccloud/version'
