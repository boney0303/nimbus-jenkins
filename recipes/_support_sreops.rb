# Cookbook:: nimbus-jenkins
# Recipe:: _software_sreops
#

# SRE ops bitbucket and superops keys
# private_key_bitbucket_file = node['nimbus-jenkins']['home'] + '/.ssh/id_rsa_bitbucket'
# private_key_superops_file = node['nimbus-jenkins']['home'] + '/.ssh/superops.pem'
# private_key_packer_file = node['nimbus-jenkins']['home'] + '/.ssh/jenkins.pem'

# migrated to
# Attributes for below 3 files content will be updated in _configure_aws recipe
# file private_key_bitbucket_file do
#   owner node['nimbus-jenkins']['user']
#   group node['nimbus-jenkins']['group']
#   content node['nimbus-jenkins']['sreops']['bitbucket']['private_key']
#   mode '0400'
#   action :create_if_missing
#   sensitive true
# end

# file private_key_packer_file do
#   owner node['nimbus-jenkins']['user']
#   group node['nimbus-jenkins']['group']
#   content node['nimbus-jenkins']['sreops']['packer']['private_key']
#   mode '0400'
#   action :create_if_missing
#   sensitive true
# end

# file private_key_superops_file do
#   owner node['nimbus-jenkins']['user']
#   group node['nimbus-jenkins']['group']
#   content node['nimbus-jenkins']['sreops']['superops']['private_key']
#   mode '0400'
#   action :create_if_missing
#   sensitive true
# end

# # Configure .ssh/config to acceess BitBucket and SSH to controller using superops.pem private key
# template "#{node['nimbus-jenkins']['home']}/.ssh/config" do
#   source 'controller_config.erb'
#   owner node['nimbus-jenkins']['user']
#   group node['nimbus-jenkins']['group']
#   mode '0600'
# end

# Create directory to keep all the repositories required by SRE OPS
directory node['nimbus-jenkins']['sreops']['repository']['path'] do
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0755'
  action :create
end

# install OPS virtualenv
execute 'create_ops_virtualenv' do
  command "python3 -m venv #{node['nimbus-jenkins']['sreops']['venv']['path']}"
  not_if { ::File.exist?("#{node['nimbus-jenkins']['sreops']['venv']['path']}/bin/activate") }
  action :nothing
end

# upgrade pip package in venv
execute 'upgrade pip' do
  cwd node['nimbus-jenkins']['sreops']['venv']['path']
  command <<~EOF
    source bin/activate && \
    python3 -m pip install --upgrade pip && \
    deactivate
  EOF
  notifies :run, 'execute[create_ops_virtualenv]', :before
end

# install ops versioned python3 packages in virtualenv
node['nimbus-jenkins']['sreops']['versioned_pip_packages'].each do |k, v|
  execute 'install ops python3 packages' do
    cwd node['nimbus-jenkins']['sreops']['venv']['path']
    command <<~EOF
      source bin/activate && \
      python3 -m pip install #{k}==#{v} && \
      deactivate
    EOF
    not_if <<~EOF
      source bin/activate && \
      PACKAGES=$(pip freeze)  && \
      deactivate && \
      echo $PACKAGES | grep #{k} | grep #{v}
    EOF
  end
end

# SES Token Required for SREOPS
node['nimbus-jenkins']['mbj_data']['credentials']['text'].each do |credential|
  if credential['jenkins_credentials_id'] == 'default-ses-token'
    node.override['nimbus-jenkins']['sreops']['ses_token'] = node.run_state[credential['jenkins_credentials_id'].strip]
  end
end

# upgrade pip before installing python2 packages - moved to _software.rb
# execute 'upgrade pip2' do
#   command '/usr/bin/python2 -m pip install --upgrade pip==20.3.4'
# end

# install ops versioned python2.7 packages in virtualenv
# node['nimbus-jenkins']['sreops']['versioned_pip_2_7_packages'].each do |k, v|
#   execute 'install ops python2.7 packages' do
#     command "/usr/bin/python2 -m pip install #{k}==#{v}"
#     not_if <<~EOF
#       PACKAGES=$(pip freeze)  && \
#       echo $PACKAGES | grep #{k} | grep #{v}
#     EOF
#     ignore_failure true
#   end
# end

# setup postfix config
template '/etc/postfix/main.cf' do
  source 'etc_postfix_main.erb'
  mode '00644'
  owner 'root'
  group 'root'
end

service 'postfix' do
  subscribes :reload, 'template[/etc/postfix/main.cf]', :immediately
end

# setup ses sasl
template '/etc/postfix/sasl_passwd' do
  source 'sasl_passwd.erb'
  mode '00644'
  owner 'root'
  group 'root'
  notifies :run, 'execute[postmap_commands]', :immediately
end

# Setup ses sasl db
execute 'postmap_commands' do
  command 'postmap hash:/etc/postfix/sasl_passwd && postmap /etc/postfix/generic'
  action :nothing
end

# setup splunk input.conf
cookbook_file '/opt/splunkforwarder/etc/apps/SplunkUniversalForwarder/local/inputs.conf' do
  source 'splunk_inputs.conf'
  mode '00644'
  owner 'splunk'
  group 'splunk'
end

service 'splunk' do
  subscribes :restart, 'cookbook_file[/opt/splunkforwarder/etc/apps/SplunkUniversalForwarder/local/inputs.conf]', :immediately
end
