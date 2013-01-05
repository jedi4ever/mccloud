# Note: documentation is currently in flux

# About
## What the hell is mccloud?

Over the years I fell in love with [Vagrant](http://vagrantup.com) and wanted to have the same workflow for ec2, kvm,  internal clouds etc..

Therefore Mccloud aims to be the equivalent of ``vagrant`` but extending it to use providers:
- aws/ec2
- kvm
- simple scripts
- and of course vagrant itself.

I'm aware vagrant might extend it's providers in the future; still as they are currently not yet implemented I thought I'd share this code with you.
As new provider will become available in vagrant they will also be available in mccloud through the vagrant provider

## Kudos to great stuff
Without the following opensource software this would not be that awesome!

- [Vagrant](http://www.vagrantup.com) is great for testing machines on your local machines
- [Fog](https://github.com/geemus/fog) is a great fog library for managing cloud systems
- [Fission](https://github.com/thbishop/fission) is a gem to interact with vmware fusion machines

Kudos to the authors!

# Installation
## Requirements

- You currently need ruby installed. Either use the system ruby or install [rvm](https://rvm.io/)
- libxml, libxslt and nokogiri

## Using the stable gem

    $ gem install mccloud

## Using the cutting edge github code

    $ git clone git@github.com:jedi4ever/mccloud.git
    $ cd mccloud
    # Note when you use rvm , there is an .rvmrc that will set some aliases
    $ bundle install
    $ bundle exec mccloud

# Configuration
Similar to a Vagrantfile, mccloud has a Mccloudfile where all is configured.
TODO: there is currently no ``mccloud init`` as it's hard to guess your preferred options

## Mccloudfile Skeleton
A mccloudfile is actually a ruby code file with a specific block

    Mccloud::Config.run do |config|
    end

## Provider section
As mccloud supports multiple providers , the first part you need to do it define the providers you want to use

### Provider AWS

You can use this provider to create/manage ec2 instances.

As this relies on fog, you first have to create a fog configuration file

    $ cat $HOME/.fog
    :default:
      :aws_access_key_id: <your id here>
      :aws_secret_access_key: <your acess key here>

The syntax to use for an ec2

    Mccloud::Config.run do |config|

      # Define a :aws provider 'aws-us-east'
      config.provider.define "host-provider" do |provider_config|

        #Note: this are option provided to fog for creation
        provider_config.provider.options = { }

        # Region in which to create the VM
        provider_config.provider.region = "us-east-1"

        ## Check if necessary keypairs exist
        ## To speed things up, set it to false
        provider_config.provider.check_keypairs = false

        ## Disable check if required security groups exist
        ## To speed things up, set it to false
        provider_config.provider.check_security_groups =  false

        ## If you share an amazon account with multiple people
        ## You can use namespaces to separate resources
        ## All resources will take this prefix
        provider_config.provider.namespace = ""

        ## Fog credential pair to use in .fog file
        provider_config.provider.credential = :default

      end
    end

If using the aws/ec see also the section about defining keystores and keypairs

### Provider host
Useful with machines that are only ssh-able and where you don't have create options

    Mccloud::Config.run do |config|

      # Define a :host provider 'host-provider' that is ssh-able
      config.provider.define "host-provider" do |provider_config|
        provider_config.provider.flavor = :host
      end

    end

### Provider vagrant
Have mccloud pick up your ``Vagrantfile``

    Mccloud::Config.run do |config|

      # Define a :vagrant provider 'vagrant-provider'
      config.provider.define "vagrant-provider" do |provider_config|
        provider_config.provider.flavor = :vagrant
      end
    end

### Provider script
Usefull if your cloud doesn't have an ip, but you can create start,stop, etc... scripts to do the work

    Mccloud::Config.run do |config|

      datacenter_settings = {
        :DATACENTER => 'belgium',
        :ENVIRONMENT => 'test'
      }

      # Define a :script provider 'script-provider'
      config.provider.define "script-provider" do |provider_config|
        provider_config.provider.flavor = :script


        # environment variables to pass to the scripts
        # these are passed as MCCLOUD_<varname>
        provider_config.provider.variables = datacenter_settings

        # No need for a namespace
        provider_config.provider.namespace = ""

        # location of the start, stop etc.. scripts
        provider_config.provider.script_dir = "myscript-provider"
      end

    end

### Provider kvm
    config.provider.define "kvm-libvirt" do |config|
      config.provider.type=:libvirt
      config.provider.options={ :libvirt_uri => "qemu+ssh://ubuntu@kvmbox/system" }
      config.provider.namespace="test"
    end

## Keypair section

Currently only used by aws provider. Allows you to define a re-usable name for keypairs for each aws region

    config.keypair.define "mccloud" do |key_config|
      key_config.keypair.public_key_path = "#{File.join(ENV['HOME'],'.ssh','mccloud_rsa.pub')}"
      key_config.keypair.private_key_path = "#{File.join(ENV['HOME'],'.ssh','mccloud_rsa')}"
    end


## Keystore section

Currently only used by aws provider. Allows you to define multiple keystores for your aws keys

    config.keystore.define "aws-us-east-key-store" do |keystore_config|
      keystore_config.keystore.provider = "aws-us-east"
      keystore_config.keystore.keypairs = [
        # :name is the name as it will be displayed on amazon
        # :keypair is the named as defined  in the mccloudfile
        { :name => "mccloud", :keypair => "mccloud"},
      ]
    end

## VM definitons
### Core vm

    vm_config.vm.share_folder("somename", "/source/inthemachinepath", "localmachinepath")
    vm_config.vm.bootstrap = "somescript"
    vm_config.vm.bootstrap_user = "root"
    vm_config.vm.bootstrap_password = "blabla"
    vm_config.vm.user = "ubuntu"

### AWS vm

    config.vm.define "demo" do |config|
     config.vm.provider="aws-eu-west"
     config.vm.ami="ami-e59ca991"
     config.vm.flavor="t1.micro"
     config.vm.zone="eu-west-1a"
     config.vm.user="ubuntu"
     config.vm.security_groups=["thesecuritygroup"]
     config.vm.key_name="mccloud-key-patrick"
     config.vm.bootstrap="definitions/ubuntu/bootstrap-ubuntu-system.sh"
     config.vm.private_key_path="keys/mccloud_rsa"
     config.vm.public_key_path="keys/mccloud_rsa.pub"
    end

### Vagrant vm

    config.vm.define "compute1" do |vm_config|
      vm_config.vm.provider   = "vagrant"
    end

### Host vm

    config.vm.define "mycoolhost.com" do |config|
      config.vm.provider=:hosts
      config.vm.ip_address="mycoolhost.com"
      config.vm.user="ubuntu"
      config.vm.port = "2222"
      config.vm.bootstrap  = "bootstrap/centos-603"
      config.vm.agent_forwarding = true
    end

### KVM vm

    config.vm.define "backend" do |config|
     config.vm.provider="juno-libvirt"

     config.vm.create_options={
       :network_interface_type => "bridge",
       :volume_template_name => "test-baseimage.img",
       :cpus => "3",
       :memory_size => 2*1024*1024, #2 GB
     }
     config.vm.user="ubuntu"
     config.vm.bootstrap="definitions/ubuntu/bootstrap-ubuntu-system.sh"
     config.vm.private_key_path="keys/mccloud_rsa"
     config.vm.public_key_path="keys/mccloud_rsa.pub"
    end


### Vmfusion

## Provisioners

You can use multiple provisioners per vm


### Puppet apply provisioner

    vm_config.vm.provision :puppet do |puppet|
      puppet_flags = "--verbose --show_diff"
      puppet.manifest_file = "site.pp"
      puppet.pp_path = "/var/tmp/puppet"
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = [ "puppet/modules" ,"puppet/my-modules"]
      puppet.options = puppet_flags
    end

### Chef-solo provisioner

     # Read chef solo nodes files
     require 'chef'
     nodes = []
     Dir["data_bags/node/*.json"].each do |n|
           nodes << JSON.parse(IO.read(n))
     end

     nodes.each do |n|
       config.vm.define n.name do |vm_config|
         vm_config.vm.provider   = "host"
         vm_config.vm.ip_address = n.automatic_attrs[:ipaddress]
         vm_config.vm.user       = n.automatic_attrs[:sudo_user]

         vm_config.vm.bootstrap  = File.join("bootstrap","bootstrap-#{n.automatic_attrs[:platform]}.sh")
         vm_config.vm.bootstrap_user  = n.automatic_attrs[:bootstrap_user]
         vm_config.vm.bootstrap_password  = n.automatic_attrs[:bootstrap_password]

         vm_config.vm.provision :chef_solo do |chef|
          chef.cookbooks_path = [ "cookbooks", "site-cookbooks" ]
          chef.roles_path = "roles"
          chef.data_bags_path = "data_bags"
          chef.clean_after_run = false

          chef.json.merge!(n.default_attrs)
          chef.json.merge!(n.automatic_attrs)
          chef.json.merge!(n.override_attrs)

          chef.add_role n.chef_environment
          chef.add_role n.automatic_attrs[:platform]

          n.run_list.run_list_items.each do |r|
            chef.add_role r.name if r.type == :role
            chef.add_recipe r.name if r.type == :recipe
          end
        end #end provisioner

      end #end vm define
    end # nodes.each

### Shell provisioner

      config.vm.provision :shell do |command|
        command.inline="uptime"
      end
    end

## Usage

### Check the status
$ mccloud status

### Bootstrap the machine
$ mccloud bootstrap web

### (interactive) Login into the machine
$ mccloud ssh web

### Halt the machine
$ mccloud halt web

### Start the machine again
$ mccloud up web

### Provision the machine
$ mccloud provision web

### Port forwarding server
$ mccloud server

### Destroy the machine again
$ mccloud destroy web

# DISCLAIMER:
this is eternal beta sofware . Don't trust it:) And don't complain if it removes all your EC instances at once....
