# Cookbook:: nimbus-jenkins
# Recipe:: _service

# remove files installed by RPM
[ '/etc/init.d/jenkins',
  '/etc/logrotate.d/jenkins',
].each do |thisfile|
  file thisfile do
    action :delete
  end
end

# create systemd directory for Jenkins
directory '/etc/systemd/system/jenkins.service.d' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  compile_time true
end

# create systemd service file
# see https://support.cloudbees.com/hc/en-us/articles/360038184151
# template 'jenkins-service' do
#   path '/etc/systemd/system/jenkins.service.d/override.conf'
#   source 'jenkins.service.erb'
#   variables({
#     home: node['nimbus-jenkins']['home'],
#     port: node['nimbus-jenkins']['port'],
#   })
#   notifies :run, 'execute[systemctl-reload]', :delayed
# end

# execute 'systemctl-reload' do
#   command 'systemctl daemon-reload; systemctl stop jenkins; systemctl start jenkins'
#   action :nothing
# end

# create systemd service file
systemd_unit '/etc/systemd/system/jenkins.service.d/override.conf' do
  actions [:create, :enable, :reload_or_restart, :start]
  content <<-FFF
[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Dcasc.jenkins.config=#{node['nimbus-jenkins']['casc_dir']} -Djenkins.install.runSetupWizard=false"
Environment="JENKINS_DEBUG_LEVEL=5"
Environment="JENKINS_HOME=#{node['nimbus-jenkins']['home']}"
Environment="JENKINS_JAVA_CMD=/etc/alternatives/java"
Environment="JENKINS_LOG=/var/log/jenkins/jenkins.log"
Environment="JENKINS_PORT=#{node['nimbus-jenkins']['master']['port']}"
Environment="JENKINS_WAR=/usr/share/java/jenkins.war"
Environment="JENKINS_WEBROOT=/var/cache/jenkins/war"
TimeoutStartSec=180
  FFF
  triggers_reload true
  user node['nimbus-jenkins']['user']
  verify false
end

# setup ssh client
include_recipe 'nimbus-jenkins::_ssh'

# create files to bypass startup wizards
file "#{node['nimbus-jenkins']['home']}/jenkins.install.UpgradeWizard.state" do
  content node['nimbus-jenkins']['master']['packages']['jenkins'].split('-')[0]
  mode '00644'
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
end
file "#{node['nimbus-jenkins']['home']}/jenkins.install.InstallUtil.lastExecVersion" do
  content node['nimbus-jenkins']['master']['packages']['jenkins'].split('-')[0]
  mode '00644'
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
end

# create the location file
template "#{node['nimbus-jenkins']['home']}/jenkins.model.JenkinsLocationConfiguration.xml" do
  source 'jenkins.model.JenkinsLocationConfiguration.xml'
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0644'
  variables(
    jenkins_url: node['nimbus-jenkins']['master']['host'],
    jenkins_email: node['nimbus-jenkins']['git']['email']
  )
end
