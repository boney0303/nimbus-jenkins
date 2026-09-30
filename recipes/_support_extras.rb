# Cookbook:: nimbus-jenkins
# Recipe:: _software_extras
#

# install packer
# https://releases.hashicorp.com/packer/1.5.4/packer_1.5.4_linux_amd64.zip
packer_zipfile = Chef::Config[:file_cache_path] + "/#{node['nimbus-jenkins']['packer']['dist_filename']}"
packer_dir = "/usr/local/#{node['nimbus-jenkins']['packer']['dist_name']}"
packer_symlink = '/usr/local/bin/packer'
remote_file packer_zipfile do
  source "#{node['nimbus-jenkins']['packer']['url_base']}/#{node['nimbus-jenkins']['packer']['version']}/#{node['nimbus-jenkins']['packer']['dist_filename']}"
  owner 'root'
  group 'root'
  mode '0755'
  checksum node['nimbus-jenkins']['packer']['checksum']
  not_if "/usr/local/bin/packer version| grep #{node['nimbus-jenkins']['packer']['version']}"
end
execute "unzip-#{packer_zipfile}" do
  command "unzip -q -o #{packer_zipfile} -d #{packer_dir}"
  creates packer_dir
  not_if "/usr/local/bin/packer version| grep #{node['nimbus-jenkins']['packer']['version']}"
end
link packer_symlink do
  to "#{packer_dir}/packer"
  not_if "/usr/local/bin/packer version| grep #{node['nimbus-jenkins']['packer']['version']}"
end

# kubectl
# https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl
kubectl = '/usr/local/bin/kubectl'
remote_file kubectl do
  owner 'root'
  group 'root'
  mode '0755'
  source node['nimbus-jenkins']['kubectl']['url']
  checksum node['nimbus-jenkins']['kubectl']['checksum']
  action :create_if_missing
end

# helm v3
# https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
helm_tarfile = Chef::Config[:file_cache_path] + '/' + node['nimbus-jenkins']['helm']['archive']
remote_file helm_tarfile do
  owner 'root'
  group 'root'
  mode '0755'
  source node['nimbus-jenkins']['helm']['url']
  action :create_if_missing
end
execute 'untar-helm' do
  command "rm -fr /usr/local/bin/helm && /bin/tar xzf #{helm_tarfile} --strip-components=1 -C /usr/local/bin/"
  notifies :run, 'script[configure-helm]', :immediately
end

# Helm now is v3, which doesn't support "helm init", and doesn't include stable default repos
# https://helm.sh/docs/topics/v2_v3_migration/
#
script 'configure-helm' do
  user node['nimbus-jenkins']['user']
  cwd node['nimbus-jenkins']['home']
  interpreter 'bash'
  environment(
    { 'HELM_HOME' => node['nimbus-jenkins']['home'] }
  )
  code <<-EOH
    /usr/local/bin/helm repo add stable https://charts.helm.sh/stable
    /usr/local/bin/helm plugin install https://github.com/hypnoglow/helm-s3 || echo "already installed"
    /usr/local/bin/helm plugin install https://github.com/jkroepke/helm-secrets || echo "already installed"
  EOH
  action :nothing
end

# symlink sbt into path
link '/usr/local/bin/sbt' do
  to '/usr/share/sbt/bin/sbt'
  not_if { ::File.exist?('/usr/local/bin/sbt') }
end

# download sops
sops_rpm = Chef::Config[:file_cache_path] + '/' + node['nimbus-jenkins']['sops']['rpm']
remote_file sops_rpm do
  owner 'root'
  group 'root'
  mode '0644'
  source node['nimbus-jenkins']['sops']['url']
  action :create_if_missing
end

# install sops
rpm_package 'sops' do
  action :install
  source sops_rpm
end

# install opa
remote_file '/usr/local/bin/opa' do
  owner 'root'
  group 'root'
  mode '0755'
  source node['nimbus-jenkins']['opa']['url']
  action :create_if_missing
end
