# Cookbook:: nimbus-jenkins
# Recipe:: _plugins
#

# install plugins

# create plugins directory
directory "#{node['nimbus-jenkins']['home']}/plugins" do
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0755'
  recursive true
end

# create list of plugins from attributes
template "#{node['nimbus-jenkins']['home']}/plugins.txt" do
  source 'plugins.txt.erb'
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0644'
  action :create
  variables(
    plugins: Array(node['nimbus-jenkins']['plugins'])
  )
end

# download the jenkins-plugin-manager
# https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.9.0/jenkins-plugin-manager-2.10.0.jar
remote_file "#{node['nimbus-jenkins']['home']}/jenkins-plugin-manager.jar" do
  owner 'root'
  group 'root'
  mode '0755'
  source node['nimbus-jenkins']['plugin_manager']['source_url']
end

# write env setup to file for maintenance use
file "#{node['nimbus-jenkins']['home']}/jenkins-plugin-manager.env" do
  content <<-EOC
  export JENKINS_VERSION="#{node['nimbus-jenkins']['master']['packages']['jenkins']}"
  export JENKINS_UC="#{node['nimbus-jenkins']['update_center_url']}?version=#{node['nimbus-jenkins']['master']['packages']['jenkins']}"
  export JENKINS_WAR=/usr/lib/jenkins/jenkins.war
  export PLUGIN_DIR="#{node['nimbus-jenkins']['home']}/plugins"
  EOC
end

# manage plugins using jenkins-plugin-manager.jar - https://github.com/jenkinsci/plugin-installation-manager-tool
script 'install-plugins' do
  interpreter 'bash'
  user node['nimbus-jenkins']['user']
  cwd node['nimbus-jenkins']['home']
  code <<-EOH
    java -jar #{node['nimbus-jenkins']['home']}/jenkins-plugin-manager.jar \
    -f #{node['nimbus-jenkins']['home']}/plugins.txt --latest=false \
    --verbose > #{node['nimbus-jenkins']['home']}/`date +%Y%m%d%H%M%s`_plugins_install.log
  EOH
  environment({
    'JENKINS_VERSION' => node['nimbus-jenkins']['master']['packages']['jenkins'],
    'JENKINS_UC' => node['nimbus-jenkins']['update_center_url'] + "?version=#{node['nimbus-jenkins']['master']['packages']['jenkins']}",
    'JENKINS_WAR' => '/usr/lib/jenkins/jenkins.war',
    'PLUGIN_DIR' => "#{node['nimbus-jenkins']['home']}/plugins",
  })
  notifies :run, 'execute[systemctl-reload]', :delayed
end

# update plugins to latest version that is compatible with jar and dependent plugins
script 'update-plugins' do
  interpreter 'bash'
  user node['nimbus-jenkins']['user']
  cwd node['nimbus-jenkins']['home']
  code <<-EOH
    java -jar #{node['nimbus-jenkins']['home']}/jenkins-plugin-manager.jar \
    -f #{node['nimbus-jenkins']['home']}/plugins.txt  \
    --verbose --available-updates > #{node['nimbus-jenkins']['home']}/`date +%Y%m%d%H%M%s`_plugins_update.log
  EOH
  environment({
    'JENKINS_VERSION' => node['nimbus-jenkins']['master']['packages']['jenkins'],
    'JENKINS_UC' => node['nimbus-jenkins']['update_center_url'] + "?version=#{node['nimbus-jenkins']['master']['packages']['jenkins']}",
    'JENKINS_WAR' => '/usr/lib/jenkins/jenkins.war',
    'PLUGIN_DIR' => "#{node['nimbus-jenkins']['home']}/plugins",
  })
  notifies :run, 'execute[systemctl-reload]', :delayed
end
