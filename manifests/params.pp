# Class: gitlabr10khook::params
# vim: set softtabstop=2 ts=2 sw=2 expandtab:
# ===========================
#
# This configures the gitlab-puppet-webhook that will take
# webhook triggers from gitlab and run r10k on your puppet server
# it currently only supports the PUSH mechanism
#
# Variables
# ----------
# @param install /opt/gitlab-puppet-webhhook is the default location
# @param release The tag point for the git project to checkout
# @param server The server hash with all of the server configuration data
# @param multimaster Enable/Disable multiemaster support
# @param log Logging settings
# @param r10k R10k Binary location and information
# @param legacy Turn off legacy... just do it trust me
# @param footprints Settings for footprints e-mail updates
# @param otrs Settings for OTRS e-mail update functionality
# @param firewall Enable firewall rule
#
# Authors
# -------
# Karl Vollmer <karl.vollmer@gmail.com>
# Copyright
# ---------
# Copyright 2016 Karl Vollmer
class gitlabr10khook::params {

  # Install Path 
  $install = '/opt/gitlab-puppet-webhook'
  $release = '0.4'

  # install packaged dependencies
  $python_dev = $::osfamily ? {
    'RedHat' => 'python-devel',
    'Debian' => 'python-dev',
  }

  $install_deps = $::osfamily ? {
    'RedHat' => [$python_dev, 'python', 'gcc', 'openssl'],
    'Debian' => [$python_dev, 'python-setuptools', 'python', 'openssl'],
    #'Debian' => [$python_dev, 'python-setuptools', 'python', 'gcc', 'git', 'openssl'],
    default  => [],
  }

  # Main Preferences
  ## Port to listen on
  $server = {
    port        => '8080',
    ### Secret Token (for gitlab)
    token       => undef,
    ## Environment Method
    ### DEPRECATED - Only used with legacy systems, will be removed soon
    ### Repo / Branch source
    method      => 'branch',
    ## Production Environment
    ### If your production branch is not called 'production', tell us what it is here
    prodname    => 'production',
    ### Path to Puppet Environments
    envdir      => '/etc/puppetlabs/code/environments',
    ### User to Run the server as
    user        => undef,
    ### Group of the User the server runs as
    group       => undef,
    ### Path to SSL PEM file (cert + key)
    pemfile     => undef,
    ### True to run it as a daemon (will fork off), if false will not detach
    daemon      => true,
    ### E-mail server, defaults to localhost
    smtpserver  => 'localhost',
    ### From Address on outgoing e-mails
    emailfrom   => 'gitlabhook@localhost',
    ### E-mail trigger, only on production / development 
    emailmethod => 'production',
    ### Gitlab action to trigger on, only do anything if it's a push
    action      => 'push',
  }

  ## Logging
  $log = {
    ### Used by Python's logging
    filename  => '/var/log/gitlab10khook.log',
    ### Log File max size Default is 50mb
    maxsize   => '50331648',
    ### Log Level, Default is WARNING, valid options are CRITICAL,ERROR,WARNING,INFO,DEBUG
    level     => 'WARNING',
  }

  $r10k = {
    ### Config path
    config      => '/etc/puppetlabs/r10k/r10k.yaml',
    binary      => '/opt/puppetlabs/puppet/bin/r10k',
  }

  ### For use with systems that need to ssh to other compile masters to deploy code
  $multimaster = {
    ### Multimaster configuration
    enabled => false,
    ### Server List, comma seperated value
    servers => undef,
  }

  ## DEPRECATED - Don't learn how to use this....
  $legacy = {
    ## Enabled, defaults to false
    enabled   => false,
    ## Path where it should dump the legacy modules
    path      => 'legacy-modules',
    ## GIT Clone path, for legacy monolithic repo
    gitpath   => undef,
  }

  $footprints = {
    ## Enable Footprints integration
    enabled   => false,
    ## Workspace ID of the project we should publish to
    project   => undef,
    ## E-mail Address to send e-mail commands to (API is not implemented)
    email     => undef,
    ## Close Status String, the name of the status to switch tickets to when 
    ### We see a FIX #{NUMBER} in the commit message
    close     => undef,
  }

  $otrs = {
    ## Enable OTRS integration
    enabled   => false,
    ## To Address for OTRS
    email     => undef,
  }

  $firewall = true

}
