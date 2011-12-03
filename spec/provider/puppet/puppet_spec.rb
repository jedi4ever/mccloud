require 'mccloud'
require 'mccloud/provisioner/puppet'

# Without a cwd passed, and no mccloudfile in any parentdir
# The default would be currentdir "."
#describe ::Mccloud::Provisioner::Puppet, "#apply" do
describe "Provisioner puppet" do
  before(:each) do
      @env=Mccloud::Environment.new(
        :cwd => File.dirname(__FILE__),
        :mccloud_file => "Mccloud-puppet-test"
      )
      @env.load!
      Fog.mock!
      @env.config.providers["aws-us-east"].keystore_sync
      @vm=@env.config.vms["puppet"]
      ::Mccloud::Util::Ssh.stub(:execute_when_tcp_available).and_return(true)
      @vm.stub!(:share_folder).and_return(nil)
      @vm.stub!(:transfer).and_return(nil)
      @vm.stub!(:execute).and_return(nil)
      @vm.stub!(:sudo).and_return(nil)
  end

  after(:each) do
     Fog::Mock.reset
     @env=nil
     @vm=nil
  end

  it "When the machine is up, puppet should run fine" do
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
      @vm.up
      # We need to count from here as 'upi', also does a provision on first run
      @vm.should_receive(:share_folder).exactly(2).times
      @vm._provision
  end

end
