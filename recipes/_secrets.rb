# Cookbook:: nimbus-jenkins
# Recipe:: _secrets
#

# get all file secrets and save in node_state[return_key]
node['nimbus-jenkins']['mbj_data']['credentials']['file'].each do |secret|
  next unless secret['jenkins_credentials_id']
  next unless secret['aws_secret_id']
  nimbus_jenkins_secret secret['aws_secret_id'] do
    action :get
    return_key secret['jenkins_credentials_id']
    compile_time true # ensure node.run_state is populated during compile phase(1)
  end
end

# get all sshkey secrets and save in node_state[return_key]
node['nimbus-jenkins']['mbj_data']['credentials']['sshkey'].each do |secret|
  next unless secret['jenkins_credentials_id']
  next unless secret['aws_secret_id']
  nimbus_jenkins_secret secret['aws_secret_id'] do
    action :get
    return_key secret['jenkins_credentials_id']
    compile_time true # ensure node.run_state is populated during compile phase(1)
  end
end

# get all text secrets and save in node_state[return_key]
node['nimbus-jenkins']['mbj_data']['credentials']['text'].each do |secret|
  next unless secret['jenkins_credentials_id']
  next unless secret['aws_secret_id']
  nimbus_jenkins_secret secret['aws_secret_id'] do
    action :get
    return_key secret['jenkins_credentials_id']
    compile_time true # ensure node.run_state is populated during compile phase(1)
  end
end

# get all username secrets and save in node_state[return_key]
node['nimbus-jenkins']['mbj_data']['credentials']['userpass'].each do |secret|
  next unless secret['jenkins_credentials_id']
  next unless secret['aws_secret_id']
  nimbus_jenkins_secret secret['aws_secret_id'] do
    action :get
    return_key secret['jenkins_credentials_id']
    compile_time true # ensure node.run_state is populated during compile phase(1)
  end
end
