# Cookbook:: nimbus-jenkins
# Recipe:: _system
#

# provide iptables resources
include_recipe 'nimbus-iptables'

# set iptables to allow jenkins access
iptables_open_port node['nimbus-jenkins']['master']['port']

# setup sysconfig
template '/etc/sysconfig/jenkins' do
  source 'jenkins.sysconfig.erb'
  mode '0600'
end

# setup logging
include_recipe 'nimbus-splunk'

[
  'jenkins.log',
  'access_log',
].each do |x|
  next if x == 'access_log' && node['nimbus-jenkins']['enable_access_log'] == 'no'

  template "/etc/logrotate.d/#{x}" do
    source 'logrotate.erb'
    variables(logfile: x)
  end

  splunk_log "/var/log/jenkins/#{x}"
end

# Change the shell of jenkins user to /bin/bash
user node['nimbus-jenkins']['user'] do
  shell '/bin/bash'
  action :modify
end

# enable proxy if we have a URL
unless node['nimbus-jenkins']['proxy']['url'].nil?
  puts "Proxy configuration ENABLED with #{node['nimbus-jenkins']['proxy']['url']}"
  node.override['nimbus-jenkins']['proxy']['enable'] = true
  node.override['nimbus-jenkins']['master']['host'] = node['nimbus-jenkins']['proxy']['url']
end

# setup git client for git push to identify Jenkins host
template "#{node['nimbus-jenkins']['home']}/.gitconfig" do
  source 'gitconfig.erb'
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0644'
  variables(
    username: node['nimbus-jenkins']['git']['username'],
    email: node['nimbus-jenkins']['git']['email']
  )
end
