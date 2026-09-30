# nimbus-jenkins

**A Chef cookbook that provisions and configures a Jenkins CI controller
(and workers) as code.**

This cookbook builds a Jenkins host from a bare CentOS machine: it installs the
software and plugins, wires up security and credentials from AWS Secrets
Manager, and registers the shared library and seed job that bring the rest of
the platform to life. Nearly all Jenkins configuration is expressed as Chef
attributes (converted to YAML for the MBJ and CASC plugins) rather than clicked
together in the UI.

It is the **provisioning layer** of a three-repository "Jenkins as code" stack:

| Repository | Layer | Responsibility |
|------------|-------|----------------|
| **`nimbus-jenkins`** (this repo) | Provisioning (Chef) | Builds the Jenkins host, installs plugins, registers the shared library and the seed job |
| [`nimbus-jenkins-jobs`](../nimbus-jenkins-jobs) | Jobs (Job DSL) | Declarative job/view/config definitions + the seed pipeline |
| [`nimbus-jenkins-shared-libraries`](../nimbus-jenkins-shared-libraries) | Library (Groovy) | Reusable pipeline steps and classes consumed by every generated job |

Once this cookbook converges a host, the seed job it registered checks out
`nimbus-jenkins-jobs`, which in turn generates every Jenkins job — each pipeline
loading `nimbus-jenkins-shared-libraries` via `@Library('saas')`.

