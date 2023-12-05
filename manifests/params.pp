# == Class: stunnel::params
#
class stunnel::params {
  case $facts['os']['family'] {
    'Debian' : {
      $conf_dir = '/etc/stunnel'
      $package = 'stunnel4'
      $service = 'stunnel4'
    }
    'RedHat' : {
      $conf_dir = '/etc/stunnel'
      $package = 'stunnel'
      $service = 'stunnel'
    }
    default: {}
  }
}
