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
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>[:tarsnap][:install_only]</tt></td>
    <td>Boolean</td>
    <td>Only builds and install tarsnap. Use this if you already have a key you want to use on the box. This will not install keys or backup script.</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>[:tarsnap][:private_key]</tt></td>
    <td>String</td>
    <td>Location of private key file</td>
    <td><tt>/root/tarsnap.key</tt></td>
  </tr>
  <tr>
    <td><tt>[:tarsnap][:limited_private_key]</tt></td>
    <td>String</td>
    <td>Location of limited (read only) private key file</td>
    <td><tt>/root/tarsnap-limited.key</tt></td>
  </tr>
  <tr>
    <td><tt>[:tarsnap][:use_backup_script]</tt></td>
    <td>Boolean</td>
    <td>Whether or not to use the backup script and cron task. In other words, you are just installing tarsnap and creating a key.</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>[:tarsnap][:backup]</tt></td>
    <td>Hash</td>
    <td>A hash of all the variables associate with the simple backup script</td>
    <td><tt>
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
      }```
    </tt></td>
  </tr>
</table>

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
