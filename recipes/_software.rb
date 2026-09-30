# Cookbook:: nimbus-jenkins
# Recipe:: _software
#

# ensure jenkins package is available
execute 'clean-yum' do
  command 'yum update -y'
end

# install packages for Jenkins
node['nimbus-jenkins']['master']['packages'].each do |k, v|
  package k do
    action :install
    flush_cache [ :before ]
    version v
  end
end

# install/remove Distro PRMS
node['nimbus-jenkins']['worker']['packages'].each do |k, v|
  package k do
    action v ? :install : :remove
  end
end

# install Versioned RPMS
node['nimbus-jenkins']['worker']['versioned_packages'].each do |k, v|
  package k do
    version v
  end
end

# install chef-workstation
include_recipe 'nimbus-jenkins::_chefworkstation' if node['nimbus-jenkins']['chefworkstation']

# install versioned gems system-wide
node['nimbus-jenkins']['worker']['versioned_gems'].each do |k, v|
  gem_package k do
    action :install
    gem_binary '/opt/chef-workstation/embedded/bin/gem'
    version v
  end
end

# install unversioned gems system-wide
node['nimbus-jenkins']['worker']['gems'].each do |k|
  gem_package k do
    action :install
    gem_binary '/opt/chef-workstation/embedded/bin/gem'
  end
end

# upgrade pip to prevent python module installation failures
# python 2.7 LAST version of pip supported is 20.3.4
execute 'python2-mpip-upgrade' do
  command '/usr/bin/python2 -m pip install --upgrade pip==20.3.4'
  not_if '/usr/bin/python2 -m pip list --format=columns | grep pip | grep 20.3.4'
end
execute 'python3-mpip-upgrade' do
  command '/usr/bin/python3 -m pip install --upgrade pip'
end

# install versioned pip2 packages with python2
node['nimbus-jenkins']['versioned_pip2_packages'].each do |k, v|
  execute 'python2-mpip-install-versioned-packages' do
    command "/usr/bin/python2 -m pip install #{k}==#{v}"
    not_if "/usr/bin/python2 -m pip list --format=columns | grep #{k}| grep #{v}"
  end
end

# install un-versioned pip2 packages with python2
node['nimbus-jenkins']['pip2_packages'].each do |this_package|
  execute 'python2-mpip-install-packages' do
    command "/usr/bin/python2 -m pip install #{this_package}"
    not_if "/usr/bin/python2 -m pip list --format=columns | grep #{this_package}"
  end
end

# install versioned pip3 packages with python3
node['nimbus-jenkins']['versioned_pip3_packages'].each do |k, v|
  execute 'python3-mpip-install-versioned-packages' do
    command "/usr/bin/python3 -m pip install #{k}==#{v}"
    not_if "/usr/bin/python3 -m pip list --format=columns | grep #{k}| grep #{v}"
  end
end

# install un-versioned pip3 packages with python3
node['nimbus-jenkins']['pip3_packages'].each do |this_package|
  execute 'python3-mpip-install-packages' do
    command "/usr/bin/python3 -m pip install #{this_package}"
    not_if "/usr/bin/python3 -m pip list --format=columns | grep #{this_package}"
  end
end

# install awscli
awscli_zipfile = Chef::Config[:file_cache_path] + '/' + node['nimbus-jenkins']['awscli']['archive']
awscli_dir = "/usr/local/awscli-#{node['nimbus-jenkins']['awscli']['version']}"

# download the file
remote_file awscli_zipfile do
  owner 'root'
  group 'root'
  mode '0644'
  source node['nimbus-jenkins']['awscli']['url']
  action :create_if_missing
  notifies :run, 'execute[unzip-awscli-zipfile]', :immediately
end

# unzip the file
execute 'unzip-awscli-zipfile' do
  command "unzip -q -o #{awscli_zipfile} -d #{awscli_dir}"
  action :nothing
  notifies :run, 'execute[run-awscli-installer]', :immediately
  not_if { ::File.directory?(awscli_dir) }
end

# run the installer
execute 'run-awscli-installer' do
  command "/usr/bin/python3 #{awscli_dir}/#{node['nimbus-jenkins']['awscli']['install_command']}"
  action :nothing
end

# install tfenv - terraform version switcher
execute 'git-clone-tfenv' do
  command "git clone --depth=1 #{node['nimbus-jenkins']['tfenv']['giturl']} #{node['nimbus-jenkins']['tfenv']['install_directory']}"
  user  node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  not_if { ::File.directory?(node['nimbus-jenkins']['tfenv']['install_directory']) }
end

# install all requested versions
node['nimbus-jenkins']['tfenv']['terraform']['versions'].each do |tfversion|
  execute "install-terraform-#{tfversion}-with-tfenv" do
    command "#{node['nimbus-jenkins']['tfenv']['install_directory']}/bin/tfenv install #{tfversion} || true"
    user  node['nimbus-jenkins']['user']
    group node['nimbus-jenkins']['group']
  end
end

# install tgenv - terragrunt version switcher
execute 'git-clone-tgenv' do
  command "git clone --depth=1 #{node['nimbus-jenkins']['tgenv']['giturl']} #{node['nimbus-jenkins']['tgenv']['install_directory']}"
  user  node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  not_if { ::File.directory?(node['nimbus-jenkins']['tgenv']['install_directory']) }
end

# install all requested versions
node['nimbus-jenkins']['tgenv']['terragrunt']['versions'].each do |tgversion|
  execute "install-terragrunt-#{tgversion}-with-tgenv" do
    command "#{node['nimbus-jenkins']['tgenv']['install_directory']}/bin/tgenv install #{tgversion} || true"
    user  node['nimbus-jenkins']['user']
    group node['nimbus-jenkins']['group']
  end
end

# install undistributed terragrunt version to support older Terraform versions
node['nimbus-jenkins']['tgenv']['terragrunt']['old_versions'].each do |tgversion, tsum|
  directory "#{node['nimbus-jenkins']['tgenv']['install_directory']}/versions/#{tgversion}" do
    action :create
    user  node['nimbus-jenkins']['user']
    group node['nimbus-jenkins']['group']
    mode  '0755'
  end
  remote_file "terragrunt-#{tgversion}" do
    source "https://github.com/gruntwork-io/terragrunt/releases/download/v#{tgversion}/terragrunt_linux_amd64"
    path "#{node['nimbus-jenkins']['tgenv']['install_directory']}/versions/#{tgversion}/terragrunt"
    owner node['nimbus-jenkins']['user']
    group node['nimbus-jenkins']['group']
    checksum tsum
    mode '0755'
  end
end

# add tgenv/tfenv to path
node.default['nimbus-jenkins']['mbj_data']['environment_vars_path_tf'] = [
  "#{node['nimbus-jenkins']['tfenv']['install_directory']}/bin",
  "#{node['nimbus-jenkins']['tgenv']['install_directory']}/bin",
].join(':')

# update default profile so that tools are available
file '/etc/profile.d/tgenv-tfenv.sh' do
  content <<-TGTF
PATH="#{node['nimbus-jenkins']['mbj_data']['environment_vars_path_tf']}":$PATH
  TGTF
  mode '0755'
end
