# == Define: stunnel::tun
#
# Creates a tunnel config to be started by the stunnel application on startup.
#
# === Parameters
#
# [*certificate*]
#   Signed SSL certificate to be used during authentication and encryption.
#   This module is meant to work in conjuction with an already established
#   Puppet infrastructure so we are defaulting to the default location of the
#   agent certificate on Puppet Enterprise.
#
# [*private_key*]
#   In order to encrypt and decrypt things there needs to be a private_key
#   someplace among the system.  Just like certificate we use data from Puppet
#   Enterprise.
#
# [*ca_file*]
#   The CA to use to validate client certificates.  We default to that
#   distributed by Puppet Enterprise.
#
# [*crl_file*]
#   Currently OCSP is not supported in this module so in order to know if a
#   certificate has not been revoked, you will need to load a revocation list.
#   We default to the one distributed by Puppet Enterprise.
#
# [*ssl_version*]
#   Which SSL version you plan to enforce for this tunnel.  The preferred and
#   default is TLSv1.
#
# [*fips*]
#   If OpenSSL is built with FIPS Mode, this parameter can be used to enable/disable it.
#   Must be set to false if you can't use TLSv1 for any reason.
#   Default value is true.
#
# [*chroot*]
#   To protect your host the stunnel application runs inside a chrooted
#   environment.  You must devine the location of the processes' root
#   directory.
#
# [*user*]
#   The stunnel application is capable of running each defined tunnel as a
#   different user.
#
# [*group*]
#   The stunnel application is capable of running each defined tunnel as a
#   different group.
#
# [*pid_file*]
#   Where the process ID of the running tunnel is saved.  This values needs to
#   be relative to your chroot directory.
#
# [*debug_level*]
#   The debug leve of your defined tunnels that is sent to the log.
#
# [*log_dest*]
#   The file that log messages are delivered to.
#
# [*client*]
#   If we running our tunnel in client mode.  There is a difference in stunnel
#   between initiating connections or listening for them.
#
# [*accept*]
#   For which host and on which port to accept connection from.
#
# [*connect*]
#  What port or host and port to connect to.
#
# [*conf_dir*]
#   The default base configuration directory for your version on stunnel.
#   By default we look this value up in a stunnel::data class, which has a
#   list of common answers.
#
# === Examples
#
#   stunnel::tun { 'rsyncd':
#     certificate => "/etc/puppet/ssl/certs/${::clientcert}.pem",
#     private_key => "/etc/puppet/ssl/private_keys/${::clientcert}.pem",
#     ca_file     => '/etc/puppet/ssl/certs/ca.pem',
#     crl_file    => '/etc/puppet/ssl/crl.pem',
#     chroot      => '/var/lib/stunnel4/rsyncd',
#     user        => 'pe-puppet',
#     group       => 'pe-puppet',
#     client      => false,
#     accept      => '1873',
#     connect     => '873',
#   }
#
# === Authors
#
# Cody Herriges <cody@puppetlabs.com>
# Sam Kottler <shk@linux.com>
#
# === Copyright
#
# Copyright 2012 Puppet Labs, LLC
#
define stunnel::tun (
  Optional[String] $certificate = undef,
  Optional[String] $private_key = undef,
  Optional[String] $ca_file     = undef,
  Optional[String] $crl_file    = undef,
  String $ssl_version           = 'TLSv1',
  Boolean $fips                 = true,
  Optional[String] $chroot      = undef,
  Optional[String] $user        = undef,
  Optional[String] $group       = undef,
  String $pid_file              = "/${name}.pid",
  String $debug_level           = '0',
  String $log_dest              = "/var/log/${name}.log",
  Optional[Boolean] $client     = undef,
  Optional[String] $accept      = undef,
  Optional[String] $connect     = undef,
  String $conf_dir              = $stunnel::params::conf_dir,
) {
  $ssl_version_real = $ssl_version ? {
    'tlsv1' => 'TLSv1',
    'sslv2' => 'SSLv2',
    'sslv3' => 'SSLv3',
    default => $ssl_version,
  }

  $fips_mode = $fips ? {
    false => 'no',
    true  => 'yes',
  }

  $client_on = $client ? {
    true  => 'yes',
    false => 'no',
  }

  file { "${conf_dir}/${name}.conf":
    ensure  => file,
    content => template("${module_name}/stunnel.conf.erb"),
    mode    => '0644',
    owner   => '0',
    group   => '0',
    require => File[$conf_dir],
  }

  file { $chroot:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0600',
  }
}
