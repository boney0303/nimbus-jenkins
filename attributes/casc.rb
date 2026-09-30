# Cookbook: = nimbus-jenkins
# Attributes: = casc
#

if node['ec2']
  # attributes for use with 'congiguration-as-code' configuration method
  default['nimbus-jenkins']['casc_dir'] = "#{node['nimbus-jenkins']['home']}/casc_configs"

  # java settings to support CASC
  default['nimbus-jenkins']['java_options'] = "-Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=#{node['nimbus-jenkins']['casc_dir']}"

  # node['nimbus-jenkins']['casc'] attributes are SUPPORTED DIRECTLY by the casc plugin
  default['nimbus-jenkins']['casc']['jenkins']['crumbIssuer']['standard']['excludeClientIPFromCrumb'] = false
  default['nimbus-jenkins']['casc']['jenkins']['disableRememberMe'] = true
  default['nimbus-jenkins']['casc']['jenkins']['disabledAdministrativeMonitors'] = [
    'OldData',
  ]
  default['nimbus-jenkins']['casc']['jenkins']['primaryView']['all']['description'] = '<a href=http://test.com>http://test.com</a>'
  default['nimbus-jenkins']['casc']['jenkins']['primaryView']['all']['name'] = 'all'

  default['nimbus-jenkins']['casc']['jenkins']['systemMessage'] = 'system message goes here\n\n'
  default['nimbus-jenkins']['casc']['jenkins']['labelString'] = 'master test-kitchen'

  default['nimbus-jenkins']['casc']['security']['gitHostKeyVerificationConfiguration']['sshHostKeyVerificationStrategy'] = 'noHostKeyVerificationStrategy'
  default['nimbus-jenkins']['casc']['security']['updateSiteWarningsConfiguration']['ignoredWarnings'] = %w(SECURITY-1350 SECURITY-1351 SECURITY-2053 SECURITY-2093 SECURITY-2232 SECURITY-2315 SECURITY-2394 SECURITY-2617-extended-choice-parameter SECURITY-837)

  default['nimbus-jenkins']['casc']['tool']['git']['installations'] = []
  default['nimbus-jenkins']['casc']['tool']['git']['installations'][0] = {
    'home' => 'git',
    'name' => 'Default',
  }

  default['nimbus-jenkins']['casc']['tool']['mavenGlobalConfig']['globalSettingsProvider'] = 'standard'
  default['nimbus-jenkins']['casc']['tool']['mavenGlobalConfig']['settingsProvider'] = 'standard'

  default['nimbus-jenkins']['casc']['tool']['pipelineMaven']['triggerDownstreamUponResultAborted'] = false
  default['nimbus-jenkins']['casc']['tool']['pipelineMaven']['triggerDownstreamUponResultFailure'] = false
  default['nimbus-jenkins']['casc']['tool']['pipelineMaven']['triggerDownstreamUponResultNotBuilt'] = false
  default['nimbus-jenkins']['casc']['tool']['pipelineMaven']['triggerDownstreamUponResultSuccess'] = false
  default['nimbus-jenkins']['casc']['tool']['pipelineMaven']['triggerDownstreamUponResultUnstable'] = false

  default['nimbus-jenkins']['casc']['unclassified']['bitbucketEndpointConfiguration']['endpoints'] = []
  default['nimbus-jenkins']['casc']['unclassified']['bitbucketEndpointConfiguration']['endpoints'][0] = {
    'bitbucketServerEndpoint' => {
      'credentialsId' => 'bitbucket-password',
      'displayName' => 'Corp',
      'manageHooks' => true,
      'serverUrl' => 'https://git.nimbus.io',
      'serverVersion' => 'VERSION_7',
    },
  }

  default['nimbus-jenkins']['casc']['unclassified']['buildUserVars']['allBuilds'] = true

  default['nimbus-jenkins']['casc']['unclassified']['awsCredentialsProvider']['cache'] = true
  default['nimbus-jenkins']['casc']['unclassified']['awsCredentialsProvider']['listSecrets']['filters'] = []

  default['nimbus-jenkins']['casc']['unclassified']['scmGit']['addGitTagAction'] = false
  default['nimbus-jenkins']['casc']['unclassified']['scmGit']['allowSecondFetch'] = false
  default['nimbus-jenkins']['casc']['unclassified']['scmGit']['createAccountBasedOnEmail'] = false
  default['nimbus-jenkins']['casc']['unclassified']['scmGit']['disableGitToolChooser'] = false
  default['nimbus-jenkins']['casc']['unclassified']['scmGit']['globalConfigEmail'] = 'jenkins@localhost'

  default['nimbus-jenkins']['casc']['unclassified']['scmGit']['globalConfigName'] = 'jenkins'
  default['nimbus-jenkins']['casc']['unclassified']['scmGit']['hideCredentials'] = false
  default['nimbus-jenkins']['casc']['unclassified']['scmGit']['showEntireCommitSummaryInChanges'] = false
  default['nimbus-jenkins']['casc']['unclassified']['scmGit']['useExistingAccountWithSameEmail'] = false

  default['nimbus-jenkins']['casc']['unclassified']['location']['adminAddress'] = 'saaseng@nimbus.io'
  default['nimbus-jenkins']['casc']['unclassified']['location']['url'] = node['nimbus-jenkins']['master']['host']

  # node['nimbus-jenkins']['casc'] - converted to YAML
  default['nimbus-jenkins']['casc']['jenkins']['clouds'] = []

  # node['nimbus-jenkins']['casc_data'] is used to derive additional settings that are added node['nimbus-jenkins']['casc'] eventually
  default['nimbus-jenkins']['casc_data'] = {}

  # ec2plugin user-supplied template information - top level where worker groups are defined
  default['nimbus-jenkins']['casc_data']['template_info'] = {}

  # ec2plugin tags will be merged with these below
  default['nimbus-jenkins']['casc_data']['ec2plugin_default_tags'] = {
    'CostCenter' => '020211745',
    'CreatedBy' => 'Jenkins EC2 Plugin',
    'DataClassification' => 'Cisco Highly Confidential',
    'DeploymentEnvironment' => 'Prod',
    'Environment' => node.environment,
    'Exception' => 'NA',
    'Name' => "#{node.environment}-jenkins-worker",
    'ResourceOwner' => 'owner@nimbus.io',
    'SecurityReview' => 'NA',
    'Service' => 'Jenkins',
  }

  # ec2plugin defaults for a template
  # https://github.com/jenkinsci/ec2-plugin#configure-plugin-via-groovy-script
  default['nimbus-jenkins']['casc_data']['ec2plugin_default_template'] = {
    'amiFilters' => [
      {
        'name' => 'name',
        'values' => 'nimbus-centos-7-x86_64-hvm-ebs-*',
      },
      {
        'name' => 'architecture',
        'values' => 'x86_64',
      },
    ],

    'associatePublicIp' => 'false',
    'connectBySSHProcess' => 'true',
    'connectionStrategy' => 'PRIVATE_IP',
    'deleteRootOnTermination' => 'true',
    'description' => 'notSet',

    'ebsEncryptRootVolume' => 'UNENCRYPTED',
    'ebsOptimized' => 'true',
    'hostKeyVerificationStrategy' => 'OFF',
    'iamInstanceProfile' => "arn:aws:iam::#{node['ec2']['account_id']}:instance-profile/#{node.environment}-jenkins-instance-profile",
    'idleTerminationMinutes' => '30',

    'instanceCapStr' => '1',
    'labelString' => 'notSet',
    'launchTimeoutStr' => '800',
    'maxTotalUses' => -1,
    'metadataEndpointEnabled' => 'true',

    'metadataTokensRequired' => 'false',
    'minimumNumberOfInstances' => 1,
    'minimumNumberOfSpareInstances' => 0,
    'mode' => 'EXCLUSIVE',
    'monitoring' => 'false',

    'numExecutors' => 1,
    'remoteAdmin' => 'jenkins',
    'remoteFS' => node['nimbus-jenkins']['home'],
    'securityGroups' => "#{node.environment}-jenkins-workers",
    'stopOnTerminate' => 'false',

    'subnetId' => node['ec2']['network_interfaces_macs'][node['ec2']['mac']]['subnet_id'],
    't2Unlimited' => 'false',
    'tags' => node['nimbus-jenkins']['casc_data']['cloud_default_tags'],
    'tenancy' => 'Default',
    'type' =>  'M5Large',

    'useEphemeralDevices' =>  'false',
    'zone' => node['ec2']['availability_zone'],
  }

  # ec2plugin defaults for a "ec2 cloud"
  default['nimbus-jenkins']['casc_data']['ec2plugin_defaults'] = {
    'cloudName' => 'notSet',
    'credentialsId' => "#{node.environment}-jenkins-public-key", # aws keypair name
    'noDelayProvisioning' => 'true',
    'region' => node['ec2']['region'],
    'sshKeysCredentialsId' => "#{node.environment}-jenkins-private-key", # 'credential' name of key located in /var/lib/jenkins/.ssh
    'useInstanceProfileForCredentials' => 'true',
    'templates' => [],
  }

  # add default template to list of cloud templates
  default['nimbus-jenkins']['casc_data']['ec2plugin_defaults']['templates'].push(node['nimbus-jenkins']['casc_data']['ec2plugin_default_template'])
end

# defaults - override within your own settings with node['nimbus-jenkins']['casc_data']['template_info']['YOURCLOUDNAME']['boot']
default['nimbus-jenkins']['casc_data']['boot_defaults'] = {
  'deployregion' => node.chef_environment.split('-').first,
  'awscli_version' => '1.19.6',
  'chef_environment' =>  node.chef_environment,
  'chef_role' => 'default_jenkins_worker',
  'chef_server' => node['nimbus-jenkins']['chef_server'],
  'jhome' => node['nimbus-jenkins']['home'],
  'region' => node['ec2'] ? node['ec2']['region'] : 'us-west-2',
  'userdata_template' => 'ec2cloud_userdata_chef.erb',
}
