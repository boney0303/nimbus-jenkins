# Cookbook:: nimbus-jenkins
# Recipe:: _my_bloody_jenkins
#

# to configure Jenkins, this recipe uses:
# init.d.groovy feature https://wiki.jenkins.io/display/JENKINS/Post-initialization+script
# using the scripts from https://github.com/odavid/my-bloody-jenkins
#
# this recipe applies configuration with config.yaml using the groovy scripts installed
# in JENKINS_HOME/init.groovy.d/

# implement 'my-bloody-jenkins' configuration tool
# https://github.com/odavid/my-bloody-jenkins

# the config yaml is created from converting certain attributes to yaml
# node['nimbus-jenkins']['mbj']

# create directory for init groovy scripts
directory node['nimbus-jenkins']['mbj_config']['home'] do
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0755'
  recursive true
end

# copy groovy configuration scripts
remote_directory node['nimbus-jenkins']['mbj_config']['library'] do
  source 'my-bloody-jenkins'
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  files_mode '0644'
  mode '0755'
  sensitive true
end

# setup credentials section for ssh keys to be loaded by mbj
node['nimbus-jenkins']['mbj_data']['credentials']['sshkey'].each do |credential|
  next unless credential['username'] # required
  next unless node.run_state[credential['jenkins_credentials_id']] # skip empty secrets
  next if node.run_state[credential['jenkins_credentials_id']].nil? # skip empty secrets
  node.override['nimbus-jenkins']['mbj']['credentials'][credential['jenkins_credentials_id']] = {
    type: 'sshkey',
    description: credential['description'],
    username: credential['username'],
    privatekey: node.run_state[credential['jenkins_credentials_id']],
  }
end

# setup credentials section for text to be loaded by mbj
node['nimbus-jenkins']['mbj_data']['credentials']['text'].each do |credential|
  next unless node.run_state[credential['jenkins_credentials_id']] # skip empty secrets
  next if node.run_state[credential['jenkins_credentials_id']].nil? # skip empty secrets
  node.override['nimbus-jenkins']['mbj']['credentials'][credential['jenkins_credentials_id']] = {
    type: 'text',
    description: credential['description'],
    text: node.run_state[credential['jenkins_credentials_id'].strip],
  }
end

# setup credentials section for files to be loaded by mbj
node['nimbus-jenkins']['mbj_data']['credentials']['file'].each do |credential|
  next unless credential['filename'] # required
  next unless node.run_state[credential['jenkins_credentials_id']] # skip empty secrets
  next if node.run_state[credential['jenkins_credentials_id']].nil? # skip empty secrets
  node.override['nimbus-jenkins']['mbj']['credentials'][credential['jenkins_credentials_id']] = {
    type: 'file',
    description: credential['description'],
    fileName: credential['filename'],
    text: node.run_state[credential['jenkins_credentials_id']],
  }
end

# setup credentials section for username/passwords to be loaded by mbj
node['nimbus-jenkins']['mbj_data']['credentials']['userpass'].each do |credential|
  next unless credential['username'] # required
  next unless node.run_state[credential['jenkins_credentials_id']] # skip empty secrets
  next if node.run_state[credential['jenkins_credentials_id']].nil? # skip empty secrets
  node.override['nimbus-jenkins']['mbj']['credentials'][credential['jenkins_credentials_id']] = {
    type: 'userpass',
    description: credential['description'],
    username: credential['username'],
    password: node.run_state[credential['jenkins_credentials_id'].strip],
  }
end

# permissions: https://wiki.jenkins.io/display/JENKINS/Matrix-based+security

# process node['nimbus-jenkins']['mbj_data'] for yaml conversion

# setup environment variables
node.override['nimbus-jenkins']['mbj']['environment'] = node['nimbus-jenkins']['mbj_data']['environment_vars_defaults'].merge(node['nimbus-jenkins']['mbj_data']['environment_vars_chefworkstation'])
node.override['nimbus-jenkins']['mbj']['environment']['PATH'] = [
  node['nimbus-jenkins']['mbj_data']['environment_vars_path_tf'],
  node['nimbus-jenkins']['mbj_data']['environment_vars_path_chefworkstation'],
  node['nimbus-jenkins']['mbj_data']['environment_vars_path_defaults'],
].join(':')

# setup security section - admins users
node['nimbus-jenkins']['mbj_data']['security']['groups']['admins'].each do |group_name|
  node.override['nimbus-jenkins']['mbj']['security']['permissions'][group_name] = node['nimbus-jenkins']['static']['permissions']['admin']
end

# setup security section - powerusers users
node['nimbus-jenkins']['mbj_data']['security']['groups']['powerusers'].each do |group_name|
  node.override['nimbus-jenkins']['mbj']['security']['permissions'][group_name] = node['nimbus-jenkins']['static']['permissions']['powerusers']
end

# setup security section - users
node['nimbus-jenkins']['mbj_data']['security']['groups']['users'].each do |group_name|
  node.override['nimbus-jenkins']['mbj']['security']['permissions'][group_name] = node['nimbus-jenkins']['static']['permissions']['users']
end

# setup notifiers section
node['nimbus-jenkins']['mbj_data']['notifiers'].each do |name, details|
  node.override['nimbus-jenkins']['mbj']['notifiers'][name] = details
end

# setup pipeline libraries section
node['nimbus-jenkins']['mbj_data']['pipeline_libraries'].each do |name, details|
  node.override['nimbus-jenkins']['mbj']['pipeline_libraries'][name] = details
end

# setup seed_jobs section
node['nimbus-jenkins']['mbj_data']['seed_jobs'].each do |name, details|
  node.override['nimbus-jenkins']['mbj']['seed_jobs'][name] = details
end

# create yaml from the attributes :)
template node['nimbus-jenkins']['mbj_config']['file'] do
  source 'config.yaml.erb'
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0644'
  variables(
    lazy do
      { config: node['nimbus-jenkins']['mbj'] }
    end
  )
  helpers NimbusJenkinsMbjHelper
  sensitive true
  notifies :run, 'execute[systemctl-reload]', :delayed
end

# create config loader
template "#{node['nimbus-jenkins']['mbj_config']['home']}/configLoader.groovy" do
  source 'init.d.groovy/JenkinsConfigLoader.groovy'
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0755'
  variables(
    lazy do
      {
        config_library: node['nimbus-jenkins']['mbj_config']['library'],
        config_file: node['nimbus-jenkins']['mbj_config']['file'],
      }
    end
  )
  sensitive true
  notifies :run, 'execute[systemctl-reload]', :delayed
end
