# Cookbook:: nimbus-jenkins
# Recipe:: _casc
#

# implement configuration-as-code plugin

# create directory for configuration-as-code settings
directory node['nimbus-jenkins']['casc_dir'] do
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0755'
  recursive true
end

template "#{node['nimbus-jenkins']['casc_dir']}/default.yaml" do
  source 'casc_configs/default.yaml.erb'
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  mode '0644'
  variables(
    lazy do
      { config: node['nimbus-jenkins']['casc'] }
    end
  )
  helpers NimbusJenkinsCascHelper
  sensitive true
  notifies :run, 'execute[systemctl-reload]', :delayed
end
