require 'mccloud/util/sshkey'

module Mccloud
  module Provider
    module Aws
      module ProviderCommand

        def keystore_sync(selection=nil,options=nil)

          env.config.keystores.each do |name,store|
            if store.keypairs.empty?
              env.ui.info "No Keypairs specified for keystore '#{name}'"
            else

              selected_keypairs=store.keypairs

              selected_keypairs.each do |defined_pair|
                keypair=env.config.keypairs[defined_pair[:keypair]]
                remote_name=defined_pair[:name]
                if keypair.nil?
                  env.ui.error "Keypair #{defined_pair[:keypair]} is not defined"
                else
                  name=keypair.name
                  begin
                    # Read key file
                    key=File.read(keypair.private_key_path)
                    fingerprint = ::Mccloud::Util::SSHKey.new(key).fingerprint

                    # Check if key already exists
                    existing_key=raw.key_pairs.get(remote_name)
                    if existing_key.nil?
                      # It does not exist, just create it
                      env.ui.info "Creating Remote Key #{remote_name}"
                      env.ui.info "- fingerprint #{fingerprint}"
                      raw.key_pairs.create(:name => remote_name, :fingerprint => fingerprint, :private_key => key)
                    else
                      if options.has_key?("overwrite")
                        # Exists but overwrite was specified
                        env.ui.info "Remote key '#{remote_name}' exists but --overwrite specified, removing key first"
                        existing_key.destroy
                        env.ui.info "Creating Remote Key #{remote_name}"
                        env.ui.info "- fingerprint #{fingerprint}"
                        raw.key_pairs.create(:name => defined_pair[:name], :fingerprint => fingerprint, :private_key => key)
                      else
                        # Exists but overwrite was NOT specified
                        env.ui.info "Remote Key '#{remote_name}' already exists. Use 'mccloud sync --overwrite'"
                      end
                    end
                  rescue Errno::ENOENT => ex
                    env.ui.error "Error: private_key_path does not exist : #{keypair.private_key_path}"
                  rescue Error => ex
                    env.ui.error "Error uploading key : #{ex}"
                  end
                end
              end
            end

          end
        end

      end
    end
  end

end