> This is a **generic template**. Every organisation-specific value has been
> replaced with a named placeholder (see
> [Placeholder convention](#placeholder-convention)).

---

## Use case

- **Reproducible controllers** – rebuild a Jenkins master (or a worker) from
  code, not from a backup or tribal knowledge.
- **Config as data** – credentials, RBAC groups, notifiers, shared libraries,
  and seed jobs are all declared as Chef attributes.
- **Secrets stay in AWS** – the `nimbus_jenkins_secret` resource reads values from
  AWS Secrets Manager at converge time; nothing sensitive is committed.

---

## How it fits together

```
  Chef converge (this cookbook)
        │  installs Jenkins + plugins, applies MBJ & CASC config,
        │  reads AWS secrets, registers the "saas" shared library
        ▼
  Seed job "Seed-PlatformTeam"  ──▶  clones nimbus-jenkins-jobs
        │                              runs seed/master.groovy
        ▼
  All Jenkins jobs generated    ──▶  each pipeline uses @Library('saas')
                                      from nimbus-jenkins-shared-libraries
```

Two configuration engines do the heavy lifting (see [Design](#design)):

- **MBJ** – [My Bloody Jenkins](https://github.com/odavid/my-bloody-jenkins):
  credentials, security, seed jobs, pipeline libraries, notifiers, tools.
- **CASC** – [Configuration as Code](https://github.com/jenkinsci/configuration-as-code-plugin):
  system message, git SCM, location, and other unclassified settings.

---

## Quick start

```bash
# 1. Fetch dependency cookbooks
berks install

# 2. Lint + unit test
rake              # or: cookstyle && rspec

# 3. Converge locally with Test Kitchen
kitchen converge
```

- Default entry point is the **`default`** recipe, which calls **`master`**.
- To build a worker instead, use the **`worker`** recipe.
- Provisioning-time configuration (credentials, seed jobs, LDAP, etc.) is passed
  in via the node/environment JSON — **do not hard-code your values into the
  cookbook**; see [Schema](#schema) at the end of this file.

---

## Repository layout

```
recipes/            Chef recipes. `default` → `master`; underscore-prefixed
                    recipes (_mbj, _casc, _plugins, _secrets, ...) are internal.
attributes/         Default attributes under node['nimbus-jenkins'][...]
                    (master, mbj, casc, mbj_data, plugins, worker, ...).
libraries/          Ruby helpers: NimbusJenkins module (ec2, secret) and the
                    NimbusJenkinsCascHelper / NimbusJenkinsMbjHelper YAML helpers.
resources/          Custom resource `secret` (invoked as nimbus_jenkins_secret).
templates/          ERB templates (jenkins.service, ec2 cloud userdata, CASC/MBJ
                    configs, ssh/git config, ...).
files/default/      Static files, incl. the vendored my-bloody-jenkins/ project.
metadata.rb         Cookbook name (nimbus-jenkins), version, and dependencies.
Berksfile           Dependency sources (nimbus-iptables, nimbus-splunk, nimbus-yum).
test/, spec/        InSpec integration tests and ChefSpec unit tests.
```

---

## Placeholder convention

The same placeholders are used across all three repos:

| Placeholder | What it represents |
|-------------|--------------------|
| `nimbus` / `nimbus-jenkins` | Your company / cookbook name — drives the `NimbusJenkins` Ruby module, the `nimbus_jenkins_secret` resource, and every `node['nimbus-jenkins'][...]` attribute |
| `skyline` | Your Git project / Chef org namespace |
| `saaseng` | The team that owns shared infra / credentials |
| `git.nimbus.io` | Your Git host |
| `saaseng@nimbus.io` | Ops / admin contact email |
| `ldap-<region>.nimbus.io`, `dc=nimbus,dc=io` | Your LDAP server and base DN |

> **Note on the cookbook name:** Chef derives the custom-resource prefix from the
> cookbook name, so `nimbus-jenkins` → `nimbus_jenkins_secret`. If you rename the
> cookbook, rename the `NimbusJenkins*` Ruby modules and the `nimbus_jenkins_secret`
> resource together, or the resource will fail to resolve.

---

## Adapting this to your organisation

1. **Cookbook name** – rename the cookbook (`metadata.rb`), the `NimbusJenkins`
   Ruby modules (`libraries/`), and the `nimbus_jenkins_secret` resource together.
2. **Dependencies** – `Berksfile` / `metadata.rb` reference `nimbus-iptables`,
   `nimbus-splunk`, `nimbus-yum`; point these at your own cookbooks.
3. **Seed job** – the `mbj_data.seed_jobs` entry points at
   `git.nimbus.io/saaseng/nimbus-jenkins-jobs.git`; update the remote and
   `credentialsId`.
4. **Shared library** – registered as the `saas` global library pointing at
   `nimbus-jenkins-shared-libraries`; update the remote in `mbj_data.pipeline_libraries`.
5. **LDAP / email / git host** – see `attributes/mbj.rb` and `attributes/casc.rb`.

> The `files/default/my-bloody-jenkins/` directory is a vendored copy of the
> upstream open-source [My Bloody Jenkins](https://github.com/odavid/my-bloody-jenkins)
> project and is intentionally left unmodified.

---

## Requirements

### Platforms

- CentOS v7.x

### Chef

- Chef 12.14+

### Cookbooks Dependencies

 - nimbus-iptables
 - nimbus-splunk
 - nimbus-yum
 - docker  ~> 7.2.2
 - poise-python

## Attributes

In order to keep the README manageable and in sync with the attributes, this cookbook documents attributes inline. The usage instructions and default values for attributes can be found in the individual attribute files.

### Attribute Hierarchy
- node['nimbus-jenkins']['master'] - used for master configuration using Chef resources
- node['nimbus-jenkins']['mbj'] - converted directly to YAML for use by MBJ
- node['nimbus-jenkins']['casc'] - converted directly to YAML for use by CASC
- node['nimbus-jenkins']['mbj_data'] - data destined for MBJ but needs supplementary processing


## Recipes

*Recipes whose names are prefixed with underscores are not meant to be invoked directly.*
- _casc - Uses **Configuration as Code** plugin to configure Jenkins host.
- _docker - Configures docker application and settings
- _ec2_cloud - Creates configurations to use AWS EC2 instances for worker nodes.
- _jenkins_ssh - Setup jenkins user ssh settings.
- _mbj - Uses **My Bloody Jenkins** paradigm to configure Jenkins host. Most aspects of the Jenkins application are configured using this method.
- _plugins - Installs plugins for Jenkins application.
- _software - Configures all the basic software needed for a Jenkins.
- _support_extras - Additional/optional software used on Jenkins host. (Jobs using these resources should be migrated to use Docker containers that contain these elements.)
- _support_blitz - resources needed to support a Blitz-application environment.
- _support_sreops - resources needed to support a Controller-application environment.
- _system - Catch-all for miscellaneous resources not covered elsewhere.
- _yum - Configures all yum repos and resources.
- default - The default recipe will call **master** recipe.
- master - invokes all other recipes and configures resources needed to build a master.
- worker - invokes all other recipes and configures resources needed to build a worker.

## Design
Jenkins does not lend itself to a single, easy-to-use, configuration method. Add to that the fact that there are over 2000 plugins and it only gets more complex. Groovy scripts provide the most complete method of configuration of Jenkins in an "Infrastructure as Code" paradigm.

This wrapper cookbook uses 2 main methods to configure Jenkins, in addition to normal Chef resources.

- mbj - [My Bloody Jenkins](https://github.com/odavid/my-bloody-jenkins) - these are comprised of a Groovy script, **configLoader.groovy**, that read/apply configuration from a YAML file on startup from **node['nimbus-jenkins']['mbj_config']['home']**.
- casc - [Configuration as Code Plugin](https://github.com/jenkinsci/configuration-as-code-plugin) - this plugin reads/applies configuration from a YAML file in **node['nimbus-jenkins']['casc_dir']**

The "mbj" project provides a process to create a Jenkins host, configure most settings, set credentials, setup seed jobs, etc. It does this by using the "hook" that Jenkins has during startup of looking for a script in the __bootstrap__ directory (default - /var/lib/jenkins/init.groovy.d on CentOS).

Here are the items managed by the __MBJ__ project that are implemented in this cookbook.
- Credentials
- Environment Variables
- General
- JobDSLScripts
- Notifiers
- PipelineLibraries
- Roles and Permissions
- ScriptApproval
- Security
- SeedJobs
- Tools

Here are the items managed by the __CASC__ project that are implemented in this cookbook.
- crumbIssuer
- disableRememberMe
- disabledAdministrativeMonitors
- systemMessage
- queueItemAuthenticator
- tool
- gitscm
- location

Both configuration methods use YAML so we convert our Chef Attributes into YAML using the Library Helpers.

## Custom Resource: `secret`
This resource will read from AWS secrets and can be used to assign values to resources. The custom resource does not modify the returned value in any way and only supports text. Invoke the resource:
```
nimbus_jenkins_secret 'name of my secret in AWS' do
  action :get
  return_key 'return key in node.run_state`
  compile_time true
end
```
The value of return_key refers to the location in node.run_state of where the returned value will be stored. To retrieve this value, use a distinctive name within `node.run_state`.

### Here is a full example os the use-case where we want to read the value of an AWS Secret. It is stored within the node.run_state using the value supplied for the argument, **return_key**, 'my-secret':
```
nimbus_jenkins_secret 'my-secret' do
  action :get
  return_key 'my-secret'
  compile_time true
end
```

### Used with an attribute
```
node.override['cookbook']['attribute]['my-secret'] = node.run_state['my-secret']
```
### Used with a resource
```
file node['nimbus-jenkins']['home'] + '/.ssh/id_rsa.pub' do
  owner node['nimbus-jenkins']['user']
  group node['nimbus-jenkins']['group']
  content lazy { node.run_state['my-secret'] }
  mode '00644'
end
```
*Note: If the AWS Secret does not exist, the return value will be nil.*

## Reading AWS Secrets and Creating Credentials/RBAC Groups/Notifiers/Libraries/SeedJobs
Using **MBJ**, we can create:
- Credentials
- RBAC Groups
- Notifiers
- Libraries
- SeedJobs

### Credential Examples
__MBJ__ creates Jenkins credentials on the host. Using the custom resource, `nimbus_jenkins_secret`, the cookbook reads values of the following attributes and attempts to read the AWS Secret stored there:

Attributes Branches:
- (list) node['nimbus-jenkins']['mbj_data']['credentials']['sshkey']
- (list) node['nimbus-jenkins']['mbj_data']['credentials']['text']
- (list) node['nimbus-jenkins']['mbj_data']['credentials']['userpass']

Attribute Usage:
- jenkins_credentials_id: the id that will be created/updated on the Jenkins instance
- description: the description visible on the Jenkins instance
- aws_secret_id: the id used within AWS that you want to access

Optional attributes for sshkey
- username: the username that will be stored with the id on the Jenkins instance
- - if set, this sshkey will be used to create a Jenkins Credential
- dot_ssh_filename: filename within /var/lib/jenkins/.ssh
-  - if set, this sshkey will be created in /var/lib/jenkins/.ssh and specified within the ssh client config

Optional attributes for userpass credentials(required)
- username: the username that will be stored with the id on the Jenkins instance

Attibutes added to the environment json - DO NOT ADD YOUR VALUES TO COOKBOOK:
```
"nimbus-jenkins": {
  "mbj_data": {
    "credentials": {
      "sshkey": [
        {
          "jenkins_credentials_id": "Jenkins Credential ID",
          "description": "Jenkins Credentials description",
          "aws_secret_id": "AWS Secret Name #1",
          "username": "root@pdx-lev-d01-git-readonly"
        },
        {
          "jenkins_credentials_id": "Jenkins Credential ID",
          "description": "Jenkins Credentials description",
          "dot_ssh_filename": "if set, the name in Jenkins .ssh for the file",
          "aws_secret_id": "AWS Secret Name #2",
          "username": "root@pdx-lev-d01-git-readwrite"
        },
      ],
      "text": [
        {
          "jenkins_credentials_id": "Jenkins Credential ID",
          "description": "Jenkins Credentials description",
          "aws_secret_id": "AWS Secret Name #3"
        },
        {
          "jenkins_credentials_id": "Jenkins Credential ID",
          "description": "Jenkins Credentials description",
          "aws_secret_id": "AWS Secret Name #4"
        }
      ],
      "userpass": [
        {
          "jenkins_credentials_id": "Jenkins Credential ID",
          "description": "Jenkins Credentials description",
          "aws_secret_id": "AWS Secret Name #5",
          "username": "Jenkins Credential Username"
        },
        {
          "jenkins_credentials_id": "Jenkins Credential ID",
          "description": "Jenkins Credentials description",
          "aws_secret_id": "AWS Secret Name #6",
          "username": "Jenkins Credential Username"
        }
      ]
    }
  }
}
```
### RBAC Group Examples
__MBJ__ creates Jenkins RBAC groups on the host. These top-level groups are pre-assigned lists of permissions that are stored at node['nimbus-jenkins']['static']['permissions'][TOP_LEVEL_GROUPNAME]:

Attributes Branches:
- (list) node['nimbus-jenkins']['mbj_data']['security']['groups']['admins']
- (list) node['nimbus-jenkins']['mbj_data']['security']['groups']['powerusers']
- (list) node['nimbus-jenkins']['mbj_data']['security']['groups']['users']

Example that assigns the LDAP groups, 'ops' and 'role-security.jenkins-tools-admin', to the ADMIN role:
```
"nimbus-jenkins": {
  "mbj_data": {
    "security": {
      "groups": {
        "admins": [
          "ops",
          "role-security.jenkins-tools-admin"
        ],
        "powerusers": [],
        "users": []
      }
    }
  }
}
```

### Notifier Examples
__MBJ__ creates Jenkins notifiers on the host. With this resource, the value for "tokenCredentialsId" should already exist and should be the same `name` as a secret retrieved from `node['nimbus-jenkins']['mbj_data']['credentials']['text']`

Attributes Branch:
- (map) node['nimbus-jenkins']['mbj_data']['notifiers']

Attribute Usage:
- tokenCredentialsId: this should be the same as **jenkins_credentials_id** created in the credentials section
- as needed, specific to each notifier

Example that creates a slack notifier:
```
"nimbus-jenkins": {
  "mbj_data": {
    "notifiers": {
      "slack": {
        "teamDomain": "nimbus",
        "botUser": false,
        "room": "saas-ops-dev",
        "tokenCredentialsId": "slack-integration-token"
      }
    }
  }
}
```
-
### Library Examples
__MBJ__ creates Jenkins shared library on the host. With this resource, the value for "credentialsId" should already exist and should be the same `name` as a secret retrieved from `node['nimbus-jenkins']['mbj_data']['credentials']['sshkeys']`

Attributes:
- (map) node['nimbus-jenkins']['mbj_data']['pipeline_libraries']

Attribute Usage:
- (key) "name": the actual name in Jenkins for this shared library
- source:remote: full URL to .git repository
- source:credentialsId: sshkey needed for access. This should be the same as **jenkins_credentials_id** created in the credentials section
- defaultVersion: version to use, or "master" to follow master branch
- implicit: loading of library, **true** autoloads library for EVERY job
- allowVersionOverride: within a job, permit a different version to be used
- includeInChangesets: changes to library are listed on job summary

Example that creates a shared library:
```
"nimbus-jenkins": {
  "mbj_data": {
    "pipeline_libraries": {
      "infralib": {
        "source": {
          "remote": "ssh://git@git.nimbus.io:7999/INFENG/infralib.git",
          "credentialsId": "root@pdx-lev-d01-git-readonly"
        },
        "defaultVersion": "master",
        "implicit": false,
        "allowVersionOverride": true,
        "includeInChangesets": true
      }
    }
  }
}
```
-
### SeedJob Examples
__MBJ__ creates Seed Job on the host. With this resource, the value for "credentialsId" should already exist and should be the same `name` as a secret retrieved from `node['nimbus-jenkins']['mbj_data']['credentials']['sshkeys']`

Attributes:
- (map) node['nimbus-jenkins']['mbj_data']['seed_jobs']

Attribute Usage:
- (key) "name": the actual name in Jenkins for this seed job
- source:remote: full URL to .git repository
- source:credentialsId: sshkey needed for access. This should be the same as **jenkins_credentials_id** created in the credentials section
- source:branch: version to use, branch name, or "master" to follow master branch
- triggers:pollScm: schedule to check repo for changes
- triggers:periodic: schedule of job autorun
- executeWhen: "always"

example that creates a seed job:
```
"nimbus-jenkins": {
  "mbj_data": {
    "seed_jobs": {
      "Seed-PlatformTeam": {
        "source": {
          "remote": "ssh://git@git.nimbus.io:7999/saaseng/nimbus-jenkins-jobs.git",
          "credentialsId": "saaseng-readonly",
          "branch": "master"
        },
        "triggers": {
          "pollScm": "H H * 1-11 *",
          "periodic": "H H * 1-11 *"
        },
        "pipeline": "seed/master.groovy",
        "executeWhen": "always"
      }
    }
  }
}
```

# Schema
```
"nimbus-jenkins": {
  "casc":{
    "jenkins": {
      "systemMessage": "Chef Server: CHEF URL\n\n"
    },
    "unclassified": {
      "gitscm": {
        "globalConfigEmail": "EMAIL",
        "globalConfigName": "Jenkins ENVIRONMENT"
      },
      "location": {
        "adminAddress": "EMAIL",
        "url": "JENKINS URL"
      }
    }
  },
  "mbj":{
    "environment": {}
    "security": {
        "server": "ldaps://LDAP SERVER"
    },
    "script_approval": {
        "approvals": []
    }
  },
  "mbj_data": {
    "credentials": {
      "sshkey": [
        {
          "jenkins_credentials_id": "Jenkins Credential ID",
          "description": "DESCRIPTION1",
          "dot_ssh_filename": "FILENAME in Jenkins home dir/.ssh",
          "aws_secret_id": "AWS Secret ID",
          "username": "Username of SSH Key"
        },
      ],
      "text": [
        {
          "jenkins_credentials_id": "Jenkins Credential ID",
          "description": "DESCRIPTION1",
          "aws_secret_id": "AWS Secret ID"
        }
      ],
      "userpass": [
        {
          "jenkins_credentials_id": "Jenkins Credential ID",
          "description": "DESCRIPTION1",
          "aws_secret_id": "AWS Secret ID",
          "username": "username"
        }
      ]
    },
    "security": {
      "groups": {
        "admins": [],
        "powerusers": [],
        "users": []
      }
    },
    "notifiers": {
      "slack": {
        "teamDomain": "nimbus",
        "botUser": false,
        "room": "CHANNEL",
        "tokenCredentialsId": "ID"
      }
    },
    "pipeline_libraries": {
      "NAME1": {
        "source": {
          "credentialsId": "ID",
          "remote": "GIT URL"
        },
        "defaultVersion": "master",
        "implicit": false,
        "allowVersionOverride": true,
        "includeInChangesets": true
      },
      "NAME2": {
        "source": {
          "credentialsId": "ID",
          "remote": "GIT URL"
        },
        "defaultVersion": "master",
        "implicit": true,
        "allowVersionOverride": true,
        "includeInChangesets": true
      }
    },
    "seed_jobs": {
      "NAME1": {
        "source": {
          "remote": "GIT URL",
          "credentialsId": "ID",
          "branch": "master"
        },
        "triggers": {
          "pollScm": "H H * 1-11 *",
          "periodic": "H H * 1-11 *"
        },
        "pipeline": "SCRIPT",
        "executeWhen": "always"
      }
    }
  }
}

```
