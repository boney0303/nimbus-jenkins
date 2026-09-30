# Cookbook:: nimbus-jenkins
# Recipe:: _software_blitz
#

# install blitz virtualenv
directory node['nimbus-jenkins']['blitz']['packages']['path'] do
  action :nothing
  owner 'root'
  group 'root'
  mode '0755'
end

directory node['nimbus-jenkins']['blitz']['virtualenv']['path'] do
  action :nothing
  owner 'root'
  group 'root'
  mode '0755'
  notifies :create, "directory[#{node['nimbus-jenkins']['blitz']['packages']['path']}]", :before
end

execute 'install_virtualenv' do
  cwd node['nimbus-jenkins']['blitz']['virtualenv']['path']
  command "/usr/bin/python2 -m pip install #{node['nimbus-jenkins']['blitz']['virtualenv']['version']}"
  not_if { ::File.exist?("#{node['nimbus-jenkins']['blitz']['virtualenv']['path']}/bin/activate") }
  notifies :create, "directory[#{node['nimbus-jenkins']['blitz']['virtualenv']['path']}]", :before
end

execute 'create_blitz_virtualenv' do
  cwd node['nimbus-jenkins']['blitz']['virtualenv']['path']
  command 'virtualenv -p /usr/bin/python2 .'
  notifies :run, 'execute[install_virtualenv]', :before
  action :nothing
end

# install blitz python packages in virtualenv
node['nimbus-jenkins']['blitz']['versioned_pip_packages'].each do |this_package|
  execute 'install blitz python packages' do
    cwd node['nimbus-jenkins']['blitz']['virtualenv']['path']
    command <<~EOF
      source bin/activate && \
      pip install #{this_package} && \
      deactivate
    EOF
    not_if <<~EOF
      source bin/activate && \
      PACKAGES=$(pip freeze)  && \
      deactivate && \
      echo $PACKAGES | grep #{this_package}
    EOF
    notifies :run, 'execute[create_blitz_virtualenv]', :before
  end
end

# install virtualenv with python3, boto3 and ansible 4.0.0
directory node['nimbus-jenkins']['blitz']['virtualenv']['path_2'] do
  action :nothing
  owner 'root'
  group 'root'
  mode '0755'
  notifies :create, "directory[#{node['nimbus-jenkins']['blitz']['packages']['path']}]", :before
end

execute 'install_virtualenv_2' do
  cwd node['nimbus-jenkins']['blitz']['virtualenv']['path_2']
  command "/usr/bin/python2 -m pip install #{node['nimbus-jenkins']['blitz']['virtualenv']['version']}"
  not_if { ::File.exist?("#{node['nimbus-jenkins']['blitz']['virtualenv']['path_2']}/bin/activate") }
  notifies :create, "directory[#{node['nimbus-jenkins']['blitz']['virtualenv']['path_2']}]", :before
end

execute 'create_blitz_virtualenv_2' do
  cwd node['nimbus-jenkins']['blitz']['virtualenv']['path_2']
  command 'virtualenv -p /usr/bin/python2 .'
  notifies :run, 'execute[install_virtualenv_2]', :before
  action :nothing
end

# install blitz python packages in virtualenv
node['nimbus-jenkins']['blitz']['versioned_pip_packages_2'].each do |this_package|
  execute 'install blitz python packages' do
    cwd node['nimbus-jenkins']['blitz']['virtualenv']['path_2']
    command <<~EOF
      source bin/activate && \
      pip install #{this_package} && \
      deactivate
    EOF
    not_if <<~EOF
      source bin/activate && \
      PACKAGES=$(pip freeze)  && \
      deactivate && \
      echo $PACKAGES | grep #{this_package}
    EOF
    notifies :run, 'execute[create_blitz_virtualenv_2]', :before
  end
end

# install blitz python3 packages in virtualenv
node['nimbus-jenkins']['blitz']['versioned_pip3_packages'].each do |this_package|
  execute 'install blitz python packages' do
    cwd node['nimbus-jenkins']['blitz']['virtualenv']['path_2']
    command <<~EOF
      source bin/activate && \
      pip3 install #{this_package} && \
      deactivate
    EOF
    not_if <<~EOF
      source bin/activate && \
      PACKAGES=$(pip3 freeze)  && \
      deactivate && \
      echo $PACKAGES | grep #{this_package}
    EOF
    notifies :run, 'execute[create_blitz_virtualenv_2]', :before
  end
end

# install blitz packer
blz_packer_zipfile = Chef::Config[:file_cache_path] + "/#{node['nimbus-jenkins']['blitz']['packer']['dist_filename']}"
blz_packer_dir = node['nimbus-jenkins']['blitz']['packages']['path']
blz_packer_dest = "#{blz_packer_dir}/packer"
remote_file blz_packer_zipfile do
  source "#{node['nimbus-jenkins']['blitz']['packer']['url_base']}/#{node['nimbus-jenkins']['blitz']['packer']['version']}/#{node['nimbus-jenkins']['blitz']['packer']['dist_filename']}"
  owner 'root'
  group 'root'
  mode '0755'
  checksum node['nimbus-jenkins']['blitz']['packer']['checksum']
  not_if { ::File.exist?(blz_packer_dest) }
  notifies :run, 'execute[unzip_blitz_packer]', :immediately
  notifies :create, "directory[#{node['nimbus-jenkins']['blitz']['packages']['path']}]", :before
end

execute 'unzip_blitz_packer' do
  command "unzip -q -o #{blz_packer_zipfile} -d #{blz_packer_dir}"
  action :nothing
end
