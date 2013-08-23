tarsnap Cookbook
================

Install tarsnap from source, creates master key file and read only key file, and installs a simple backup
script you can put into cron.

Requirements
------------

#### Operating Systems

This has only been tested on the following OS:

* `Ubuntu 12.04 LTS`

Since it is very simple in nature, it should work on other distributions easily. Let me know if you have tested it on another distro and ill add it to the list, or you can submit a pull request.

#### Cookbooks

- `build-essential` - chef cookbook that installs build-essential tools for commands like make, g++, etc.

Attributes
----------

#### tarsnap::default

* `[:tarsnap][:install_only]` **Boolean** (default: false) Only builds and installs tarsnap. Use this if you already have a key you want to use on the box. This will not generate new keys.</td>

* `[:tarsnap][:private_key]` **String** (default: "/root/tarsnap.key") Location of private key file</tt></td>

* `[:tarsnap][:limited_private_key]` **String** (default: "/root/tarsnap-limited.key") Location of limited (read only) private key file</td>

* `[:tarsnap][:use_backup_script]` **Boolean** (default: "/root/tarsnap-limited.key") Whether or not to use the backup script and cron task.</tt></td>

* `[:tarsnap][:backup]` **Hash** (default: see below) A hash of all the variables associated with the simple backup script

Backup Settings:

```ruby
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
```

* `[:tarsnap][:conf]` **Hash** (default: see below) A hash of all the variables for the tarsnap config

Conf Settings

```ruby
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
```

Usage
-----

This recipe depends on a data bag called `tarsnap` with a data bag item called `user`.

The default recipe calls

```ruby
tarsnap_user = Chef::EncryptedDataBagItem.load("tarsnap", "user")
```

You will need two key/value pairs in the `user` item:

* username - your tarsnap username
* password - your tarsnap password

Then just include `tarsnap` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[tarsnap]"
  ]
}
```

Contributing
------------

1. Fork the repository on Github
2. Write your change
3. Submit a Pull Request using Github

License and Authors
-------------------
License: MIT
Authors: Glen Zangirolami
