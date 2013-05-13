#
# Cookbook Name:: tarsnap
# Recipe:: default
#
# Author: Glen Zangiroami <http://github.com/glenbot>
#
# MIT Licensed
include_recipe "build-essential"

tarsnap_bin = "/usr/local/bin/tarsnap"
tarsnap_user = Chef::EncryptedDataBagItem.load("tarsnap", "user") 


def generate_cron_interval(interval)
    intervals = ["minute", "hour", "day", "month", "weekday"]
    # minute hour dom mon dow
    cron_times = "* */1 * * *"  # once an hour
    amount, type = interval.split()

    case type
        when "minute"
            cron_times = "*/#{amount} * * * *"
        when "hour"
            cron_times = "0 */#{amount} * * *"
        when "day"
            cron_times = "0 0 */#{amount} * *"
        when "month"
            cron_times = "0 0 0 */#{amount} *"
    end

    # return a Hash in the form of
    # {"weekday"=>"*", "day"=>"0", "hour"=>"0", "minute"=>"0", "month"=>"*/5"}
    return Hash[intervals.zip(cron_times.split())]
end

def generate_interval(interval)
    date_params = "+%F"
    _, type = interval.split()
    
    case type
        when "minute"
            date_params = "+%F-%M"
        when "hour"
            date_params = "+%F-%H"
        else
            date_params = "+%F"
    end

    return date_params
end

def generate_retention(retention)
    date_params = "-d-%s %s"
    amount, type = retention.split()
    params = ["#{amount}#{type}"]
    
    case type
        when "minute"
            params.push("+%F-%M")
        when "hour"
            params.push("+%F-%H")
        else
            params.push("+%F")
    end

    return date_params % params
end

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

if not node[:tarsnap][:install_only] and node[:tarsnap][:use_backup_script]
    interval = generate_interval(node[:tarsnap][:backup][:interval])
    retention = generate_retention(node[:tarsnap][:backup][:retention])

    # install the backup script
    template node[:tarsnap][:backup][:script] do
        source "backup.sh.erb"
        mode "0755"
        variables(
            :tarsnap_bin => tarsnap_bin,
            :interval => interval,
            :retention => retention
        )
    end

    intervals = generate_cron_interval(node[:tarsnap][:backup][:interval])

    cron "tarsnap_backup_cron" do
        minute "#{intervals['minute']}"
        hour "#{intervals['hour']}"
        day "#{intervals['day']}"
        month "#{intervals['month']}"
        weekday "#{intervals['weekday']}"
        command "#{node[:tarsnap][:backup][:script]} >> #{node[:tarsnap][:backup][:log]} 2>&1"
        only_if do
            File.exist?("#{node[:tarsnap][:backup][:script]}")
        end
    end
end


if not node[:tarsnap][:install_only]
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
end
