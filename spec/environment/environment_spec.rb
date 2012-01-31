require 'mccloud'
require 'tempfile'

describe "Mccloud environment" do
  it "With a cwd passed, and no mccloudfile in any parentdir, the default would be currentdir" do
    tempdir = Dir.mktmpdir
    begin
      env=Mccloud::Environment.new(:cwd => tempdir)
      Pathname(env.root_path).dirname.realpath.should == Pathname(tempdir).dirname.realpath
    ensure
      FileUtils.remove_entry_secure tempdir
    end
  end

  it "With a cwd passed, and a mccloudfile in it, the default would be currentdir" do
    tempdir = Dir.mktmpdir
    FileUtils.touch(File.join(tempdir,"Mccloudfile"))
    begin
      env=Mccloud::Environment.new(:cwd => tempdir)
      Pathname(env.root_path).dirname.realpath.should == Pathname(tempdir).dirname.realpath
    ensure
      FileUtils.remove_entry_secure tempdir
    end
  end

end
