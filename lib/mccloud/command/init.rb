require 'mccloud/generators'
require 'highline/import'
require 'mccloud/util/sshkey'

require 'erb'

module Mccloud
  module Command
    include Mccloud::Util
    def self.init(amiId=nil,options=nil)
      init_options=ARGV

      puts "Welcome to the Mccloud configurator: "
      init_options<< "--mcPrefix"
      init_options<< "mccloud"

      init_options<< "--providerId"
      init_options<< "AWS"

      create_fog('AWS')

      template=ERB.new File.new("lib/mccloud/templates/Mccloudfile.erb").read,nil,"%"
      mcPrefix="mccloud"
      providerId="AWS"
      mcEnvironment=select_environment
      mcIdentity=select_identity

      serverName=select_servername
      image_selection=select_image
      imageId=image_selection['imageId']
      userName=image_selection['userName']
      imageDescription=image_selection['imageDescription']
      availabilityZone=select_zone
      flavorId=select_flavor
      securityGroup=select_security_group

      keypair_selection=select_keypair
      keyName=keypair_selection['keyName']
      privateKeyPath=keypair_selection['privateKeyPath']
      publicKeyPath=keypair_selection['publicKeyPath']

      confirmed=false
      content=template.result(binding)
      if File.exists?("Mccloudfile")
        confirmed=agree("\nDo you want to overwrite your existing config?: ") { |q| q.default="no"}
      else
        confirmed=true
      end
      if confirmed
        puts
        puts "Writing your config file Mccloudfile"
        mccloudfile=File.new("Mccloudfile","w")
        mccloudfile.puts(content)
        mccloudfile.close
      else
        puts "Ok did not overwrite the config,  moving along"
      end  


      #Mccloud::Generators.run_cli Dir.pwd, File.basename(__FILE__), Mccloud::VERSION, init_options
    end

    private 

    def self.generate_key(comment=nil)
      keyset=SSHKey.generate(:comment => comment)
      return keyset
    end
    def self.select_image() 

      suggestions=[
        { "Name" => "Ubuntu 10.10 - Maverick 64-bit", "ImageId" => "ami-cef405a7", "UserName" => "ubuntu" },
      ]

      imageId=""
      userName="root"
      imageDescription=""

      choose do |menu|
        menu.index_suffix =") "
        menu.header="\Suggested image Ids"
        menu.default="1"
        menu.prompt="\nSelect the Image Id (aka AMI-ID on EC2): |1| "
        suggestions.each do |suggestion|
          menu.choice "#{suggestion['Name']} - #{suggestion['ImageId']}" do 
            imageId=suggestion['ImageId']
            userName=suggestion['UserName']
            imageDescription=suggestion['Name']
          end
        end
        menu.choice "Specify your own:" do
          imageId=ask("Image Id: ")
          userName=ask("Username to login: ")
          imageDescription=ask("Description: ")

        end

      end 

      return { "imageId"=>imageId,"userName" =>userName,"imageDescription" => imageDescription}

    end

    def self.select_identity() 

      puts "If you share the same cloud provider account, you can specify an identity"
      puts "to uniquely identify *your* servers (ex. firstname.lastname)"
      puts "Leave blank if unsure or working in a team "
      puts ""
      mcIdentity=ask("Identity: ")
      puts
      return mcIdentity

    end

    def self.select_servername() 

      puts "Provide an short name to identify your server (ex. web,db) "
      mcIdentity=ask("Servername: ") { |q| q.default="web"}
      puts
      return mcIdentity

    end

    def self.select_environment() 

      puts "Provide a name for the environment your are using (ex. development, test, demo)"
      mcEnvironment=ask("Environment: "){|q| q.default="development"}
      puts
      return mcEnvironment

    end


    def self.select_flavor()      
      flavorId="t1.micro"
      choose do |menu|
        menu.index_suffix =") "
        menu.header="\nAvailable machine flavors"
        menu.default="1"
        menu.prompt="\nSelect the flavor for your machine: |1| "
        @provider.flavors.each do |flavor|
          menu.choice "#{flavor.name} - #{flavor.id} - #{flavor.cores} core - #{flavor.disk} disk" do 
            flavorId=flavor.id
          end
        end
      end
      return flavorId

    end

    def self.select_security_group() 


      securityGroup="default"
      choose do |menu|
        menu.index_suffix =") "
        menu.header="\nAvailable security groups"
        menu.default="1"
        menu.prompt="\nSelect the security group for your machine: |1| "
        @provider.security_groups.each do |group|
          menu.choice "#{group.name} - #{group.description}" do 
            securityGroup=group.name
          end
        end
      end

      return securityGroup

    end

    def self.select_zone() 

      return "us-east-1b"

      zone="default"
      choose do |menu|
        menu.index_suffix =") "
        menu.header="\nAvailable zones"
        menu.default="1"
        menu.prompt="\nSelect the zone for your machine: |1| "
        @provider.describe_availability_zones.body["availabilityZoneInfo"].each do |region|
          menu.choice "#{region['zoneName']} - #{region['regionName']} - #{region['regionEndpoint']}" do 
            zone=region['zoneName']
          end
        end
      end

      return zone

    end

    def self.create_fog(provider='AWS')
      begin
        @provider=Fog::Compute.new(:provider => provider)
      rescue ArgumentError => e
        #  Missing required arguments: 
        required_string=e.message
        required_string["Missing required arguments: "]=""
        required_options=required_string.split(", ")
        puts "Please provide credentials for provider [#{provider}]:"
        answer=Hash.new
        for fog_option in required_options do 
          answer["#{fog_option}".to_sym]=ask("- #{fog_option}: ") 
          #{ |q| q.validate = /\A\d{5}(?:-?\d{4})?\Z/ }
        end
        puts "\nThe following snippet will be written to #{File.join(ENV['HOME'],".fog")}"

        snippet=":default:\n"
        for fog_option in required_options do
          snippet=snippet+"  :#{fog_option}: #{answer[fog_option.to_sym]}\n"
        end

        puts "======== snippit start ====="
        puts "#{snippet}"
        puts "======== snippit end ======="
        confirmed=agree("Do you wan to save this?: ")

        if (confirmed)
          fogfile=File.new("#{File.join(ENV['HOME'],".fog")}","w")
          fogfile.puts "#{snippet}"
          fogfile.close
        else
          #puts "Ok, we won't write it, but we continue with your credentials in memory"
          exit -1
        end
        begin
          answer[:provider]= provider
          @provider=Fog::Compute.new(answer)
        rescue
          puts "We tried to create the provider but failed again, sorry we give up"
          exit -1
        end
      end
    end

    def self.select_keypair() 


      valid_private_key=false
      valid_public_key=false
      private_key_path=""
      public_key_path=""

      keyName=nil
      choose do |menu|
        menu.index_suffix =") "
        menu.header="\nAvailable keypairs"
        menu.default="1"
        menu.prompt="\nSelect a keypair: |1| "

        menu.choice "Use/Generate a new (mccloud) keypair (RSA)" do

          private_key_path=File.join("#{ENV['HOME']}",".ssh","mccloud_rsa")
          public_key_path=File.join("#{ENV['HOME']}",".ssh","mccloud_rsa.pub")

          reuse=true
          if File.exists?(private_key_path)
            reuse=agree("\nReuse existing (mccloud) keypair?: ") { |q| q.default="yes"}
          end

          rsa_key=nil
          unless reuse
            keyName=ask("\nPlease enter a name for your new key: "){|q| q.default="mccloud-key-#{ENV['USER']}"}
            rsa_key=generate_key(keyName)
            File.open(public_key_path, 'w') {|f| f.write(rsa_key.ssh_public_key) }
            File.open(private_key_path, 'w') {|f| f.write(rsa_key.rsa_private_key) }

            provider_keypair=@provider.key_pairs.get(keyName)
            unless (provider_keypair.nil?)
              puts "Removing existing key with cloud provider"
              provider_keypair.destroy()                
            end
            provider_keypair=@provider.key_pairs.create(
            :name => keyName,
            :public_key => rsa_key.ssh_public_key )
            puts "Registered Key with cloud provider"

        else
          keyName=ask("\nPlease enter a name for your key: "){|q| q.default="mccloud-key-#{ENV['USER']}"}                           
        end

        valid_public_key=true
        valid_private_key=true
      end

      menu.choice "Provide your own keypair (RSA)" do
        keyName=nil
      end
      @provider.key_pairs.each do |keypair|
        menu.choice "#{keypair.name} - #{keypair.fingerprint}" do 
          keyName=keypair.name
        end
      end
    end


    if keyName.nil?
      puts "You selected to provide a custom keypair. Note that only RSA keys are supported"
      puts
      keyName=ask("Please enter a name for your custom key: (ex. ec2key-firstname.lastname) "){|q| q.default="mccloud-key-#{ENV['USER']}"}
    else
      valid_public_key=true
    end

    while (valid_private_key==false) do
      private_key_path=ask("Enter full path to private key: "){|q| q.default="#{File.join(ENV['HOME'],'.ssh','mccloud-id_rsa')}"}
      if File.exists?(private_key_path)
        valid_private_key=true
      else
        puts "#{private_key_path} does not exist"
      end
    end

    while (valid_public_key==false) do
      public_key_path=ask("Enter full path to public key: "){|q| q.default="#{File.join(ENV['HOME'],'.ssh','mccloud-id_rsa.pub')}"}
      if File.exists?(public_key_path)
        valid_public_key=true
      else
        puts "#{public_key_path} does not exist"
      end
    end              



    if private_key_path==""
      return {"keyName" => keyName,"privateKeyPath" => private_key_path}

    else
      return {"keyName" => keyName,"publicKeyPath" => public_key_path,"privateKeyPath" => private_key_path}
    end
  end

end
end
