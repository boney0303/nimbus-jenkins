name 'nimbus-jenkins'
maintainer 'Saas Engineering'
maintainer_email 'saaseng@nimbus.io'
license 'MIT'
description 'Installs/Configures nimbus-jenkins'

version '1.0.106'

supports 'centos', '>= 7.0'

issues_url 'https://git.nimbus.io/projects/PLATFORM/repos/nimbus-jenkins/browse'
source_url 'https://git.nimbus.io/projects/PLATFORM/repos/nimbus-jenkins/browse'

depends 'nimbus-iptables'
depends 'nimbus-splunk'
depends 'nimbus-yum'
depends 'docker', '~> 7.7'
