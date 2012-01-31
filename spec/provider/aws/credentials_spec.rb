require 'mccloud'
require 'fileutils'
require 'tempfile'
require 'mccloud/provider/aws/provider'

describe "AWS provider" do

  before(:each) do
   @tempdir = Dir.mktmpdir
   @env=Mccloud::Environment.new(:cwd => @tempdir,:autoload => false)
  end

  after(:each) do
    @env=nil
    FileUtils.remove_entry_secure @tempdir
  end

  it "When there are no credentials, accessing the raw provider should be missing credentials" do
    p=::Mccloud::Provider::Aws::Provider.new("aws-bla",{},@env)
    p.credentials_path=File.join(@tempdir,".fog")
    expect {
      raw=p.raw
    }.to raise_error(Mccloud::Error)
  end

  it "When there are credentials, accessing the raw provider should be ok" do
    p=::Mccloud::Provider::Aws::Provider.new("aws-bla",{},@env)
    credentials={:default => {:aws_access_key_id => "1223454",
                 :aws_secret_access_key => "123456"}}
    p.credentials_path=File.join(@tempdir,".fog")
    File.open(p.credentials_path,'w') {|f| f.write(credentials.to_yaml)}
    expect {
      raw=p.raw
    }.to_not raise_error(Mccloud::Error)
  end

end
