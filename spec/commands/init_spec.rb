require 'mccloud'
require 'fileutils'
require 'tempfile'

describe "Init command" do

  before(:each) do
   @tempdir = Dir.mktmpdir
   @env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => false)
  end

  after(:each) do
    @env=nil
    FileUtils.remove_entry_secure @tempdir
  end

  it "When I run an mccloud init from an empty directory, it should create a new Mccloudfile" do
    args=["init"]
    ::Mccloud::CLI.start(args,:env => @env)
    File.exists?(File.join(@tempdir,"Mccloudfile")).should be_true
  end

  it "When I run an mccloud init in a directory that already has a Mccloudfile, it should error" do
    args=["init"]
    ::Mccloud::CLI.start(args,:env => @env)
    @env.ui.should_receive(:error).at_least(1).times.with(/already exists/)
    ::Mccloud::CLI.start(args,:env => @env)
  end

end
