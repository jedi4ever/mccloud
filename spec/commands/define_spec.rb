require 'mccloud'
require 'fileutils'
require 'tempfile'

describe "Define command" do

  before(:each) do
    @tempdir = Dir.mktmpdir
  end

  after(:each) do
    @env=nil
    FileUtils.remove_entry_secure @tempdir
  end

  context "Given a fresh mccloud project has been inited" do
    before do
      args=["init","bla"]
      env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => false)
      ::Mccloud::CLI.start(args,:env => env)
    end

    describe "When I run mccloud define ubuntu ubuntu-10" do
      before do
        args=["define","ubuntu","ubuntu-10.10-server-amd64"]
        env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => true)
        ::Mccloud::CLI.start(args,:env => env)
      end

      it "And the next time I load the environment it should have one definition" do
        env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => true)
        env.config.templates.length.should > 0
      end

      it "It should have a new definition directory called ubuntu" do
        File.directory?(File.join(@tempdir,"definitions","ubuntu")).should be_true
        File.exists?(File.join(@tempdir,"definitions","ubuntu","mccloud.rb")).should be_true
      end


      it "And the next time I load the environment it should have one definition" do
        env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => true)
        env.config.definitions.length.should == 1
      end

      it "And the default provider of the  definition is aws-us-east" do
        env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => true)
        env.config.definitions["ubuntu"].provider =~ /aws-us-east/
      end
    end
  end

  context "Given a fresh mccloud project and 1 definition ubuntu" do
    before do
      env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => false)
      args=["init","bla"]
      ::Mccloud::CLI.start(args,:env => env)
      env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => true)
      args=["define","ubuntu",'ubuntu-10.10-server-amd64']
      ::Mccloud::CLI.start(args,:env => env)
    end

    describe "When I run mccloud vm define ubuntu ubuntu" do

      before do
        env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => true)
        args=["vm","define",'ubuntu','ubuntu']
        ::Mccloud::CLI.start(args,:env => env)
      end

      it "It should have an ubuntu definition " do
        content=File.read(File.join(@tempdir,"definitions","ubuntu","mccloud.rb"))
        content.should =~ /ubuntu/
      end

      it "It should have a new vms directory" do
        File.directory?(File.join(@tempdir,"vms")).should be_true
      end

      it "It should have a new vm file ubuntu.rb" do
        File.exists?(File.join(@tempdir,"vms","ubuntu.rb")).should be_true
      end

      it "It should have exactly one vm defined" do
        env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => true)
        env.config.vms.length.should == 2
      end

      it "And the vm ubuntu should have username ubuntu" do
        env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => true)
        env.config.vms["ubuntu"].user.should == "ubuntu"
      end
    end
  end

end
