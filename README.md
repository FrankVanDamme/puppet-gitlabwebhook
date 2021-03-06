# gitlabr10khook

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with gitlabr10khook](#setup)
    * [What gitlabr10khook affects](#what-gitlabr10khook-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with gitlabr10khook](#beginning-with-gitlabr10khook)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Webhook for updating Puppet using R10K from Gitlab repos

This is a simple Python webserver that accepts webhook PUSH notifications
from Gitlab, and runs R10k to bring your puppet server up to date. The newest
versions of the Python script no longer support monolithic repos

The Python script can also trigger e-mails to Footprints or OTRS ticketing
systems based on the commit mesage

This module will install the `0.4` release of the webhook by default

## Changelog

0.1.4
 - Fix Systemctl startup scripts

0.1.3 
 - Fix README
 - Add python-devel package requirement

0.1.2
 - Fix missing gcc package for psutil module install

0.1.1
 - Add psutil python module installation

0.1.0
 - Bump to 0.3 Tag of Webhook

## Setup

### What gitlabr10khook affects 

* Updates python-daemon module
* Installs pip
* Installs git
* Installs psutil python module
* Installs slackweb python module

### Setup Requirements 

Every effort was made such that this manifest should attempt to install 
everything it needs, but it expects python, pip, some modules, openssl
and git to be available

### Beginning with gitlabr10khook

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module. Below is a minimal declaration of the webhook

```
class { 'gitlabr10khook':
  server => {
    token => 'mytoken',
    user  => 'myuser',
    group => 'mygroup',
    pemfile => 'cert.pem',
   },
}
```

It's unlikely that the above will give you a fully functional install but
it should at least run. You will need to add the webhook to Your Gitlab
project - Instructions can be found at https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/web_hooks/web_hooks.md


##### Hiera Example
```
gitlabr10khook::server:
  token: 'mytoken'
  user: 'myuser'
  group: 'mygroup'
  pemfile: 'cert.pem'
gitlabr10khook::multimaster:
  enabled: true
  servers: '10.0.0.1,10.0.0.2'
```

## Usage

The webhook declaration is made up of the following seven hashes

* server
* log
* r10k
* legacy
* multimaster
* footprints
* otrs

The certificate for the python webserver, as defined by `pemfile` must be a PEM file that is a combination of
your certifacte and the key. 

Both E-mail based ticketing integrations assume that `FIX #120398` indicates that ticket 120398 has been 
resolved, if you just want to reference a ticket simply put `#120398`. You can reference multiple tickets
in a single commit. By default the ticketing system will only be updated when things are moved into the
branch that is defined to be your production environment (Default of `production`). 

## Reference

**Parameters**

Required parameters are indicated by **bold**, default values are in *italics*

`install` *`/opt/gitlab-puppet-webhook`*

Specifies the directory to clone the gitlab webhook into, this is done via a git clone

`python_dev`

The name of the python development package in your distribution; normally you wouldn't need to change this on Red Hat or Debian-like distributions (where they are python-devel and python-dev, respectively).

`install_deps` 

By default, an array of package names. By default, a number of build dependencies for python modules are managed. See params.pp for per-distribution defaults; you can copy this list and delete one or more items, or change the parameter to an empty array: *[]*

install_deps also includes the python_dev package (above)

`release` *`0.4`*

The TAG of https://github.com/vollmerk/gitlab-puppet-webhook you want to checkout and use

`server::port` *`8080`*

Specifies the TCP port that the python daemon should listen on for notifications from gitlab. This 
module does not adjust your firewall

**`server::token`** 

Sets the secret token that must be submitted with the push from gitlab, this requires newer versions of
gitlab, but is seen as a require security feature.

`server::method` *`branch`*

Defines the method to be used for deploying puppet modules to the server, branch is the only 

valid method, but it is kept due to legacy code. DEPRECATED

`server::prodname` *`production`*

The name of your production branch, this does not have to be `production`, it is used to determine if e-mails
should be sent based on the `emailmethod` parameter

`server::envdir` *`/etc/puppetlab/code/environments`*

The path where it should check out the puppet environments, this is only needed by the legacy code. DEPRECATED

**`server::user`**

Defines the user that the python daemon should run as, the daemon should be launched by root and will fork off to 
the specified user, also used for file permission setups

**`server::group`**

Used to make sure that permissions are set correctly

**`server:pemfile`**

SSL PEM file for the server, must be certificate + key

`server::daemon` *`true`*

Should the application fork off and disconnect, or remain connected to the terminal. Set to false for debug

`server::smtpserver` *`localhost`*

Hostname of your mailserver that will accept mail from the daemon

`server::emailfrom` *`gitlabhook@localhost`*

The FROM: address used on outgoing e-mail, you should change this as most restrictive smtp servers will reject @localhost mail

`server::emailmethod` *`production`*

Only send e-mails when the `server::prodname` branch is being modified, valid options are `production` `development`. If its 
set to development, e-mails will not be re-sent when you merge into production

`server::action` *`push`*

The action from Gitlab that the webhook should proccess

`log::filename` *`/var/log/gitlabr10khook.log`*

Define the file that the daemon should log to, will attempt to set correct permissions for this file on install

`log::maxsize` *`50331648`*

Set the max size of the log file (will be roated when reached). Defaults to 50MB

`log::level` *`WARNING`*

The Log level from the webhook daemon, valid options are `CRITICAL` `ERROR` `WARNING` `INFO` `DEBUG`

`r10k::config` *`/etc/puppetlabs/r10k/r10k.yaml`*

Path to the r10k config file, needed when launching r10k

`r10k::binary` *`/opt/puppetlabs/puppet/bin/r10k`*

Path to the r10k binary

`multimaster::enabled` *`false`*

Do we need to trigger builds on other puppet servers?

`multimaster::servers` *`undef`*

Comma seperated list of IPs or hostnames of the hosts that the webhook should attempt to run r10k on

`legacy::enabled` *`false`*

Legacy monolithic puppet module repo functionality, just don't use this... DEPRECATED

`legacy::path` *`legacy-modules`*

The path under your production environment where the legacy monolithic repo will be checked out

**`legacy::gitpath`**

Only required if `legacy::enabled=true` This is the git repo path for your monolithic puppet module pile

`footprints::enabled` *`false`*

Enable this to have the daemon send emails to Footprints on commit if a ticket is referenced via #12039
supports the use of FIX #12039 to close the ticket

**`footprints::project`**

Required if using footprints, the numeric value of the project that you wish ticket updates to be
submitted to, The system does not currently support multiple projects

**`footprints::email`**

Required if using footprints, the e-mail addres to end e-mail updates to, this assumes that your
footprints accepts e-mail commands

**`footprints::close`**

The status in your footprints that indicates that the ticket is closed, this is a string value

`otrs::enabled` *`false`*

Enable this to have the daemon send emails to an OTRS instance, OTRS must allow special headers
to be received, so that the updates appear to be from agents

**`otrs::email`**

E-mail address for your OTRS instance, updates will be sent here

## Limitations

Currently only implemented for CentOS and Debian, and only for systemd 

## Development

Contributions will be accepted, please make sure any code you commit follows
all of the Puppet Lint checks. Thanks!

Karl Vollmer <karl.vollmer@gmail.com>

