require File.join(File.dirname(__FILE__), 'ec2')

module NimbusJenkins
  module Secret
    include NimbusJenkins::Ec2

    def secret
      require 'aws-sdk-secretsmanager'

      Chef::Log.debug('Initializing the Secrets Manager Client')
      @secret ||= create_aws_interface(::Aws::SecretsManager::Client, region: new_resource.region)
    end
  end
end
