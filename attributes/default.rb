# NOTE: tarsnap username and password need to be placed in an encrypted data bag called "tarsnap"
# with the key "user". The json parameters should look like:
# { "username": "someemail@yourhost.com", "password": "yourpassword" }

# Install flag
# Use this if you want to only install tarsnap and not generate keys.
# Useful if you are restoring a server
default[:tarsnap][:install_only] = false

# Download information
default[:tarsnap][:version] = "1.0.33"
default[:tarsnap][:tarball_basename] = "tarsnap-autoconf-#{default[:tarsnap][:version]}"
default[:tarsnap][:tarball] = "#{default[:tarsnap][:tarball_basename]}.tgz"
default[:tarsnap][:download_url] = "https://www.tarsnap.com/download/#{default[:tarsnap][:tarball]}"
default[:tarsnap][:signature] = "0c0d825a8c9695fc8d44c5d8c3cd17299c248377c9c7b91fdb49d73e54ae0b7d"

# Key locations
default[:tarsnap][:private_key] = "/root/tarsnap.key"
default[:tarsnap][:limited_private_key] = "/root/tarsnap-limited.key"

# Default packages needed for tarsnap in Debian
# We are installing expect here so that we can run the tarsnap-keygen command
# in an automated fashion
default[:tarsnap][:packages] = %w{expect libssl-dev zlib1g-dev e2fslibs-dev}

# Tarsnap machine name. This gets passed to the 
# tarsnap comment when it creates the key file
default[:tarsnap][:machine] = node[:fqdn]

# toggle backup script. If true, it will install that backup
# script in templates and add it to cron with all the settings
default[:tarsnap][:use_backup_script] = true

# Default backup settings
# -----------------------
# The backup script that runs is really simple. If you don't want to use
# this script then just set default[:tarsnap][:use_backup_script] to false
# and use your own backup script
default[:tarsnap][:backup] = {
    # where backup script from template gets written to
    "script" => "/root/backup.sh",
    # backup script log file -- see backup.sh.erb template
    "log" => "/var/log/tarsnap_backup.log",
    # backup 1 hour intervals. You can use the following:
    # minute, hour, day, month. Please retain the space.
    "interval" => "1 hour",
    # remove backups that are 24 hours old
    # NOTE: this must match interval -- so if interval is 1 day, retention must be
    # somethins like 7 day
    "retention" => "24 hour",
    # backup script directories -- see backup.sh.erb template
    # backup the following directories on the system, a list of absolute paths
    # OVERRIDE ME!
    "directories" => ['/var/www', '/home'],
    # backup name. Will be prepended to a timestamp
    "name" => "backup"
}

# Default conf settings
# ---------------------
# These settings will get laid in /usr/local/etc/tarsnap.conf
default[:tarsnap][:conf] = {
    # Tarsnap cache directory
    "cache_dir" => "/usr/local/tarsnap-cache",
    # Tarsnap key file
    "key_file" => default[:tarsnap][:limited_private_key],
    # Don't archive files which have the nodump flag set
    "no_dump" => true,
    # Print statistics when creating or deleting archives
    "print_stats" => true,
    # Create a checkpoint once per GB of uploaded data.
    "checkpoint_bytes" => "1GB",
    # Use SI prefixes to make numbers printed by --print-stats more readable.
    "humanize_numbers" => false,
    # Aggressive network behaviour: Use multiple TCP connections when
    # writing archives.  Use of this option is recommended only in
    # cases where TCP congestion control is known to be the limiting
    # factor in upload performance.
    "aggressive_networking" => false,
    # Attempt to reduce tarsnap memory consumption.  This option
    # will slow down the process of creating archives, but may help
    # on systems where the average size of files being backed up is
    # less than 1 MB.
    "low_mem" => false,
    # Try even harder to reduce tarsnap memory consumption.  This can
    # significantly slow down tarsnap, but reduces its memory usage
    # by an additional factor of 2 beyond what the lowmem option does.
    "very_low_mem" => false,
    # Snapshot time.  Use this option if you are backing up files
    # from a filesystem snapshot rather than from a "live" filesystem.
    "snap_time" => nil
}
