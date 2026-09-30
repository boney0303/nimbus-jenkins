# Cookbook:: nimbus-jenkins
# Attributes:: permissions

# this group is always the same
default['nimbus-jenkins']['mbj']['security']['permissions']['authenticated'] = [
  'hudson.model.Hudson.Read',
]

default['nimbus-jenkins']['static']['permissions']['admin'] = [
  'hudson.model.Hudson.Administer',
  'GROUP:hudson.model.Hudson.Administer',
]

default['nimbus-jenkins']['static']['permissions']['powerusers'] = [
  'GROUP:com.cloudbees.plugins.credentials.CredentialsProvider.Create',
  'GROUP:com.cloudbees.plugins.credentials.CredentialsProvider.Delete',
  'GROUP:com.cloudbees.plugins.credentials.CredentialsProvider.ManageDomains',
  'GROUP:com.cloudbees.plugins.credentials.CredentialsProvider.Update',
  'GROUP:com.cloudbees.plugins.credentials.CredentialsProvider.View',
  'GROUP:hudson.model.Computer.Build',
  'GROUP:hudson.model.Computer.Configure',
  'GROUP:hudson.model.Computer.Connect',
  'GROUP:hudson.model.Computer.Create',
  'GROUP:hudson.model.Computer.Delete',
  'GROUP:hudson.model.Computer.Disconnect',
  'GROUP:hudson.model.Item.Build',
  'GROUP:hudson.model.Item.Cancel',
  'GROUP:hudson.model.Item.Configure',
  'GROUP:hudson.model.Item.Create',
  'GROUP:hudson.model.Item.Delete',
  'GROUP:hudson.model.Item.Discover',
  'GROUP:hudson.model.Item.Move',
  'GROUP:hudson.model.Item.Read',
  'GROUP:hudson.model.Item.ViewStatus',
  'GROUP:hudson.model.Item.Workspace',
  'GROUP:hudson.model.Run.Delete',
  'GROUP:hudson.model.Run.Replay',
  'GROUP:hudson.model.Run.Update',
  'GROUP:hudson.model.View.Configure',
  'GROUP:hudson.model.View.Create',
  'GROUP:hudson.model.View.Delete',
  'GROUP:hudson.model.View.Read',
  'GROUP:hudson.scm.SCM.Tag',
  'GROUP:jenkins.metrics.api.Metrics.HealthCheck',
  'GROUP:jenkins.metrics.api.Metrics.ThreadDump',
  'GROUP:jenkins.metrics.api.Metrics.View',
  'GROUP:org.jenkins.plugins.lockableresources.LockableResourcesManager.Reserve',
  'GROUP:org.jenkins.plugins.lockableresources.LockableResourcesManager.Unlock',
  'GROUP:org.jfrog.hudson.ArtifactoryPlugin.Promote',
  'GROUP:org.jfrog.hudson.ArtifactoryPlugin.Release',
]

default['nimbus-jenkins']['static']['permissions']['users'] = [
  'GROUP:hudson.model.Item.Build',
  'GROUP:hudson.model.Item.Cancel',
  'GROUP:hudson.model.Item.Read',
  'GROUP:hudson.model.Item.ViewStatus',
  'GROUP:hudson.model.Run.Update',
  'GROUP:hudson.model.View.Read',
  'GROUP:hudson.scm.SCM.Tag',
]
