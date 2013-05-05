#
# Cookbook Name:: tarsnap
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "build-essential"

tarsnap_bin = "/usr/local/bin/tarsnap"
tarsnap_user = Chef::EncryptedDataBagItem.load("tarsnap", "user") 


# install required packages
node[:tarsnap][:packages].each do |p|
    package p do
        action :install
    end
end

# download the package
remote_file "/tmp/#{node[:tarsnap][:tarball]}" do
    not_if do
        File.exists?("#{tarsnap_bin}")
    end
    checksum node[:tarsnap][:signature]
    source node[:tarsnap][:download_url]
    mode "0644"
end

# configure, make, install, and clean tarsnap
script "install_tarsnap" do
    not_if do
        File.exists?("#{tarsnap_bin}")
    end
    interpreter "bash"
    user "root"
    cwd "/tmp"
    code <<-EOH
    tar -xzvf #{node[:tarsnap][:tarball]}
    cd #{node[:tarsnap][:tarball_basename]}
    ./configure
    make all install clean
    EOH
end

# install the backup script
template node[:tarsnap][:backup_script] do
    source "backup.sh.erb"
    mode "0755"
    variables(
        :tarsnap_bin => tarsnap_bin
    )
end

# create initial private key and register box with tarsnap
bash "create_tarsnap_private_key" do
    not_if do
        File.exists?("#{node[:tarsnap][:private_key]}")
    end
    user "root"
    cwd "/tmp"
    code <<-EOF
    /usr/bin/expect -c 'spawn tarsnap-keygen --keyfile #{node[:tarsnap][:private_key]} --machine #{node[:fqdn]}  --user #{tarsnap_user['username']}
    expect "Enter tarsnap account password: "
    send "#{tarsnap_user['password']}\r"
    expect eof'
    EOF
end

# create the limited private key with only read/write
execute "create_tarsnap_limited_key" do
    not_if do
        File.exists?("#{node[:tarsnap][:limited_private_key]}")
    end
    command "tarsnap-keymgmt --outkeyfile #{node[:tarsnap][:limited_private_key]} -r -w #{node[:tarsnap][:private_key]}"
    user "root"
    group "root"
end
