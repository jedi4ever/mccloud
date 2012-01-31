require 'mccloud'
require 'mccloud/provisioner/puppet'
require 'tempfile'

# Without a cwd passed, and no mccloudfile in any parentdir
# The default would be currentdir "."
#describe ::Mccloud::Provisioner::Puppet, "#apply" do
describe "Provisioner puppet" do
  def default_config(env)
    #    Dynamically creating the vm
    #    @env.load!
    env.config.define do |config|
      config.provider.define "aws-us-east" do |provider_config|
        provider_config.provider.flavor = :aws
        provider_config.provider.region = "us-east-1"
        provider_config.provider.credentials_path=File.join(@tempdir,".fog")
      end

      config.keypair.define "mccloud" do |key_config|
        key_config.keypair.public_key_path = "#{File.join(ENV['HOME'],'.ssh','mccloud_rsa.pub')}"
        key_config.keypair.private_key_path = "#{File.join(ENV['HOME'],'.ssh','mccloud_rsa')}"
      end

      config.keystore.define "aws-us-east-key-store" do |keystore_config|
        keystore_config.keystore.provider = "aws-us-east"
        keystore_config.keystore.keypairs = [
          { :name => "mccloud", :keypair => "mccloud"},
        ]
      end

    end
  end

  def fake_credentials(env)
    credentials={:default => {:aws_access_key_id => "1234567",
                              :aws_secret_access_key => "1234567"}}
    File.open(File.join(@tempdir,".fog"),'w') { |f| f.write(credentials.to_yaml)}
  end

  def default_puppet(env)
    env.config.define do |config|
      config.vm.define "puppet" do |vm_config|
        vm_config.vm.provider = "aws-us-east"
        vm_config.vm.provision :puppet do |puppet|
          puppet.module_path = ["modules"]
        end
      end
    end
  end

  before(:each) do
    @tempdir=Dir.mktmpdir
    @env=Mccloud::Environment.new(
      :cwd => File.dirname(__FILE__),
      :autoload => false
    )

    fake_credentials(@env)
    default_config(@env)
    default_puppet(@env)

    # Fog will get loaded because of aws
    Fog.mock!
    #@env.config.providers["aws-us-east"].keystore_sync

    @vm=@env.config.vms["puppet"]
    ::Mccloud::Util::Ssh.stub(:execute_when_tcp_available).and_return(true)
    @vm.stub!(:share_folder).and_return(nil)
    @vm.stub!(:transfer).and_return(nil)
    @vm.stub!(:execute).and_return(nil)
    @vm.stub!(:sudo).and_return(nil)
  end

  after(:each) do
    Fog::Mock.reset
    FileUtils.remove_entry_secure @tempdir
    @env=nil
    @vm=nil
  end

  it "When the machine is up, and no manifest is specified puppet should not run" do
    expect {
      @vm.up
      @vm._provision
    }.should raise_error
  end

  it "When the machine is up, puppet should run fine and has a valid manifest" do
    @vm.provisioner.manifest_file="bla.sh"
    @vm.up
    @vm.should_receive(:share_folder).at_least(1).times
    @vm.should_receive(:sudo).at_least(1).times.with(/puppet apply/)
    @vm._provision
  end

  it "When the machine is down, running the provision should throw an error" do
    expect {
      @vm._provision
    }.should raise_error
  end

  it "When 1 module path and 1 manifest path are given, it should share 2 folders" do
    @vm.provisioners.first.manifest_file="bla.sh"
    @vm.up
    # We need to count from here as 'upi', also does a provision on first run
    @vm.should_receive(:share_folder).exactly(2).times
    @vm._provision
  end

end
