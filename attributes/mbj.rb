# Cookbook:: nimbus-jenkins
# Attributes:: mbj

# attributes for use with 'my-bloody-jenkins' configuration method

# node['nimbus-jenkins']['mbj_config'] - configuration vars for my bloody jenkins scripts
# node['nimbus-jenkins']['mbj_data'] - vars processed and added to mbj
# node['nimbus-jenkins']['mbj'] - vars directly converted to YAML
# node['nimbus-jenkins']['static'] - vars used during processing with node['nimbus-jenkins']['mbj_data']

default['nimbus-jenkins']['mbj_config']['home'] = node['nimbus-jenkins']['home'] + '/init.groovy.d'
default['nimbus-jenkins']['mbj_config']['library'] = node['nimbus-jenkins']['mbj_config']['home'] + '/my-bloody-jenkins'
default['nimbus-jenkins']['mbj_config']['file'] = node['nimbus-jenkins']['mbj_config']['home'] + '/config.yaml'

default['nimbus-jenkins']['mbj_data']['environment_vars_chefworkstation'] = {}

default['nimbus-jenkins']['mbj_data']['environment_vars_defaults'] = {
  'CHEF_LICENSE' => 'accept',
  'Environment' => node.environment,
  'GIT_COMMITER_EMAIL' => 'saaseng@nimbus.io',
  'GIT_COMMITER_NAME' => 'jenkins',
  'GitHost' => 'git.nimbus.io',
  'HttpGitHost' => 'https://git.nimbus.io',
  'PYTHONUNBUFFERED' => '1',
  'SshGitHost' => 'ssh://git.nimbus.io:7999',
}

default['nimbus-jenkins']['mbj_data']['environment_vars_path_defaults'] = [
  '/usr/local/bin',
  '/usr/bin',
  '/usr/local/sbin',
  '/usr/sbin',
  '/var/lib/jenkins/.chef/gem/ruby/3.0.0/bin',
].join(':')

default['nimbus-jenkins']['mbj_data']['credentials']['file'] = []
default['nimbus-jenkins']['mbj_data']['credentials']['sshkey'] = []
default['nimbus-jenkins']['mbj_data']['credentials']['text'] = []
default['nimbus-jenkins']['mbj_data']['credentials']['userpass'] = []

default['nimbus-jenkins']['mbj_data']['security']['groups']['admins'] = []
default['nimbus-jenkins']['mbj_data']['security']['groups']['powerusers'] = []
default['nimbus-jenkins']['mbj_data']['security']['groups']['users'] = []

default['nimbus-jenkins']['mbj_data']['notifiers'] = {}
default['nimbus-jenkins']['mbj_data']['pipeline_libraries'] = {}
default['nimbus-jenkins']['mbj_data']['seed_jobs'] = {}

default['nimbus-jenkins']['mbj']['credentials'] = {}
default['nimbus-jenkins']['mbj']['environment'] = {}

if node['ec2']
  default['nimbus-jenkins']['mbj']['environment']['AWSRegion'] = node['ec2']['region']
  default['nimbus-jenkins']['mbj']['environment']['AWS_DEFAULT_REGION'] = node['ec2']['region']
  default['nimbus-jenkins']['mbj']['environment']['AccountNumber'] = node['ec2']['account_id']
  default['nimbus-jenkins']['mbj']['environment']['JenkinsSubnet'] = node['ec2']['network_interfaces_macs'][node['ec2']['network_interfaces_macs'].keys[0]]['subnet_id']
  default['nimbus-jenkins']['mbj']['environment']['JenkinsVpcId'] = node['ec2']['network_interfaces_macs'][node['ec2']['network_interfaces_macs'].keys[0]]['vpc_id']
  default['nimbus-jenkins']['mbj']['environment']['REGION'] = node['ec2']['region']
end

default['nimbus-jenkins']['mbj']['security']['connectTimeout'] = 5000
default['nimbus-jenkins']['mbj']['security']['disableMailAddressResolver'] = false
default['nimbus-jenkins']['mbj']['security']['displayNameAttr'] = 'displayname'
default['nimbus-jenkins']['mbj']['security']['emailAttr'] = 'mail'
default['nimbus-jenkins']['mbj']['security']['groupMembershipFilter'] = '(memberUid={1})'
# default['nimbus-jenkins']['mbj']['security']['groupSearchBase'] = 'ou=groups,dc=nimbus,dc=io'
default['nimbus-jenkins']['mbj']['security']['groupSearchFilter'] = '(& (cn={0}) (objectclass=posixGroup))'
default['nimbus-jenkins']['mbj']['security']['readTimeout'] = 60000
default['nimbus-jenkins']['mbj']['security']['realm'] = 'ldap'
default['nimbus-jenkins']['mbj']['security']['rootDN'] = 'dc=nimbus,dc=io'
default['nimbus-jenkins']['mbj']['security']['server'] = "ldaps://ldap-#{node['ec2']['region']}.nimbus.io" if node['ec2']
# default['nimbus-jenkins']['mbj']['security']['userSearchBase'] = 'ou=Users,dc=nimbus,dc=io'
default['nimbus-jenkins']['mbj']['security']['userSearchFilter'] = 'uid={0}'

