# NOTE: tarsnap username and password need to be placed in an encrypted data bag called "tarsnap"
# with the key "user". The json parameters should look like:
# { "username": "someemail@yourhost.com", "password": "yourpassword" }

# download information
default[:tarsnap][:version] = "1.0.33"
default[:tarsnap][:tarball_basename] = "tarsnap-autoconf-#{default[:tarsnap][:version]}"
default[:tarsnap][:tarball] = "#{default[:tarsnap][:tarball_basename]}.tgz"
default[:tarsnap][:download_url] = "https://www.tarsnap.com/download/#{default[:tarsnap][:tarball]}"
default[:tarsnap][:signature] = "0c0d825a8c9695fc8d44c5d8c3cd17299c248377c9c7b91fdb49d73e54ae0b7d"

# key settings
default[:tarsnap][:private_key] = "/root/tarsnap.key"
default[:tarsnap][:limited_private_key] = "/root/tarsnap-limited.key"

# default packages needed for tarsnap in debian
# we are installing expect here so that we can run the tarsnap-keygen command
default[:tarsnap][:packages] = %w{expect libssl-dev zlib1g-dev e2fslibs-dev}

# backup script location
default[:tarsnap][:backup_script] = "/root/backup.sh"

# backup script log file -- see backup.sh.erb template
default[:tarsnap][:backup_log] = "/var/log/tarsnap_backup.log"

# backup script retention -- see backup.sh.erb template
# backup will be deleted if they are older than 5 days
# Ideally this should be overriden by environment
default[:tarsnap][:backup_retention] = 5  # in days

# backup script directories -- see backup.sh.erb template
# backup the following directories on the system, a list of absolute paths
# OVERRIDE ME!
default[:tarsnap][:backup_directories] = ['/var/www', '/home']
