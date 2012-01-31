guard :rspec, :version => 2, :cli => "--color --format documentation" do
  watch(%r{spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})         { "spec" }
  #watch(%r{^lib/(.+)\.rb$})         { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{spec/spec_helper\.rb$}) { "spec" }
end

guard :cucumber, :cli => "-s" do
  watch(%r{lib/(.+)\.rb$}) { "features" }
end
