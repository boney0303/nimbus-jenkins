# Cookbook:: nimbus-jenkins
# Recipe:: _yum
#

# setup extras repo
yum_repository 'extras' do
  fastestmirror_enabled true
  gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
  baseurl 'https://$adrepo/$adbranch/yum/centos/$releasever/extras/$basearch'
  action :create
end

# setup Jenkins repo
yum_repository 'AD_jenkins' do
  baseurl node['nimbus-jenkins']['repo']['baseurl']
  description 'AD Jenkins repo'
  enabled true
  make_cache false
  gpgcheck false
end

# remove deprecated sbt repo
yum_repository 'bintray--sbt-rpm' do
  baseurl 'https://sbt.bintray.com/rpm'
  description 'bintray--sbt-rpm'
  enabled true
  gpgcheck false
  action :remove
end

# add sbt repo via https://www.scala-sbt.org/1.x/docs/Installing-sbt-on-Linux.html
yum_repository 'sbt-rpm' do
  baseurl 'https://repo.scala-sbt.org/scalasbt/rpm'
  description 'scala build tool repo'
  enabled true
  gpgcheck false
  make_cache false
end

# yum update daily - except kernel and jenkins
cron 'run-yum-update-daily' do
  command 'yum clean all; yum -y update --exclude=kernel* --exclude=jenkins*'
  hour '01'
  minute '1'
end
