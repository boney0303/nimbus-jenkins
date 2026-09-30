# Cookbook:: nimbus-jenkins
# Recipe:: worker
#

# configure repos
include_recipe 'nimbus-jenkins::_yum'

# install needed software
include_recipe 'nimbus-jenkins::_software'

# load secrets from AWS
include_recipe 'nimbus-jenkins::_secrets'

# create worker group
group node['nimbus-jenkins']['group'] do
  group_name node['nimbus-jenkins']['group']
  action :create
end

# create worker user
user node['nimbus-jenkins']['user'] do
  comment 'jenkins worker-node user'
  group node['nimbus-jenkins']['group']
  home node['nimbus-jenkins']['home']
  shell '/bin/bash'
  manage_home true
end

# create worker home directory
directory node['nimbus-jenkins']['home'] do
  owner     node['nimbus-jenkins']['user']
  group     node['nimbus-jenkins']['group']
  mode      '0700'
  recursive true
end

# install docker
include_recipe 'nimbus-jenkins::_docker' unless node['test-kitchen']

# provide iptables resources
include_recipe 'nimbus-iptables'

# set iptables to allow jenkins access
iptables_open_port 22

# create ssh directory
directory node['nimbus-jenkins']['home'] + '/.ssh' do
  action :create
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0700'
end

# save all public keys to authorized_keys if 'dot_ssh_filename' is provided
# we only want the public key to write into the /var/lib/jenkins/.ssh/authorized_keys file
node['nimbus-jenkins']['mbj_data']['credentials']['text'].each do |credential|
  next unless credential['dot_ssh_filename'] # only create if given filename
  next if node.run_state[credential['jenkins_credentials_id']].nil? # skip empty secrets
  file "#{node['nimbus-jenkins']['home']}/.ssh/#{credential['dot_ssh_filename']}" do
    owner node['nimbus-jenkins']['user']
    group node['nimbus-jenkins']['group']
    mode '0600'
    content lazy { node.run_state[credential['jenkins_credentials_id']] }
  end
end unless node['test-kitchen']

# add jenkins to sudo so jenkins master can access and manage worker
file '/etc/sudoers.d/jenkins' do
  mode '0600'
  content '%jenkins  ALL=(ALL) NOPASSWD:ALL'
end
