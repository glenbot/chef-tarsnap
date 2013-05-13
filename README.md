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

* `[:tarsnap][:install_only]` **Boolean** (default: false) Only builds and install tarsnap. Use this if you already have a key you want to use on the box. This will not install keys or backup script.</td>

* `[:tarsnap][:private_key]` **String** (default: "/root/tarsnap.key") Location of private key file</tt></td>

* `[:tarsnap][:limited_private_key]` **String** (default: "/root/tarsnap-limited.key") String Location of limited (read only) private key file</td>

* `[:tarsnap][:use_backup_script]` **Boolean** (default: "/root/tarsnap-limited.key") Whether or not to use the backup script and cron task. In other words, you are just installing tarsnap and creating a key.</tt></td>

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
