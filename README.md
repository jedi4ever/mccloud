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

## Why not in vagrant?

NOTE: mccloud is meant to be complementary to vagrant - we truely love @mitchellh

- Main reason - this code has been around way before there was discussion on vagrant new providers
- Companies are using it now as it supports EC2, KVM, scripts, NOW
- Vagrant is (currently) focused on desktop vm types only - this extends it to server based cloud solution
- Once providers are available in vagrant, you can easily switch: the effort is not in the Mccloudfile or Vagrantfile syntax but in the provisioning
- Vagrant moves away from the 'gem ' support and targets fat installers - I need this code available as a library
- Vagrant new setup requires root to be installed - not what I want
- Vagrant builder (might) replace veewee with new setup - I want to continue working with it now

Bottom line - if vagrant has the new plugin architecture going and documented I'm happy to review again


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

### Provider kvm (might not work out of the box)

this works together with veewee that support creating kvm template machines.
Like on vagrant, mccloud clones a veewee created vm 

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

## IP definitions

    config.ip.define "ip-demo1" do |config|
      config.ip.provider="aws-eu-west"
      config.ip.address="46.137.72.170"
      config.ip.vmname = "aws-demo1"
    end

## LB definitions

    config.lb.define "mccloud-development-patrick-lb" do |config|
     config.lb.provider="aws-eu-west"
     config.lb.members=["aws-demo2","aws-demo1"]
     config.lb.sorry_members=["aws-demo2"]
    end

## Template/definitions
TODO

## VM definitions
### Core vm

Sharing of files is done over rsync because cloud based architectures don't have the ability to mount local folders

    vm_config.vm.share_folder("somename", "/source/inthemachinepath", "localmachinepath")

    vm_config.vm.bootstrap = "somescript"
    vm_config.vm.bootstrap_user = "root"
    vm_config.vm.bootstrap_password = "blabla"
    vm_config.vm.user = "ubuntu"

    vm_config.vm.name
    vm_config.vm.port

    vm_config.vm.private_key_path
    vm_config.vm.public_key_path
    vm_config.vm.agent_forwarding
    vm_config.vm.autoselection
    vm_config.vm.bootstrap
    vm_config.vm.bootstrap_user
    vm_config.vm.bootstrap_password

    vm_config.vm.forward_port

### AWS vm

    vm.ami
    vm.key_name
    vm.security_groups = Array
    vm.user_data
    vm.flavor
    vm.user

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


this is the way we are currently mounting EBS Volumes with Mccloud.
For attaching an EBS volume created from a Snaphot;

      # see http://fog.io/1.1.2/rdoc/Fog/Compute/AWS/Servers.html
      # and https://github.com/fog/fog/blob/v1.1.2/lib/fog/aws/requests/compute/run_instances.rb
      config.vm.create_options = {
        :block_device_mapping => [
          { "DeviceName" => "/dev/sdf", "Ebs.SnapshotId" =>
  "snap-d056d786", "Ebs.DeleteOnTermination" => true }
        ]
      }

Or, for attaching a newly created EBS volume:

    config.vm.create_options = {
    :block_device_mapping => [
    { "DeviceName" => "/dev/sdf", "Ebs.VolumeSize" => "100",
    "Ebs.DeleteOnTermination" => false }
    ]
    }

The mounting we then do our provision.sh script:

      echo "/dev/sdf1 /mnt/ebs ext4 defaults 0 0" >> /etc/fstab
      mkdir -p /mnt/ebs
      mount -a


### Fog vm

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


### Vmfusion vm
need to check this

## Provisioners

You can use multiple provisioners per vm


### Puppet apply provisioner

    manifest_file
    manifest_path
    module_paths = Array
    pp_path
    options

    vm_config.vm.provision :puppet do |puppet|
      puppet_flags = "--verbose --show_diff"
      puppet.manifest_file = "site.pp"
      puppet.pp_path = "/var/tmp/puppet"
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = [ "puppet/modules" ,"puppet/my-modules"]
      puppet.options = puppet_flags
    end

### Chef-solo provisioner

    cookbooks_path
    roles_path
    provisioning_path
    data_bags_path
    json
    json_erb
    clean_after_run
    roles

    mccloud server is added to json

    add_role(name)
    add_recipe(name)

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


     # Using ips in erb json
     chef.json.merge!({
       :logger => {
                :redis_host_ip => "<%= private_ips['frontend'] %>"
            }
     })

     # Defining a default node
      def default_node(chef)
        chef.add_recipe("ntp")
        chef.add_recipe("timezone")
        chef.json.merge!({
          :nagios_host_ip => "<%= private_ips['monitoring'] %>",
          :ruby => {
          :version => "1.9.2",
          :patch_level => "p180"}}
        })
      end

### Shell provisioner

option command.sudo = true|false

      config.vm.provision :shell do |command|
        command.inline="uptime"
      end

      config.vm.provision :shell do |command|
        command.path="script.sh"
      end

## Usage

Some functions are there in the CLI, but they are left overs from previous coding sessions.

### Mostly working
Tasks:

    mccloud version                      # Prints the Mccloud version information

    mccloud bootstrap [NAME] [FILENAME]  # Executes the bootstrap sequence
    mccloud destroy [NAME]               # Destroys the machine
    mccloud forward [NAME]               # Forwards ports from a machine to localhost
    mccloud halt [NAME]                  # Shutdown the machine
    mccloud help [TASK]                  # Describe available tasks or one specific task
    mccloud image                        # Subcommand to manage images
    mccloud up [NAME]                    # Starts the machine and provisions it
    mccloud provision [NAME]             # Provisions the machine
    mccloud reload [NAME]                # Reboots the machine
    mccloud ssh [NAME] [COMMAND]         # Ssh-shes into the box
    mccloud status [name]                # Shows the status of the current Mccloud environment

    mccloud lb                           # Subcommand to manage Loadbalancers
    mccloud balance [LB-NAME]            # Balances loadbalancers
    mccloud sorry [LB-NAME]              # Puts loadbalancers in a sorry state

    mccloud ip                           # Subcommand to manage IP's
    mccloud ips [NAME]                   # Associate IP addresses

### Experimental/Not checked

    mccloud define NAME TEMPLATE-NAME    # Creates a new definition based on a tempate
    mccloud init                         # Initializes a new Mccloud project

    mccloud keypair                      # Subcommand to manage keypairs
    mccloud keystore                     # Subcommand to manage keystores

    mccloud package [NAME]               # Packages the machine
    mccloud template                     # Subcommand to manage templates
    mccloud vm                           # Subcommand to manage vms


# DISCLAIMER:
this is eternal beta sofware . Don't trust it:) And don't complain if it removes all your EC instances at once....
