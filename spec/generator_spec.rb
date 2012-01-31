require 'mccloud'
require 'fileutils'
require 'tempfile'
require 'mccloud/generator'

describe "Generator" do

  before(:each) do
   @tempdir = Dir.mktmpdir
   @env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => false)
   @env.ssh_key_path=@tempdir
  end

  after(:each) do
    @env=nil
    FileUtils.remove_entry_secure @tempdir
  end

  it "When I specify an unknown provider it should generate an error" do
    expect {
    @env.generator.generate({:provider => :blabla})
    }.to raise_error(::Mccloud::Error)
  end

  it "When I specify no provider it should default to aws" do
    @env.generator.generate()
    File.exists?(@env.mccloud_file).should be_true
  end

end
