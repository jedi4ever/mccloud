## Note:
- This is a quick copy and paste job(weekend hacking), you should not consider it anything but experimental right now
- But I wanted the idea already with others

## Kudos to great stuff
- [Vagrant](http://www.vagrantup.com) is great for testing machines on your local machines
- [Fog](https://github.com/geemus/fog) is a great fog library for managing cloud systems

Without those two, this project would not be possible. Kudos to the authors!

This project tries to combine both:
- Because your local machine might outgrow your complexity your local machine can handle
- use the same vagrantfile for local dev, and cloud devel

## Some notes before you dive in

- I could probably have integrated with vagrant code but this would have taken me longer to understand vagrant code
- I didn't want the dependency on virtualbox
- The machines it creates will have the prefix as defined in the Mccloudfile, so this should not pollute your stuff

## Todo:

- provision to other providers than ec2
- Shared folders will become rsync-ed directories
- try to stay fully compatible with Vagrantfile
- manage cloud providers better

## How it will work/works

### Create a config file for fog. Note that these are spaces in front and no tabs
$ cat $HOME/.fog
<pre>
:default:
  :aws_access_key_id: <your id here>
  :aws_secret_access_key: <your acess key here>
</pre>

### Create a Mccloud project
$ mccloud init

This will create a Mccloudfile

### Edit your Mccloud appropriate

<pre>
	Mccloud::Config.run do |config|
	  # All Mccloud configuration is done here. For a detailed explanation
	  # and listing of configuration options, please view the documentation
	  # online.

	  config.mccloud.prefix="mccloud"

	  config.vm.define :web do |web_config|
	    web_config.vm.ami = "ami-cef405a7"
	    web_config.vm.provider="AWS"

	    #web_config.vm.provisioner=:chef_solo
	    #web_config.vm.provisioner=:puppet

	    web_config.vm.provider_options={ 
	      # ID = "ami-cef405a7" = x64 Ubuntu 10.10
	      :image_id => 'ami-cef405a7', 
	      # Flavors
	      :flavor_id => 't1.micro',
	      #:flavor_id => 'm1.large',
	      :groups => %w(ec2securitygroup), :key_name => "ec2-keyname",
	      :availability_zone => "us-east-1b" 
	    }
	    web_config.vm.forward_port("http", 80, 8080)
	    web_config.vm.user="ubuntu"
	    web_config.vm.bootstrap="ruby-bootstrap.sh"
	    web_config.vm.key="my-ec2-key.pem"
	  end

	  ### Provisioners
	  config.vm.provision :puppet do |puppet|
	    puppet.pp_path = "/tmp/vagrant-puppet"
	    #puppet.manifests_path = "puppet/manifests"
	    #puppet.module_path = "puppet/modules"
	    puppet.manifest_file = "newbox.pp"
	  end

	  config.vm.provision :chef_solo do |chef|
	     chef.cookbooks_path = ["<your cookboopath>"]
	     chef.add_recipe("<some recipe>")
	     # You may also specify custom JSON attributes:
	     chef.json.merge!({})
	  end
	end

</pre>

### Start your machines
# If the machine does not yet exist, it will also run bootstrap
$ mccloud up web

### Check the status
$ mccloud status

### Bootstrap the machine
$ mccloud bootstrap web

### (interactive) Login into the machine
$ mccloud ssh web

### run a command on a machine
$ mccloud command web "who am i"

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
