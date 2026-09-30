# Cookbook:: nimbus-jenkins
# Recipe:: _chefworkstation.rb
#

# install chef workstation
# https://packages.chef.io/files/stable/chef-workstation/22.7.1006/el/7/chef-workstation-22.7.1006-1.el7.x86_64.rpm
#
chef_workstation_rpm = Chef::Config[:file_cache_path] + "/#{node['nimbus-jenkins']['chef-workstation']['rpm']}"
source_url = [
  node['nimbus-jenkins']['chef-workstation']['source'],
  node['nimbus-jenkins']['chef-workstation']['version'],
  'el/7',
  node['nimbus-jenkins']['chef-workstation']['rpm'],
].join('/')

# get the rpm
remote_file chef_workstation_rpm do
  owner 'root'
  group 'root'
  mode '0644'
  source source_url
  not_if "rpm -q chef-workstation |grep #{node['nimbus-jenkins']['chef-workstation']['version']}"
end

# install the rpm
execute "yum-install-#{node['nimbus-jenkins']['chef-workstation']['rpm']}" do
  command "yum -y localinstall #{chef_workstation_rpm}"
  not_if "rpm -q chef-workstation |grep #{node['nimbus-jenkins']['chef-workstation']['version']}"
end

# create symlinks into /usr/local/bin for often-used tools
%w(berks chef chef-apply chef-solo chef-vault cookstyle foodcritic inspec kitchen knife).each do |x|
  link "/usr/local/bin/#{x}" do
    to "/opt/chef-workstation/embedded/bin/#{x}"
  end
end

# accept the license
execute 'accept-license' do
  command '/opt/chef-workstation/bin/chef shell-init bash --chef-license accept-silent'
  not_if { ::File.exist?('/etc/chef/accepted_licenses/chef_workstation') }
end

# add to chefworkstation to path
node.default['nimbus-jenkins']['mbj_data']['environment_vars_path_chefworkstation'] = [
  '/opt/chef-workstation/bin',
  '/opt/chef-workstation/embedded/bin',
  '/opt/chef-workstation/gitbin',
  '$HOME/.chefdk/gem/ruby/3.0.0/bin',
].join(':')

# add GEM vars to Environment
node.default['nimbus-jenkins']['mbj_data']['environment_vars_chefworkstation'] = {
  'GEM_HOME' => "#{node['nimbus-jenkins']['home']}/.chef/gem/ruby/3.0.0",
  'GEM_ROOT' => '/opt/chef-workstation/embedded/lib/ruby/gems/3.0.0',
  'GEM_PATH' => [
    '$HOME/.chef/gem/ruby/3.0.0',
    '/opt/chef-workstation/embedded/lib/ruby/gems/3.0.0',
  ].join(':'),
}

# update default profile so that tools are available
file '/etc/profile.d/chef-workstation.sh' do
  content <<-SCR
  PATH="#{node['nimbus-jenkins']['mbj_data']['environment_vars_path_chefworkstation']}":$PATH
  eval "$(chef shell-init bash)"
  SCR
  mode '0755'
end

# end of file