default['nimbus-jenkins']['mbj']['security']['permissions'] = {}

default['nimbus-jenkins']['mbj']['security']['securityOptions']['disableRememberMe'] = false
default['nimbus-jenkins']['mbj']['security']['securityOptions']['enableAgentMasterAccessControl'] = true
default['nimbus-jenkins']['mbj']['security']['securityOptions']['enableCLIOverRemoting'] = true
default['nimbus-jenkins']['mbj']['security']['securityOptions']['enableScriptSecurityForDSL'] = false
default['nimbus-jenkins']['mbj']['security']['securityOptions']['jnlpProtocols'] = [
  'JNLP4',
]
default['nimbus-jenkins']['mbj']['security']['securityOptions']['preventCSRF'] = true
default['nimbus-jenkins']['mbj']['security']['securityOptions']['sshdEnabled'] = true

default['nimbus-jenkins']['mbj']['security']['securityOptions']['markupFormatter']['rawHtmlMarkupFormatter']['disableSyntaxHighlighting'] = true

default['nimbus-jenkins']['mbj']['notifiers'] = {}

default['nimbus-jenkins']['mbj']['pipeline_libraries'] = {}

default['nimbus-jenkins']['mbj']['seed_jobs'] = {}

default['nimbus-jenkins']['mbj']['script_approval']['approvals'] = [
  'method groovy.json.JsonSlurperClassic parseText java.lang.String',
  'method groovy.lang.GroovyObject getProperty java.lang.String',
  'method groovy.lang.GroovyObject invokeMethod java.lang.String java.lang.Object',
  'method hudson.model.Item getFullName',
  'method hudson.model.ItemGroup getAllItems java.lang.Class',
  'method hudson.model.ItemGroup getItem java.lang.String',
  'method hudson.model.Job addProperty hudson.model.JobProperty',
  'method hudson.model.Job getProperty java.lang.Class',
  'method hudson.model.Job removeProperty java.lang.Class',
  'method hudson.model.Saveable save',
  'method hudson.util.Secret getPlainText',
  'method java.io.File exists',
  'method java.io.File getName',
  'method java.lang.Class isArray',
  'method java.lang.Process getInputStream',
  'method java.lang.ProcessBuilder start',
  'method java.util.zip.ZipEntry getName',
  'method java.util.zip.ZipInputStream getNextEntry',
  'method jenkins.model.ParameterizedJobMixIn$ParameterizedJob setDisabled boolean',
  'method org.apache.commons.collections.KeyValue getKey',
  'method org.apache.commons.collections.KeyValue getValue',
  'method org.jenkinsci.plugins.matrixauth.AuthorizationContainer add java.lang.String',
  'method org.jenkinsci.plugins.workflow.support.actions.EnvironmentAction$IncludingOverrides getOverriddenEnvironment',
  'method org.yaml.snakeyaml.Yaml load java.lang.String',
  'new groovy.json.JsonSlurperClassic',
  'new hudson.security.AuthorizationMatrixProperty',
  'new java.io.File java.lang.String',
  'new java.lang.ProcessBuilder java.lang.String[]',
  'new java.util.HashMap',
  'new java.util.Properties',
  'new java.util.zip.ZipInputStream java.io.InputStream',
  'new org.yaml.snakeyaml.Yaml',
  'staticMethod groovy.json.JsonOutput toJson java.lang.Object',
  'staticMethod groovy.lang.GroovySystem getVersion',
  'staticMethod groovy.util.Eval me java.lang.String',
  'staticMethod hudson.util.Secret fromString java.lang.String',
  'staticMethod java.lang.String valueOf boolean',
  'staticMethod java.lang.String valueOf int',
  'staticMethod jenkins.model.Jenkins getInstance',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods drop java.lang.Object[] int',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods dropRight java.lang.Object[] int',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods eachDir java.io.File groovy.lang.Closure',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods eachLine java.io.File groovy.lang.Closure',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods findAll java.lang.Object groovy.lang.Closure',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods getAt java.lang.Object java.lang.String',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods getAt java.util.Collection java.lang.String',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods getText java.io.File',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods grep java.util.List java.lang.Object',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods invokeMethod java.lang.Object java.lang.String java.lang.Object',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods println java.lang.Object java.lang.Object',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods putAt java.lang.Object java.lang.String java.lang.Object',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods readLines java.io.File',
  'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods write java.io.File java.lang.String',
  'staticMethod org.codehaus.groovy.runtime.ScriptBytecodeAdapter unaryPlus java.lang.Object',
]
