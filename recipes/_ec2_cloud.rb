# Cookbook:: nimbus-jenkins
# Recipe:: _ec2_cloud

# configure EC2 Cloud (workers) - https://github.com/jenkinsci/ec2-plugin

# For creating a Jenkins worker group using the ec2 cloud plugin, you need to add these attributes to the
# Chef environment JSON file located in chef-repo/environments.  Others can be added to override the defaults listed
# within default['nimbus-jenkins']['casc_data']['cloud_default_template'] in attributes/casc.rb.
# The following JSON is provided as an example. Yes the TAGs are required.

# default.attributes.nimbus-jenkins.casc_data = node['nimbus-jenkins']['casc_data']
# {
#   "casc_data":{
#     "template_info":{
#       "mycloudname": {
#         "boot":{
#           "awscli_version": "version of awscli, defaults to '1.19.6'",
#           "chef_role" => "existing chef role in chef-repo used to apply to worker node, default to 'default_jenkins_worker'",
#           "userdata_template": "existing template in cookbook, defaults to 'ec2cloud_userdata_chef.erb'"
#         },
#         "plugin": {
#           "description": "my description",
#           "idleTerminationMinutes": "idle minutes until node is destroyed",
#           "instanceCapStr": "4",
#           "labelString": "used by Jenkins to run jobs that have the agent=<a single label>",
#           "minimumNumberOfInstances": "Set a minimum number of instances",
#           "type": "M5Xlarge",
#           "tags":{
#             "DataClassification": "Cisco Highly Confidential",
#             "DeploymentEnvironment": "( NonProd | Prod )",
#             "Description": "Sets Description TAG",
#             "JIRACreation": "Sets JIRACreation TAG",
#             "JIRAProject": "Sets JIRAProject TAG",
#             "ResourceOwner": "owner@nimbus.io",
#           },
#         },
#       },
#       "anothercloud": {
#         ....
#       }
#     }
#   }
# }

if node['ec2'] && node['ec2']['region'] # ensure we are hosted in AWS

  # add test_kitchen_for_cookbooks for dev environments
  if %w(pdx-d01 syd-d01).include? node.environment
    # define test kitchen cloud
    node.default['nimbus-jenkins']['casc_data']['template_info']['TestKitchen'] = {}

    # boot settings
    node.default['nimbus-jenkins']['casc_data']['template_info']['TestKitchen']['boot']['chef_role'] = 'default_jenkins_worker'
    node.default['nimbus-jenkins']['casc_data']['template_info']['TestKitchen']['boot']['userdata_template'] = 'ec2cloud_userdata_chef.erb'

    # settings that plugin supports directly
    node.default['nimbus-jenkins']['casc_data']['template_info']['TestKitchen']['plugin']['idleTerminationMinutes'] = '30'
    node.default['nimbus-jenkins']['casc_data']['template_info']['TestKitchen']['plugin']['instanceCapStr'] = '1'
    node.default['nimbus-jenkins']['casc_data']['template_info']['TestKitchen']['plugin']['labelString'] = "test-kitchen #{node.environment} #{node['ec2']['region']}"
    node.default['nimbus-jenkins']['casc_data']['template_info']['TestKitchen']['plugin']['minimumNumberOfInstances'] = '1'
    node.default['nimbus-jenkins']['casc_data']['template_info']['TestKitchen']['plugin']['type'] = 'M5Xlarge'
    node.default['nimbus-jenkins']['casc_data']['template_info']['TestKitchen']['plugin']['tags'] = {
      'DataClassification' => 'Cisco Highly Confidential',
      'DeploymentEnvironment' => 'NonProd',
      'Description' => 'Workers for Cookbook Testing via Test Kitchen',
      'JIRACreation' => 'SSEG-10662',
      'JIRAProject' => 'SSEG',
      'ResourceOwner' => 'owner@nimbus.io',
    }
  end

  # create userdata as file on system for ease of addition to ec2cloud setup
  node['nimbus-jenkins']['casc_data']['template_info'].each do |template_name, template_data|
    bootsettings = node['nimbus-jenkins']['casc_data']['boot_defaults'].dup
    bootsettings['awsregion'] = node['ec2']['region']

    # override defaults if provided
    bootsettings.merge!(template_data['boot']) if template_data['boot']
    template "#{Chef::Config[:file_cache_path]}/ec2plugin_#{template_name}_userdata" do
      source bootsettings['userdata_template']
      variables(
        bootsettings
      )
      compile_time true
    end
  end

  # iterate all cloud 'template_info' to create 'processed_templates' for addition to node.default['nimbus-jenkins']['casc_data']['cloud_data']
  processed_templates = []
  node['nimbus-jenkins']['casc_data']['template_info'].each do |template_name, template_data|
    # copy defaults as a starting point - override as needed
    cloud_template = node['nimbus-jenkins']['casc_data']['ec2plugin_default_template'].dup

    # override defaults if provided
    cloud_template.merge!(template_data['plugin']) if template_data['plugin']

    # ensure that instance type is valid- default to 'M5Xlarge'
    unless node['nimbus-jenkins']['ec2_instance_types'].include? cloud_template['type']
      cloud_template['type'] = 'M5Large'
    end

    # set template description same as tag:Description
    if template_data['plugin'] && template_data['plugin']['tags']['Description']
      cloud_template['description'] = template_data['plugin']['tags']['Description']
    end

    # copy default tags as a starting point - override as needed
    raw_tags = node['nimbus-jenkins']['casc_data']['ec2plugin_default_tags'].dup
    if template_data['plugin'] && template_data['plugin']['tags']
      raw_tags.merge!(template_data['plugin']['tags']) # format tags into name=, value=
    end
    processed_tags = []
    raw_tags.each do |name, value|
      processed_tags.append({ 'name' => name, 'value' => value })
    end
    cloud_template['tags'] = processed_tags

    # setup the boot settings
    cloud_template['userData'] = ::File.read("#{Chef::Config[:file_cache_path]}/ec2plugin_#{template_name}_userdata")
    processed_templates.push(cloud_template)
  end

  # add 'processed_templates' to CASC cloud_data
  node.default['nimbus-jenkins']['casc_data']['cloud_data'] = {
    'cloudName' => node.environment,
    'credentialsId' => "#{node.environment}-jenkins",
    'noDelayProvisioning' => 'true',
    'region' => node['ec2']['region'],
    'sshKeysCredentialsId' => 'infeng/jenkins-private-key',
    'useInstanceProfileForCredentials' => 'true',
    'templates' => processed_templates,
  }

  # create clouds from cloud_data
  node.default['nimbus-jenkins']['casc']['jenkins']['clouds'] = [{ 'amazonEc2' => node['nimbus-jenkins']['casc_data']['cloud_data'] }]

end
