# worker settings
default['nimbus-jenkins']['worker']['ami'] = ''
default['nimbus-jenkins']['worker']['ssh_template'] = 'ssh_config.erb'
default['nimbus-jenkins']['worker']['public_key_secret'] = 'infeng/jenkins-public-key'

default['nimbus-jenkins']['worker']['versioned_packages'] = {
  'sbt' => '1.2.8-0',
}

# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html
default['nimbus-jenkins']['worker']['versioned_gems'] = {
  'aws-sdk' => '~> 3',
}

default['nimbus-jenkins']['worker']['chef_role'] = 'default_jenkins_worker'

default['nimbus-jenkins']['worker']['gems'] = %w(knife-spork sshkey)

# install the latest Distro RPMs
default['nimbus-jenkins']['worker']['packages'] = {
  'PyYAML' => true,
  'autoconf' => true,
  'binutils' => true,
  'bind-utils' => true,
  'bison' => true,
  'bzip2' => true,
  'cyrus-sasl' => true,
  'cyrus-sasl-lib' => true,
  'cyrus-sasl-plain' => true,
  'dejavu-sans-fonts' => true,
  'flex' => true,
  'gcc' => true,
  'gcc-c++' => true,
  'gettext' => true,
  'git' => true,
  'java-1.8.0-openjdk' => false,
  'java-1.8.0-openjdk-devel' => false,
  'java-1.8.0-openjdk-headless' => false,
  'java-11-openjdk' => true,
  'java-11-openjdk-devel' => true,
  'jq' => true,
  'libcurl-devel' => true,
  'libtool' => true,
  'make' => true,
  'mysql' => true,
  'mysql-devel' => true,
  'openssl-devel' => true,
  'patch' => true,
  'pkgconfig' => true,
  'python-devel' => true,
  'python-httplib2' => true,
  'python-jinja2' => true,
  'python-paramiko' => true,
  'python-pip' => true,
  'python3' => true,
  'python3-devel' => true,
  'python3-libs' => true,
  'python3-pip' => true,
  'python3-setuptools' => true,
  'redhat-rpm-config' => true,
  'rpm-build' => true,
  'rpm-sign' => true,
  'rubygems' => true,
  'rubygems-devel' => true,
  'unzip' => true,
  'wget' => true,
  'yum-plugin-versionlock' => false,
}
