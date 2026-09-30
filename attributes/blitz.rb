# Cookbook:: nimbus-jenkins
# Attributes:: blitz
#

# Blitz Packages
default['nimbus-jenkins']['blitz']['packages']['path'] = '/usr/local/src/blz_py_libs'
default['nimbus-jenkins']['blitz']['virtualenv']['version'] = 'virtualenv==15.1.0'
default['nimbus-jenkins']['blitz']['virtualenv']['path'] = node['nimbus-jenkins']['blitz']['packages']['path'] + '/blz_ansible'
default['nimbus-jenkins']['blitz']['versioned_pip_packages'] = %w(ansible==2.4.5.0 botocore==1.17.62 boto==2.49.0 boto3==1.14.62 requests==2.27.1 git+https://github.com/nimbus/nimbus-rest-client.git)
default['nimbus-jenkins']['blitz']['virtualenv']['path_2'] = node['nimbus-jenkins']['blitz']['packages']['path'] + '/blz_ansible_4'
default['nimbus-jenkins']['blitz']['versioned_pip_packages_2'] = %w(ansible==4.0.0 botocore==1.17.62 boto==2.49.0 boto3==1.14.62 requests==2.27.1 git+https://github.com/nimbus/nimbus-rest-client.git)
default['nimbus-jenkins']['blitz']['versioned_pip3_packages'] = %w(Jinja2==2.11.3)
default['nimbus-jenkins']['blitz']['packer']['url_base'] = 'https://releases.hashicorp.com/packer'
default['nimbus-jenkins']['blitz']['packer']['version'] = '1.8.0'
default['nimbus-jenkins']['blitz']['packer']['dist_name'] = "packer_#{node['nimbus-jenkins']['blitz']['packer']['version']}_linux_amd64"
default['nimbus-jenkins']['blitz']['packer']['dist_filename'] = "packer_#{node['nimbus-jenkins']['blitz']['packer']['version']}_linux_amd64.zip"
default['nimbus-jenkins']['blitz']['packer']['checksum'] = '94c5d65386fa8f17e36d3496fbbdf18d3bfab01306aa8000c14656b63070b7c2'
# end of file
