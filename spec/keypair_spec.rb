require 'mccloud'
require 'fileutils'
require 'tempfile'
require 'mccloud/keypair'

describe "Keypair" do

  before(:each) do
   @tempdir = Dir.mktmpdir
   @env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => false)
   @env.ssh_key_path=@tempdir
  end

  after(:each) do
    @env=nil
    FileUtils.remove_entry_secure @tempdir
  end

  it "When I generate a non-existing pair, the public and private key should be created" do
    k=::Mccloud::Keypair.new("mccloud",@env)
    k.generate
    File.exists?(File.join(@env.ssh_key_path,"mccloud_rsa.pub")).should == true
    File.exists?(File.join(@env.ssh_key_path,"mccloud_rsa")).should == true
  end

  it "When I generate a existing pair, there should be an error" do
    k=::Mccloud::Keypair.new("mccloud",@env)
    k.generate
    expect { k.generate }.to raise_error(Mccloud::Error)
  end

  it "When I generate a existing pair,and I force the creation there should be no error" do
    k=::Mccloud::Keypair.new("mccloud",@env)
    k.generate
    expect { k.generate({:force => true}) }.to_not raise_error(Mccloud::Error)
  end

end
