# Cookbook:: nimbus-jenkins
# Attributes:: sreops

default['nimbus-jenkins']['sreops']['repository']['path'] = '/opt/repositories'

default['nimbus-jenkins']['sreops']['ses_smtp_user'] = 'dummy'
default['nimbus-jenkins']['sreops']['ses_token'] = 'dummy'

# SRE OPS venv
default['nimbus-jenkins']['sreops']['venv']['path'] = node['nimbus-jenkins']['home'] + '/opswork_python_3'
# OPS versioned Python2.7 pip packages
default['nimbus-jenkins']['sreops']['versioned_pip_2_7_packages'] = {
  'ansible' => '2.0.2.0',
  'bcrypt' => '3.1.6',
  'botocore' => '1.20.61',
  'docopt' => '0.6.2',
  'paramiko' => '2.4.2',
  'terraform-external-data' => '0.0.5',
}
# OPS versioned Python3 pip packages
default['nimbus-jenkins']['sreops']['versioned_pip_packages'] = {
    'ansible' => '2.9.9',
    'ansible-runner' => '1.4.6',
    'atlassian-python-api' => '2.1.2',
    'bcrypt' => '3.1.7',
    'boto' => '2.49.0',
    'boto3' => '1.17.1',
    'botocore' => '1.20.41',
    'certifi' => '2020.4.5.2',
    'cffi' => '1.14.0',
    'chardet' => '3.0.4',
    'click' => '7.1.2',
    'cryptography' => '2.9.2',
    'decorator' => '4.4.2',
    'Deprecated' => '1.2.10',
    'dnspython' => '2.0.0',
    'docutils' => '0.15.2',
    'idna' => '2.9',
    'importlib-resources' => '3.0.0',
    'Jinja2' => '2.11.2',
    'jira' => '3.2.0',
    'jmespath' => '0.10.0',
    'lockfile' => '0.12.2',
    'MarkupSafe' => '1.1.1',
    'netaddr' => '0.8.0',
    'oauthlib' => '3.1.0',
    'openpyxl' => '3.0.7',
    'pandas' => '1.1.5',
    'paramiko' => '2.7.1',
    'pexpect' => '4.8.0',
    'PingdomLib' => '2.0.3',
    'PingdomLib3' => '3.0.0',
    'progress' => '1.5',
    'psutil' => '5.7.3',
    'ptyprocess' => '0.6.0',
    'py' => '1.9.0',
    'pycparser' => '2.20',
    'PyMySQL' => '0.9.3',
    'PyNaCl' => '1.4.0',
    'python-daemon' => '2.2.4',
    'python-dateutil' => '2.8.1',
    'python-jenkins' => '1.8.0',
    'PyYAML' => '5.3.1',
    'requests' => '2.24.0',
    'requests-oauthlib' => '1.3.0',
    'retry' => '0.9.2',
    's3transfer' => '0.3.3',
    'six' => '1.15.0',
    'tabulate' => '0.8.7',
    'template' => '0.5.1',
    'termcolor' => '1.1.0',
    'texttable' => '1.6.7',
    'toml' => '0.10.1',
    'urllib3' => '1.25.9',
    'wrapt' => '1.12.1',
    'yml' => '0.0.1',
    'zipp' => '3.3.1',
}
