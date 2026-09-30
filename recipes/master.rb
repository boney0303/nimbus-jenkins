# Cookbook:: nimbus-jenkins
# Recipe:: master
#

# configure repos
include_recipe 'nimbus-jenkins::_yum'

# install needed software
include_recipe 'nimbus-jenkins::_software'

# load secrets from AWS
include_recipe 'nimbus-jenkins::_secrets'

# install jenkins and setup service
include_recipe 'nimbus-jenkins::_service'

# misc system settings - must go before docker
include_recipe 'nimbus-jenkins::_system'

# install docker
include_recipe 'nimbus-jenkins::_docker' unless node['test-kitchen']

# install Jenkins plugins
include_recipe 'nimbus-jenkins::_plugins'

# setup bootstrap files for auto-config
include_recipe 'nimbus-jenkins::_mbj'
include_recipe 'nimbus-jenkins::_casc'

# install options if enabled
include_recipe 'nimbus-jenkins::_support_extras' if node['nimbus-jenkins']['master']['support_extras']
include_recipe 'nimbus-jenkins::_support_blitz' if node['nimbus-jenkins']['master']['support_blitz']
include_recipe 'nimbus-jenkins::_support_sreops' if node['nimbus-jenkins']['master']['support_sreops']
include_recipe 'nimbus-jenkins::_ec2_cloud' if node['ec2'] && node['ec2']['region']
