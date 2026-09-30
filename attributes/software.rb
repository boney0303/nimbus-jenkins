# Cookbook:: nimbus-jenkins
# Attributes:: software

# additional software settings

# https://packages.chef.io/files/stable/chef-workstation/21.4.365/el/7/chef-workstation-21.4.365-1.el7.x86_64.rpm
# https://packages.chef.io/files/stable/chef-workstation/22.5.923/el/7/chef-workstation-22.5.923-1.el7.x86_64.rpm
# https://packages.chef.io/files/stable/chef-workstation/22.7.1006/el/7/chef-workstation-22.7.1006-1.el7.x86_64.rpm

default['nimbus-jenkins']['chef-workstation'] = {
  'rpm' => 'chef-workstation-22.10.1013-1.el7.x86_64.rpm',
  'version' => '22.10.1013',
  'source' => 'https://packages.chef.io/files/stable/chef-workstation',
}

default['nimbus-jenkins']['docker']['version'] = '20.10.10'

# versioned RPMs
default['nimbus-jenkins']['master']['packages'] = {
  'jenkins' => '2.387.2-1.1',
}

# versioned Python pip2 packages
default['nimbus-jenkins']['versioned_pip2_packages'] = {
  'ansible' => '2.0.2.0',
  'bcrypt' => '3.1.6',
  'paramiko' => '2.4.2',
  'boto3' => '1.7.57',
  'docopt' => '0.6.2',
  'termcolor' => '1.1.0',
  'terrafile' => '0.3.3',
  'netaddr' => '0.7.19',
  'mysqlclient' => '1.3.12',
  'ujson' => '1.19',
}

# unversioned Python pip2 packages
default['nimbus-jenkins']['pip2_packages'] = %w()

# versioned Python pip3 packages
default['nimbus-jenkins']['versioned_pip3_packages'] = {
  'bcrypt' => '3.2.2',
  'cryptography' => '2.3',
  'click' => '7.1.2',
  'fabric' => '2.4',
  'python-nmap' => '0.6.4',
  'pyyaml' => '5.4.1',
}

# unversioned Python pip3 packages
default['nimbus-jenkins']['pip3_packages'] = %w(awacs boto boto3 dnspython mysqlclient netaddr pbincli pingdom PingdomLib requests setuptools termcolor terrafile terraform-external-data)

# packer settings
# https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2_linux_amd64.zip
# find checksum on linux: sha256sum <zip filename>
default['nimbus-jenkins']['packer']['url_base'] = 'https://releases.hashicorp.com/packer'
default['nimbus-jenkins']['packer']['version'] = '1.8.6'
default['nimbus-jenkins']['packer']['dist_name'] = "packer_#{node['nimbus-jenkins']['packer']['version']}_linux_amd64"
default['nimbus-jenkins']['packer']['dist_filename'] = "packer_#{node['nimbus-jenkins']['packer']['version']}_linux_amd64.zip"
default['nimbus-jenkins']['packer']['checksum'] = '57d0411e578aea62918d36ed186951139d5d49d44b76e5666d1fbf2427b385ae'

# kubectl
# curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.7/2022-10-31/bin/linux/amd64/kubectl
default['nimbus-jenkins']['kubectl']['source'] = 'https://amazon-eks.s3-us-west-2.amazonaws.com'
default['nimbus-jenkins']['kubectl']['version'] = '1.24.7'
default['nimbus-jenkins']['kubectl']['release'] = '2022-10-31'
default['nimbus-jenkins']['kubectl']['uri'] = node['nimbus-jenkins']['kubectl']['version'] + \
                                            '/' + node['nimbus-jenkins']['kubectl']['release'] + \
                                            '/bin/linux/amd64/kubectl'

default['nimbus-jenkins']['kubectl']['url'] = node['nimbus-jenkins']['kubectl']['source'] + \
                                            '/' + node['nimbus-jenkins']['kubectl']['uri']

default['nimbus-jenkins']['kubectl']['checksum'] = 'd577810dec7ceffec97479870a45ae257cb149221cf005ee3609dfbd6812c2ae'

