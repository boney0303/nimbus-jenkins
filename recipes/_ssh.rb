# Cookbook:: nimbus-jenkins
# Recipe:: _ssh
#

# create ssh directory
directory node['nimbus-jenkins']['home'] + '/.ssh' do
  action :create
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0700'
end

# save all keys locally if 'dot_ssh_filename' is provided
ssh_files = []
node['nimbus-jenkins']['mbj_data']['credentials']['sshkey'].each do |credential|
  next unless credential['dot_ssh_filename'] # only create if given filename
  next if node.run_state[credential['jenkins_credentials_id']].nil? # skip empty secrets
  file "#{node['nimbus-jenkins']['home']}/.ssh/#{credential['dot_ssh_filename']}" do
    owner node['nimbus-jenkins']['user']
    group node['nimbus-jenkins']['group']
    mode '0600'
    content lazy { node.run_state[credential['jenkins_credentials_id']] }
    # sensitive true
    # compile_time true
  end
  # store filenames for use with ssh config
  ssh_files.append(credential['dot_ssh_filename'])
end

# final config of .ssh/config
# setup ssh client to use all keys
template "#{node['nimbus-jenkins']['home']}/.ssh/config" do
  source node['nimbus-jenkins']['master']['ssh_template']
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '00600'
  variables(
    filenames: ssh_files
  )
  # subscribes :create, 'directory[ssh_directory]', :immediately
end
