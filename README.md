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
    <td><tt>[:tarsnap][:backup_script]</tt></td>
    <td>String</td>
    <td>Location of the backup shell script</td>
    <td><tt>/root/backup.sh</tt></td>
  </tr>
  <tr>
    <td><tt>[:tarsnap][:backup_log]</tt></td>
    <td>String</td>
    <td>Location of the log file used by the backup shell script</td>
    <td><tt>/var/log/tarsnap_backup.log</tt></td>
  </tr>
  <tr>
    <td><tt>[:tarsnap][:backup_retention]</tt></td>
    <td>Integer</td>
    <td>Number of days to retain backups. Used by the backup shell script</td>
    <td><tt>/var/log/tarsnap_backup.log</tt></td>
  </tr>
  <tr>
    <td><tt>[:tarsnap][:backup_directories]</tt></td>
    <td>Array</td>
    <td>Array of directories the backup script should back up.</td>
    <td><tt>['/var/www', '/home']</tt></td>
  </tr>
</table>

Usage
-----

This recipe depends on a data bag called `tarsnap` with a data bag item called `user`.

The recipe calls

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
