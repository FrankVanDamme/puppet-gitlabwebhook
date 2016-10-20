# Class: gitlabr10khook
# vim: set softtabstop=2 ts=2 sw=2 expandtab:
# ===========================
# This configures the gitlab-puppet-webhook that will take
# webhook triggers from gitlab and run r10k on your puppet server
# it currently only supports the PUSH mechanism
#
# Parameters
# ----------
#
# Variables
# ----------
#
# Examples
# --------
#
# @example
#    class { 'gitlabr10khook':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
# Karl Vollmer <karl.vollmer@gmail.com>
# Copyright
# ---------
# Copyright 2016 Karl Vollmer.
class gitlabr10khook  (
  $install    = $gitlabr10khook::params::install,
  $server     = $gitlabr10khook::params::server,
  $log        = $gitlabr10khook::params::log,
  $r10k       = $gitlabr10khook::params::r10k,
  $legacy     = $gitlabr10khook::params::legacy,
  $footprints = $gitlabr10khook::params::footprints,
  $otrs       = $gitlabr10khook::params::otrs,
) inherits gitlabr10khook::params {

  # Merge defaults
  $intserver      = merge($gitlabr10khook::params::server,$server)
  $intlog         = merge($gitlabr10khook::params::log,$log)
  $intr10k        = merge($gitlabr10khook::params::r10k,$r10k)
  $intlegacy      = merge($gitlabr10khook::params::legacy,$legacy)
  $intfootprints  = merge($gitlabr10khook::params::footprints,$footprints)
  $intotrs        = merge($gitlabr10khook::params::otrs,$otrs)

  # Make sure the bits are at least semi-valid
  ## Make sure they specified a proper path for the installation
  validate_absolute_path($install)

  ## Make sure daemon is a boolean
  validate_bool($intserver['daemon'])

  ## Make sure that server port is an integer 

  # Run the install, config and then start the service
  anchor { 'gitlabr10khook::begin': } ->
  class { '::gitlabr10khook::install': } ->
  class { '::gitlabr10khook::config': } ~>
  class { '::gitlabr10khook::service': } ~>
  anchor { 'gitlabr10khook::end': }

}
