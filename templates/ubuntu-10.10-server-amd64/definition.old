# Canonical
# http://uec-images.ubuntu.com/releases/10.04/release/
# http://jonathanhui.com/create-and-launch-amazon-ec2-instance-ubuntu-and-centos

aws_templates=[
  { :name => "aws-us-east::ubuntu-10.10-64",
    :description => "Ubuntu 10.10 - Maverick 64-bit (Canonical/EBS)",
    :provider => "aws-us-east",
    :ami => "ami-cef405a7", :user => "ubuntu" ,:arch => "64",
    :zone => "us-east-1a",
    :bootstrap => [ "bootstrap-ubunty.sh"]},
  { :name => "aws-us-east::ubuntu-10.10-32",
    :description => "Ubuntu 10.10 - Maverick 32-bit (Canonical/EBS)",
    :ami => "ami-ccf405a5", :user => "ubuntu" ,:arch => "32",
    :provider => "aws-us-east",
    :zone => "us-east-1a",
    :bootstrap => ""},
  { :name => "aws-us-east::ubuntu-10.04-64",
    :description => "Ubuntu 10.04 - Lucid 64-bit (Canonical/EBS)",
    :ami => "ami-3202f25b", :user => "ubuntu" ,:arch => "64",
    :provider => "aws-us-east",
    :zone => "us-east-1a",
    :bootstrap => "" },
  { :name => "aws-us-east::ubuntu-10.04-32",
    :description => "Ubuntu 10.04 - Lucid 32-bit (Canonical/EBS)",
    :ami => "ami-3e02f257", :user => "ubuntu" ,:arch => "32",
    :provider => "aws-us-east",
    :zone => "us-east-1a",
    :bootstrap => "" },
  { :name => "aws-us-east::centos-5.4-64",
    :description => "Centos 5.4 - 64-bit (Rightscale/EBS)",
    :ami => "ami-4d42a924", :user => "root" ,:arch => "64",
    :provider => "aws-us-east",
    :zone => "us-east-1a",
    :bootstrap => "" },
  { :name => "aws-us-east::centos-5.4-32",
    :description => "Centos 5.4 - 32-bit (Rightscale/EBS)",
    :ami => "ami-2342a94a", :user => "root" ,:arch => "32",
    :provider => "aws-us-east",
    :zone => "us-east-1a",
    :bootstrap => "" }
]

aws_templates.each do |template|
  config.template.define "#{template[:name]}" do |template_config|
    template_config.template.name=template[:name]
    template_config.template.params=template
    template_config.template.file=File.join(".","aws.erb")
    template_config.template.bootstrap="#{template[:bootstrap]}"
  end
end
