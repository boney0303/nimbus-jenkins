// this will add the relevant config for slaves for this Jenkins master

import com.amazonaws.services.ec2.model.InstanceType
import com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.Domain
import hudson.model.*
import hudson.plugins.ec2.AmazonEC2Cloud
import hudson.plugins.ec2.AMITypeData
import hudson.plugins.ec2.EC2Tag
import hudson.plugins.ec2.SlaveTemplate
import hudson.plugins.ec2.SpotConfiguration
import hudson.plugins.ec2.UnixData
import jenkins.model.Jenkins

// parameters
def SlaveTemplateParameters = [
  ami:                      '<%= @ami_id %>',
  associatePublicIp:        false,
  connectBySSHProcess:      true,
  connectUsingPublicIp:     false,
  customDeviceMapping:      '',

  deleteRootOnTermination:  true,
  description:              '<%= @description %>',
  ebsOptimized:             false,
  iamInstanceProfile:       '<%= @iamInstanceProfile %>',
  idleTerminationMinutes:   '10',

  initScript:               '<%= @initScript %>',
  instanceCapStr:           '<%= @instanceCap %>',
  jvmopts:                  '',
  labelString:              '<%= @labelString %>',
  launchTimeoutStr:         '600',

  numExecutors:             '<%= @numExecutors %>',
  remoteAdmin:              '<%= @remoteAdmin %>',
  remoteFS:                 '<%= @remoteFS %>',
  securityGroups:           <%= @securityGroups %>, // comma delimited with single quote around outside
  stopOnTerminate:          false,

  subnetId:                 '<%= @subnetId %>',
  tags:                     <%= @tags %>,
  tmpDir:                   '',
  type:                     '<%= @type %>',
  useDedicatedTenancy:      false,

  useEphemeralDevices:      false,
  usePrivateDnsName:        false,
  userData:                 '<%= @userData %>',
  zone:                     '<%= @zone %>'
]

def AmazonEC2CloudParameters = [
  cloudName:                '<%= @cloud_name %>',
  credentialsId:            '<%= @credentialsId %>',
  instanceCapStr:           '2',
  privateKey:               '''<%= @privateKey %>''',
  region:                   '<%= @region %>',
  useInstanceProfileForCredentials: true
]

// this can be used with DC2 and 'useInstanceProfileForCredentials' = false
// def AWSCredentialsImplParameters = [
//   id:           'added-via-groovy-scr',
//   description:  'Jenkins AWS IAM key',
//   accessKey:    '01234567890123456789',
//   secretKey:    '01345645657987987987987987987987987987'
// ]

// https://github.com/jenkinsci/aws-credentials-plugin/blob/aws-credentials-1.23/src/main/java/com/cloudbees/jenkins/plugins/awscredentials/AWSCredentialsImpl.java
// AWSCredentialsImpl aWSCredentialsImpl = new AWSCredentialsImpl(
//   CredentialsScope.GLOBAL,
//   AWSCredentialsImplParameters.id,
//   AWSCredentialsImplParameters.accessKey,
//   AWSCredentialsImplParameters.secretKey,
//   AWSCredentialsImplParameters.description
// )

AMITypeData aMITypeData = null

// https://github.com/jenkinsci/ec2-plugin/blob/ec2-1.38/src/main/java/hudson/plugins/ec2/SlaveTemplate.java
SlaveTemplate slaveTemplateAppd = new SlaveTemplate(

  SlaveTemplateParameters.ami,
  SlaveTemplateParameters.zone,
  null,
  SlaveTemplateParameters.securityGroups,
  SlaveTemplateParameters.remoteFS,

  InstanceType.fromValue(SlaveTemplateParameters.type),
  SlaveTemplateParameters.ebsOptimized,
  SlaveTemplateParameters.labelString,
  Node.Mode.NORMAL,
  SlaveTemplateParameters.description,

  SlaveTemplateParameters.initScript,
  SlaveTemplateParameters.tmpDir,
  SlaveTemplateParameters.userData,
  SlaveTemplateParameters.numExecutors,
  SlaveTemplateParameters.remoteAdmin,

  aMITypeData,
  SlaveTemplateParameters.jvmopts,
  SlaveTemplateParameters.stopOnTerminate,
  SlaveTemplateParameters.subnetId,
  [SlaveTemplateParameters.tags],

  SlaveTemplateParameters.idleTerminationMinutes,
  SlaveTemplateParameters.usePrivateDnsName,
  SlaveTemplateParameters.instanceCapStr,
  SlaveTemplateParameters.iamInstanceProfile,
  SlaveTemplateParameters.deleteRootOnTermination,

  SlaveTemplateParameters.useEphemeralDevices,
  SlaveTemplateParameters.useDedicatedTenancy,
  SlaveTemplateParameters.launchTimeoutStr,
  SlaveTemplateParameters.associatePublicIp,
  SlaveTemplateParameters.customDeviceMapping,

  SlaveTemplateParameters.connectBySSHProcess,
  SlaveTemplateParameters.connectUsingPublicIp
)

// https://github.com/jenkinsci/ec2-plugin/blob/ec2-1.41/src/main/java/hudson/plugins/ec2/AmazonEC2Cloud.java
AmazonEC2Cloud amazonEC2Cloud = new AmazonEC2Cloud(
  AmazonEC2CloudParameters.cloudName,
  AmazonEC2CloudParameters.useInstanceProfileForCredentials,
  AmazonEC2CloudParameters.credentialsId,
  AmazonEC2CloudParameters.region,
  AmazonEC2CloudParameters.privateKey,
  AmazonEC2CloudParameters.instanceCapStr,
  [slaveTemplateAppd],
  null,
  null
)

// get Jenkins instance
Jenkins jenkins = Jenkins.getInstance()

// get credentials domain
def domain = Domain.global()

// get credentials store
// def store = jenkins.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

// add credential to store - these will be added to the Credentials on the host
// store.addCredentials(domain, aWSCredentialsImpl)

//  make this idempotent
if ( jenkins.instance.clouds[<%= @cloudIndex %>] == null ) {
  // add cloud configuration
  jenkins.clouds.add(amazonEC2Cloud)
}
else {
  // update the AMI for the existing cloud config
  def temp = jenkins.clouds[<%= @cloudIndex %>].getTemplates()[0]
  temp.setAmi('<%= @ami_id %>')
}

// save current Jenkins state to disk
jenkins.save()
