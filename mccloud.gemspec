# -*- encoding: utf-8 -*-
require File.expand_path("../lib/mccloud/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "mccloud"
  s.version     = Mccloud::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Patrick Debois"]
  s.email       = ["patrick.debois@jedi.be"]
  s.homepage    = "http://github.com/jedi4ever/mccloud/"
  s.summary     = %q{Cloud integration vagrant style}
  s.description = %q{Use the same simple commandline api to manage cloud interfaces}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "mccloud"

  s.add_dependency "net-ssh", "~> 2.1.0"
  #s.add_dependency "sshkey"
  s.add_dependency "net-scp"
   s.add_dependency "fog", "~> 1.1.0"

  s.add_dependency "json"
  s.add_dependency "ansi"

  #s.add_dependency "templater"
  s.add_dependency "popen4", "~> 0.1.2"
  s.add_dependency "thor", "~> 0.14.6"
  s.add_dependency "highline", "~> 1.6.1"
  #s.add_dependency "progressbar"
  #s.add_development_dependency "cucumber", "0.8.5"


  s.add_dependency "net-ssh-multi"
  #s.add_dependency "rspec"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency("ruby-libvirt","~>0.4.0")
  s.add_development_dependency("vagrant","~>0.8.1")
  s.add_dependency("rake","~>0.9")

  s.add_dependency "i18n"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

