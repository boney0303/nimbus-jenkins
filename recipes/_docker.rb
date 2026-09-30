# Cookbook:: nimbus-jenkins
# Recipe:: _docker
#

# setup docker
directory 'Create docker directory' do
  owner 'root'
  group 'root'
  mode '0755'
  path '/etc/docker'
  action :create
end

# configure docker
cookbook_file 'set docker config' do
  source 'daemon.json'
  owner 'root'
  group 'root'
  mode '0644'
  path '/etc/docker/daemon.json'
  action :create
end

# install docker via cookbook
docker_service 'default' do
  action [:create, :start]
  install_method 'package'
  iptables true
end

# add jenkins user to docker group
group 'docker' do
  action :modify
  members node['nimbus-jenkins']['user']
  append true
  not_if { ::File.exist?('/.dockerenv') }
end

# create docker directory
directory "#{node['nimbus-jenkins']['home']}/.docker" do
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0700'
end

# restart docker weekly
cron 'restart-docker-weekly' do
  command 'service docker restart'
  weekday '6'
  hour '01'
  minute '10'
  month '*'
end

# prune docker images
cron 'prune-docker-images' do
  command 'docker system prune -f'
  weekday '6'
  hour '01'
  minute '1'
  month '*'
end
