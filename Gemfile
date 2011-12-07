source "http://rubygems.org"

#gem 'fog', :path => "/Users/patrick/imac/fog"
#gem "fog", :git => 'git@github.com:geemus/fog.git',:branch => 'master'

#http://www.deploymentzone.com/2011/05/24/guard-rspec-2-and-growl/
group :development do
  gem 'rspec', '>= 2.0'
  gem "rake"
  gem 'autotest'
  if RUBY_PLATFORM.downcase.include?("darwin")
    gem 'autotest-fsevent'
    # also install growlnotify from the Extras/growlnotify/growlnotify.pkg in Growl disk image
    gem 'autotest-growl'
  end
end

gem "mccloud", :path => "."
