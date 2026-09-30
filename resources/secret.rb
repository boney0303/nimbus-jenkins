#
# Cookbook:: nimbus-jenkins
# Resource:: secret
#
unified_mode true

# => Define the Resource Properties
property :secret_name, String, name_property: true

# => Retrieval Properties
# => run_state key to put the Retrieved Value(s)
property :return_key, String

# => Create Properties
property :value, String
property :description, String

# => AWS Config
property :aws_access_key, String
property :aws_secret_access_key, String, sensitive: true
property :aws_session_token, String, sensitive: true
property :aws_assume_role_arn, String
property :aws_role_session_name, String
property :region, String, default: lazy { fallback_region }

include NimbusJenkins::Ec2 # needed for aws_region helper

action :create do
  if secret_exists?(new_resource.secret_name)
    Chef::Log.debug("Secret Exists: #{new_resource.secret_name}")
    # update the secret
    Chef::Log.debug("Update Secret: #{new_resource.secret_name}")
    request = {
      secret_id: new_resource.secret_name,
      secret_string: new_resource.value,
    }
    resp = secret.update_secret(request)
  else
    # create the secret
    Chef::Log.debug("Create Secret: #{new_resource.secret_name}")
    request = {
      name: new_resource.secret_name,
      secret_string: new_resource.value,
      description: new_resource.description,
    }
    resp = secret.create_secret(request)
  end
  node.run_state[new_resource.return_key] = resp.arn
end

action :get do
  if secret_exists?(new_resource.secret_name)
    # get the value
    Chef::Log.debug("Get Secret:  #{new_resource.secret_name}")

    request = {
      secret_id: new_resource.secret_name,
    }
    resp = secret.get_secret_value(request)
    node.run_state[new_resource.return_key] = resp.secret_string
    Chef::Log.debug("Show Secret:  #{resp.secret_string}")
  end
end

action_class do
  include NimbusJenkins::Secret

  # secret_exists - logic for checking if the secret exists
  def secret_exists?(secret_name)
    resp = secret.get_secret_value(secret_id: secret_name)
    if !resp.empty?
      true
    else
      false
    end
  rescue
    Chef::Log.debug("secret_exists? - Secret does not exist: #{secret_name}")
    false
  end
end