# helm3
# https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
default['nimbus-jenkins']['helm']['source'] = 'https://get.helm.sh'
default['nimbus-jenkins']['helm']['version'] = 'v3.7.1'
default['nimbus-jenkins']['helm']['archive'] = "helm-#{node['nimbus-jenkins']['helm']['version']}-linux-amd64.tar.gz"
default['nimbus-jenkins']['helm']['url'] = "#{node['nimbus-jenkins']['helm']['source']}/#{node['nimbus-jenkins']['helm']['archive']}"

# aws cli version 2
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html#cliv2-linux-install
# example url: https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip"
# default['nimbus-jenkins']['awscli']['url_base'] = 'https://awscli.amazonaws.com/'
# default['nimbus-jenkins']['awscli']['version'] = '2.1.25'
# default['nimbus-jenkins']['awscli']['prefix'] = ''
# default['nimbus-jenkins']['awscli']['archive'] = "awscli-exe-linux-x86_64-#{node['nimbus-jenkins']['awscli']['version']}.zip"
# default['nimbus-jenkins']['awscli']['url'] = "#{node['nimbus-jenkins']['awscli']['url_base']}/#{node['nimbus-jenkins']['awscli']['prefix']}/#{node['nimbus-jenkins']['awscli']['archive']}"
# default['nimbus-jenkins']['awscli']['install_command'] = 'aws/install -i /usr/local/aws-cli -b /usr/local/bin'

# aws cli version 1
# https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html
# example url: https://s3.amazonaws.com/aws-cli/awscli-bundle-1.16.312.zip
default['nimbus-jenkins']['awscli']['url_base'] = 'https://s3.amazonaws.com/'
default['nimbus-jenkins']['awscli']['version'] = '1.19.6'
default['nimbus-jenkins']['awscli']['prefix'] = 'aws-cli'
default['nimbus-jenkins']['awscli']['archive'] = "awscli-bundle-#{node['nimbus-jenkins']['awscli']['version']}.zip"
default['nimbus-jenkins']['awscli']['url'] = "#{node['nimbus-jenkins']['awscli']['url_base']}/#{node['nimbus-jenkins']['awscli']['prefix']}/#{node['nimbus-jenkins']['awscli']['archive']}"
default['nimbus-jenkins']['awscli']['install_command'] = 'awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws'

# sops
default['nimbus-jenkins']['sops']['rpm'] = 'sops-3.2.0-1.x86_64.rpm'
default['nimbus-jenkins']['sops']['url'] = "https://github.com/mozilla/sops/releases/download/3.2.0/#{node['nimbus-jenkins']['sops']['rpm']}"

# opa
default['nimbus-jenkins']['opa']['source'] = 'https://openpolicyagent.org/downloads'
default['nimbus-jenkins']['opa']['version'] = 'v0.44.0'
default['nimbus-jenkins']['opa']['uri'] = "#{node['nimbus-jenkins']['opa']['version']}/opa_linux_amd64_static"
default['nimbus-jenkins']['opa']['url'] = "#{node['nimbus-jenkins']['opa']['source']}/#{node['nimbus-jenkins']['opa']['uri']}"

# tfenv - terraform version manager
default['nimbus-jenkins']['tfenv']['install_directory'] = "#{node['nimbus-jenkins']['home']}/.tfenv"
default['nimbus-jenkins']['tfenv']['terraform']['versions'] = %w(0.11.14 0.12.31 0.13.4 0.14.11 0.15.5 1.0.11 1.1.9 1.2.9 1.3.9 1.4.5 latest)
default['nimbus-jenkins']['tfenv']['giturl'] = 'https://github.com/tfutils/tfenv.git'

# tgenv - terragrunt version manager
default['nimbus-jenkins']['tgenv']['install_directory'] = "#{node['nimbus-jenkins']['home']}/.tgenv"
default['nimbus-jenkins']['tgenv']['terragrunt']['versions'] = %w(0.31.11 0.36.12 0.38.12 0.40.2 0.41.0 0.42.8 0.43.3 0.44.5 0.45.4 latest)
default['nimbus-jenkins']['tgenv']['giturl'] = 'https://github.com/cunymatthieu/tgenv.git'

default['nimbus-jenkins']['tgenv']['terragrunt']['old_versions'] = {
  '0.18.7' => '3a45138e77fb41e0884b9491c67dcdeacd06418cd10a1e16ea0cc03976f1b288',
  '0.24.4' => 'f65a22becc185af5291870b04653939cab0cee86beda97fd774feb6dc822b416',
}
