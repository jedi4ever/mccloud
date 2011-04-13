require 'open-uri'
require 'json'

module Mccloud
  module Type
    
  class Stack
    attr_accessor :name
    attr_accessor :params    
    attr_accessor :provider
    attr_accessor :provider_options
    attr_accessor :create_options
    attr_accessor :jsonfile
    attr_accessor :instance
    attr_accessor :rewrite_names
    
    attr_accessor :user
    attr_accessor :private_key
    attr_accessor :public_key
    attr_accessor :key_name
    attr_accessor :userdata_file

    
    def initialize
#      @forwardings=Array.new
       @rewrite_names=true
       @user=Hash.new
       @private_key=Hash.new
       @public_key=Hash.new
       @userdata_file=Hash.new
       @key_name=Hash.new
       @provider_options={:region => "us-east-1"}
    end
    
    def private_key_for_instance(machinename)
      default_private_key=private_key[:default]
      if private_key[machinename].nil?
        return default_private_key
      else
        return private_key[machinename]
      end
    end

    def public_key_for_instance(machinename)
      default_public_key=public_key[:default]
      if public_key[machinename].nil?
        return default_public_key
      else
        return public_key[machinename]
      end
    end

    def user_for_instance(machinename)
      default_user=user[:default]
      if user[machinename].nil?
        return default_user
      else
        return user[machinename]
      end
    end
    
    def key_name_for_instance(machinename)
      default_key_name=key_name[:default]
      if key_name[machinename].nil?
        return default_key_name
      else
        return key_name[machinename]
      end
    end

    def userdata_file_for_instance(machinename)
      default_userdata_file=userdata_file[:default]
      if userdata_file[machinename].nil?
        return default_userdata_file
      else
        return userdata_file[machinename]
      end
    end
    
    def instance
#      if @this_instance.nil?
#        begin
#          @this_instance=Mccloud.session.config.providers[provider].servers.get(Mccloud.session.all_servers[name.to_s])
#        rescue Fog::Service::Error => e
#          puts "Error: #{e.message}"
#          puts "We could not request the information from your provider #{provider}. We suggest you check your credentials."
#          puts "Check configuration file: #{File.join(ENV['HOME'],".fog")}"
#          exit -1
#        end
#      end
#      return @this_instance
    end
    
    def json_rewrite
      hash=self.json_to_hash
      unknown_counter=1
      # First rewrite the Name Tags
      hash["Resources"].each do  |name,resource|
              
              if resource["Type"]=="AWS::EC2::Instance"
                foundName=false
                foundKeyName=false
                instance_name=""

                rewrittenTags=Array.new
                 
                 # Loop over each hash 
                 hash["Resources"][name]["Properties"]["Tags"].each do |tag_hash|
                  
                  new_tag_hash=tag_hash
                  
                  # If we found the Name tag rewrite it
                   if tag_hash["Key"]="Name"
                     # Need to rewrite name
                     new_tag_hash={"Value"=>"#{Mccloud.session.config.mccloud.filter}#{tag_hash["Value"]}", "Key"=>"Name"}
                     instance_name="#{tag_hash["Value"]}"
                     foundName=true
                   end

                   #if tag_hash["Key"]="KeyName"
                  #   foundKeyName=true
                   #end
                   
                   rewrittenTags << new_tag_hash
                   
                end #Hash Tags iteration
                unless foundName
                  rewrittenTags << {"Value"=>"#{Mccloud.session.config.mccloud.filter}noname-#{unkown_counter}", "Key"=>"Name"}
                  instance_name="noname-#{unkown_counter}"
                  unknown_counter=unknown_counter+1
                end

                hash["Resources"][name]["Properties"]["Tags"]=rewrittenTags

                unless hash["Resources"][name]["Properties"].has_key?("UserData")
                  puts "merging in Userdata file for server #{instance_name} - #{self.userdata_file_for_instance(instance_name)}"
                  userdata=json_escape_file(self.userdata_file_for_instance(instance_name))
                  hash["Resources"][name]["Properties"]["UserData"]={ "Fn::Base64" => "#{userdata}" }
                end
                                
              end #EC2 Instance
      end  
      
      
      return hash.to_json    
    end
    
    def json_escape_file(filename)
      data=''
        File.open(filename) {|f| data << f.read}
        return self.json_escape(data)
    end

    
    
    def json_escape(string)
      parse = JSON.parse({ 'json' => string }.to_json)
      return parse['json']
    end
    
    
    def json
      begin
        json=open(@jsonfile) {|f| f.read }
        hash=JSON.parse(json)
      rescue Errno::ENOENT => e
        puts "Error getting json file -  #{e.message}"
        exit
      rescue JSON::ParserError => e
        puts "Error parsing json file -  #{e.message}"
        exit
      end
      return json
    end
    
    def exists?
      false
    end
    
    def json_to_hash
      hash=nil
      begin
        hash=JSON.parse(self.json)
      rescue JSON::ParserError => e
        puts "Error parsing json file -  #{e.message}"
        exit
      end
      return hash
    end

    def filtered_instance_names
      fullname_instances=self.instance_names
      short_instances=[]
      filter=Mccloud.session.config.mccloud.filter
      fullname_instances.each do |instancename|
        if instancename.start_with?(filter)
          short=instancename
          short[filter]=""
          short_instances << short
        end
      end
      return short_instances 
    end
    

    def instance_names
      hash=self.json_to_hash

      instances=[]
      resources=hash["Resources"]
      resources.each do  |name,resource|
             
              if resource["Type"]=="AWS::EC2::Instance"
                
                resources[name]["Properties"]["Tags"].each do |tag|

                  if tag["Key"]=="Name"
                    instances << tag["Value"]
                  end
                end
#                instances << hash["Resources"][name]["Properties"]["Tags"]
#                      hash["Resources"][name]["Properties"]["Tags"]=[{"Value"=>"mccloud - development - patrick - drupalblub", "Key"=>"Name"}]
            else
               # puts "found something else"
              end
      end
      return instances
    end
    
    def reload
      #@this_instance=nil
    end
    def forward_port(name,local,remote)
      #forwarding=Forwarding.new(name,local,remote)
      #forwardings << forwarding
    end
  end
  
end
end #Module Mccloud