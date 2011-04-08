#require 'mccloud/generators'
require 'highline/import'
require 'mccloud/util/sshkey'

require 'erb'

module Mccloud
  module Command
    include Mccloud::Util
    def self.init(amiId=nil,options=nil)
      
      trap("INT") { puts
        puts ""; exit }
      
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
      
      #strip all 
      serverName.gsub!(/[^[:alnum:]]/, '_') 
      
      image_selection=select_image
      imageId=image_selection['imageId']
      userName=image_selection['userName']
      imageDescription=image_selection['imageDescription']
      arch=image_selection['arch']
      
      full_bootstrapScript=image_selection['bootstrap']
      copy_bootstrap(full_bootstrapScript)
      bootstrapScript=File.basename("#{full_bootstrapScript}")

      availabilityZone=select_zone
      flavorId=select_flavor(arch)

      fullIdentity=Array.new
       if !mcPrefix.nil? 
          fullIdentity << mcPrefix 
       end
       if mcEnvironment!="" 
          fullIdentity << mcEnvironment
       end
       if mcIdentity!=""
          fullIdentity << mcIdentity 
       end
       full_identity=fullIdentity.join("-")
      
      securityGroup=select_security_group(full_identity)

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

    def self.copy_bootstrap(filename=nil)
      
      unless filename.nil?
     
        FileUtils.cp(filename,File.basename(filename))
        puts "Copied bootstrap - #{File.basename(filename)} to your current directory"
      end
    end

    def self.generate_key(comment=nil)
      keyset=SSHKey.generate(:comment => comment)
      return keyset
    end
    def self.select_image() 

      # Canonical 
      # http://uec-images.ubuntu.com/releases/10.04/release/
      # http://jonathanhui.com/create-and-launch-amazon-ec2-instance-ubuntu-and-centos
      
      suggestions=[
        { "Name" => "Ubuntu 10.10 - Maverick 64-bit (Canonical/EBS)", "ImageId" => "ami-cef405a7", 
          "UserName" => "ubuntu" ,"Arch" => "64", "Bootstraps" =>
          [ {"Description" => "Ruby via standard .deb packages + rubygems from source + (chef,puppet) as gems", "Filename" => "bootstrap-ubuntu-system.sh"},
            {"Description" => "Ruby 1.8.7 via rvm + (chef,puppet) as gems", "Filename" =>  "bootstrap-ubuntu-rvm-1.8.7.sh"},
             {"Description" => "Empty bootstrap you can customize", "Filename" =>  "bootstrap-custom.sh"},
            ]
        },
        { "Name" => "Ubuntu 10.10 - Maverick 32-bit (Canonical/EBS)", "ImageId" => "ami-ccf405a5",
           "UserName" => "ubuntu" ,"Arch" => "32",  "Bootstraps" =>
           [ {"Description" => "Ruby via standard .deb packages + rubygems from source + (chef,puppet) as gems",  "Filename" => "bootstrap-ubuntu-system.sh"},
             {"Description" => "Ruby 1.8.7 via rvm + (chef,puppet) as gems",  "Filename" => "bootstrap-ubuntu-rvm-1.8.7.sh"},
             {"Description" => "Empty bootstrap you can customize", "Filename" =>  "bootstrap-custom.sh"},

             ]},
        { "Name" => "Ubuntu 10.04 - Lucid 64-bit (Canonical/EBS)", "ImageId" => "ami-3202f25b",
           "UserName" => "ubuntu" ,"Arch" => "64",  "Bootstraps" =>
           [ {"Description" => "Ruby via standard .deb packages + rubygems from source + (chef,puppet) as gems",  "Filename" => "bootstrap-ubuntu-system.sh"},
             {"Description" => "Ruby 1.8.7 via rvm + (chef,puppet) as gems",  "Filename" => "bootstrap-ubuntu-rvm-1.8.7.sh"},
             {"Description" => "Empty bootstrap you can customize", "Filename" =>  "bootstrap-custom.sh"},

             ]},
        { "Name" => "Ubuntu 10.04 - Lucid 32-bit (Canonical/EBS)", "ImageId" => "ami-3e02f257", 
          "UserName" => "ubuntu" ,"Arch" => "32",  "Bootstraps" =>
          [ {"Description" => "Ruby via standard .deb packages + rubygems from source + (chef,puppet) as gems",  "Filename" => "bootstrap-ubuntu-system.sh"},
            {"Description" => "Ruby 1.8.7 via rvm + (chef,puppet) as gems",  "Filename" => "bootstrap-ubuntu-rvm-1.8.7.sh"},
            {"Description" => "Empty bootstrap you can customize", "Filename" =>  "bootstrap-custom.sh"},

            ]},
        { "Name" => "Centos 5.4 - 64-bit (Rightscale/EBS)", "ImageId" => "ami-4d42a924", 
          "UserName" => "root" ,"Arch" => "64",  "Bootstraps" =>
          [ {"Description" => "Ruby 1.8.7 from source + (chef,puppet) as gems",  "Filename" => "bootstrap-centos-rubysource-1.8.7.sh"},
            {"Description" => "Ruby 1.8.7 via rvm + (chef,puppet) as gems",  "Filename" => "bootstrap-centos-rvm-1.8.7.sh"},
            {"Description" => "Ruby REE 1.8.7 via rvm + (chef,puppet) as gems", "Filename" =>  "bootstrap-centos-rvm-ree-1.8.7.sh"},

            {"Description" => "Ruby 1.9.2 via rvm + (chef,puppet) as gems",  "Filename" => "bootstrap-centos-rvm-1.9.2.sh"},
            {"Description" => "Empty bootstrap you can customize", "Filename" =>  "bootstrap-custom.sh"},

            ]},
        { "Name" => "Centos 5.4 - 32-bit (Rightscale/EBS)", "ImageId" => "ami-2342a94a", 
          "UserName" => "root" ,"Arch" => "32", "Bootstraps" =>
          [ {"Description" => "Ruby 1.8.7 from source + (chef,puppet) as gems",  "Filename" => "bootstrap-centos-rubysource-1.8.7.sh"},
            {"Description" => "Ruby 1.8.7 via rvm + (chef,puppet) as gems",  "Filename" => "bootstrap-centos-rvm-1.8.7.sh"},
            {"Description" => "Ruby REE 1.8.7 via rvm + (chef,puppet) as gems", "Filename" =>  "bootstrap-centos-rvm-ree-1.8.7.sh"},

            {"Description" => "Ruby 1.9.2 via rvm + (chef,puppet) as gems",  "Filename" => "bootstrap-centos-rvm-1.9.2.sh"},
            {"Description" => "Empty bootstrap you can customize", "Filename" =>  "bootstrap-custom.sh"},

            ]},
  
      ]

      imageId=""
      userName="root"
      imageDescription=""
      arch="0"
      bootstrap=""

      choose do |menu|
        menu.index_suffix =") "
        menu.header="\nSuggested image Ids"
        menu.default="1"
        menu.prompt="\nSelect the Image Id (aka AMI-ID on EC2): |1| "
        suggestions.each do |suggestion|
          menu.choice "#{suggestion['Name']} - #{suggestion['ImageId']}" do 
            imageId=suggestion['ImageId']
            userName=suggestion['UserName']
            imageDescription=suggestion['Name']
            arch=suggestion['Arch']       
            
            choose do |bootstrap_menu|
              bootstrap_menu.index_suffix =") "
              bootstrap_menu.header="\nSuggested bootstraps"
              bootstrap_menu.default="1"
              bootstrap_menu.prompt="\nSelect the Image Id (aka AMI-ID on EC2): |1| "
              suggestion["Bootstraps"].each do |bootstrap_file|
                bootstrap_menu.choice "#{bootstrap_file['Description']}" do 
                  bootstrap=File.expand_path(File.join(File.dirname(__FILE__),'..','templates',"#{bootstrap_file["Filename"]}"))                  
                end
              end
            end
            
          end
        end
        menu.choice "Specify your own:" do
          imageId=ask("Image Id: ")
          userName=ask("Username to login: ")
          imageDescription=ask("Description: ")
          arch=ask("Architecture (32,64): "){|q| q.default="64"}
          bootstrap=ask("Path to Bootstrap script: ")
        end

      end 

      return { "imageId"=>imageId,"userName" =>userName,"imageDescription" => imageDescription,"arch" => arch,"bootstrap" => bootstrap}

    end

    def self.select_identity() 

      puts "If you share the same cloud provider account, you can specify an identity"
      puts "to uniquely identify *your* servers (ex. firstname.lastname)"
      puts "Leave blank if you want to work in a team "
      puts ""
      mcIdentity=ask("Identity: ") {|q| q.default="#{ENV['USER']}"}
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


    def self.select_flavor(filter=nil)      
      flavorId="t1.micro"
      choose do |menu|
        menu.index_suffix =") "
        menu.header="\nAvailable machine flavors"
        menu.default="1"
        menu.prompt="\nSelect the flavor for your machine: |1| "
        @provider.flavors.each do |flavor|
          if "#{flavor.bits}"==filter || "#{flavor.bits}"=="0"
            menu.choice "#{flavor.name} - #{flavor.id} - #{flavor.cores} cores" do 
              flavorId=flavor.id
            end
          end
        end
      end
      return flavorId

    end

    def self.select_security_group(identity=nil) 

      securityGroup="default"
      choose do |menu|
        menu.index_suffix =") "
        menu.header="\nAvailable security groups"
        menu.default="1"
        menu.prompt="\nSelect the security group for your machine: |1| "
        
        mcgroup=@provider.security_groups.get("#{identity}-securitygroup")
        if mcgroup.nil?
          menu.choice "[Create new] #{identity}-securitygroup" do 
            sg=@provider.security_groups.new
            sg.name="#{identity}-securitygroup"
            sg.description="#{identity}-securitygroup"
            sg.save
            
            puts "Authorizing access to port 22"
            sg.authorize_port_range(22..22)

            securityGroup="#{identity}-securitygroup"
          end
        else
          menu.choice "#{identity}-securitygroup" do 
            securityGroup="#{identity}-securitygroup"
          end
        end
          
        @provider.security_groups.each do |group|
          unless "#{group.name}"=="#{identity}-securitygroup"
            menu.choice "#{group.name} - #{group.description}" do 
              puts "Make sure this security group has ssh/port 22 enabled\n"
              securityGroup=group.name
            end
          end
        end
      end

      # We should check to see if 22 is enabled for that zone
      #(AWS.security_groups.get("JMETER").ip_permissions[0]["fromPort"]..AWS.security_groups.get("JMETER").ip_permissions[0]["toPort"]) === 22
      # make sure port 22 is open in the first security group
      #    security_group = connection.security_groups.get(server.groups.first)
      #    authorized = security_group.ip_permissions.detect do |ip_permission|
      #      ip_permission['ipRanges'].first && ip_permission['ipRanges'].first['cidrIp'] == '0.0.0.0/0' &&
      #      ip_permission['fromPort'] == 22 &&
      #      ip_permission['ipProtocol'] == 'tcp' &&
      #      ip_permission['toPort'] == 22
      #    end
      #    unless authorized
      #      security_group.authorize_port_range(22..22)
      #    end
      return securityGroup

    end

    def self.select_zone() 


      zone="default"
      
      choose do |menu|
        menu.index_suffix =") "
        menu.header="\nAvailable zones"
        menu.default="us-east-1b"
        menu.prompt="\nSelect the zone for your machine: |#{menu.default}| "

        @provider.describe_availability_zones.body["availabilityZoneInfo"].each do |region|
          menu.choice "#{region['zoneName']} - #{region['regionName']}" do 
            zone=region['zoneName']
          end
        end

        [ {"zoneName" => "eu-west-1a", "regionName" => "eu-west-1"}, {"zoneName" => "eu-west-1b", "regionName" => "eu-west-1"}].each do |region|
          menu.choice "#{region['zoneName']} - #{region['regionName']}" do 
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
        confirmed=agree("Do you want to save this?: ") {|q| q.default="yes"}
        puts

        if (confirmed)
          fogfile=File.new("#{File.join(ENV['HOME'],".fog")}","w")
           FileUtils.chmod(0600,fogfile)
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

          if File.exists?(private_key_path)
            reuse=agree("\nReuse existing (mccloud) keypair?: ") { |q| q.default="yes"}
          else
            reuse=false
          end

          rsa_key=nil
          unless reuse
            keyName=ask("\nPlease enter a name for your new key: "){|q| q.default="mccloud-key-#{ENV['USER']}"}
            rsa_key=generate_key(keyName)

            unless File.exists?(File.dirname(public_key_path))
              puts "Creating directory #{File.dirname(public_key_path)}"
              FileUtils.mkdir_p(File.dirname(public_key_path))
              FileUtils.chmod(0700,File.dirname(public_key_path))
            end

            unless File.exists?(File.dirname(private_key_path))
              puts "Creating directory #{File.dirname(private_key_path)}"

              FileUtils.mkdir_p(File.dirname(private_key_path))
              FileUtils.chmod(0700,File.dirname(private_key_path))
            end


            File.open(public_key_path, 'w') {|f| f.write(rsa_key.ssh_public_key) }
            File.open(private_key_path, 'w') {|f| f.write(rsa_key.rsa_private_key) }
            FileUtils.chmod(0600,private_key_path)
            FileUtils.chmod(0600,public_key_path)

            puts 
            puts "Created a new public key in #{public_key_path}"
            puts "Created a new private key in #{private_key_path}"
            puts "I suggest you backup these later."
            puts

            provider_keypair=@provider.key_pairs.get(keyName)
            unless (provider_keypair.nil?)
              puts "Updating your existing key #{keyName} with cloud provider"
              provider_keypair.destroy()                
            end
            provider_keypair=@provider.key_pairs.create(
            :name => keyName,
            :public_key => rsa_key.ssh_public_key )
            puts "Registered #{keyName} with your cloud provider"

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
