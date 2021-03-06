# Class: gitlabr10khook::config
# vim: set softtabstop=2 ts=2 sw=2 expandtab:
# ===========================
# This configures the gitlab-puppet-webhook that will take
# webhook triggers from gitlab and run r10k on your puppet server
# it currently only supports the PUSH mechanism
#
# Authors
# -------
# Karl Vollmer <karl.vollmer@gmail.com>
#
# Copyright
# ---------
# Copyright 2016 Karl Vollmer.
class gitlabr10khook::config inherits gitlabr10khook {

  # lint:ignore:variable_scope
  # Configure the Conf file
  file { "${gitlabr10khook::install}/webhook-puppet.conf":
    ensure  => file,
    mode    => '0640',
    owner   => 'root',
    group   => $gitlabr10khook::server['group'],
    content => template('gitlabr10khook/webhook-puppet.erb'),
  }

  $logfile = $gitlabr10khook::log['filename']
  $logdir = dirname($logfile)

  ## We're going to assume you're using the puppetlabs-firewall module
  # FIXME: There should be an enable on this, and some legit config
  if ( $gitlabr10khook::firewall == true ){
    notify{"foo":}
    firewall { '100 GitlabWebhook Allow': 
      proto   => tcp,
      dport   => $gitlabr10khook::intserver['port'],
      action  => accept,
    }
  }

  # Make sure the log directory exists, this won't work for
  # recursive cause :( 
  if ( $logdir != '/var/log' ){
    file { $logdir:
      ensure => directory,
      mode   => '0770',
      owner  => $gitlabr10khook::server['user'],
      group  => $gitlabr10khook::server['group'],
      before => $logfile,
    }
  }

  # Make sure the log file exists and is writeable by the runner
  file { $logfile:
    ensure  => file,
    mode    => '0660',
    owner   => $gitlabr10khook::server['user'],
    group   => $gitlabr10khook::server['group'],
  }

  # Add the service to /etc/systemd/system
  file { '/etc/systemd/system/gitlab-puppet-webhook.service':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('gitlabr10khook/startup/gitlab-puppet-webhook.service.erb'),
  }

  # Make sure the systemd conf is in place with the correct path
  file { "${gitlabr10khook::install}/startup/systemd.conf":
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('gitlabr10khook/startup/systemd.conf.erb'),
  }
  #lint:endignore
}
