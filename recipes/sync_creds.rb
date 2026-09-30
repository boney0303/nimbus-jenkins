# Cookbook:: nimbus-jenkins
# Recipe:: sync_creds
# Description: sync AWS secrets into Jenkins credentials

# load secrets from AWS
include_recipe 'nimbus-jenkins::_secrets'

# install jenkins and setup service
include_recipe 'nimbus-jenkins::_service'

# setup bootstrap files for auto-config
include_recipe 'nimbus-jenkins::_mbj'
include_recipe 'nimbus-jenkins::_casc'

# restart jenkins
execute 'systemctl-restart' do
  command 'systemctl restart jenkins'
end
