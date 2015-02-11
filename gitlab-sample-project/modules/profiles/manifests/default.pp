# It doesn't add anything to baseline configurations
class profiles::default {

  class { 'apt':
  }

  # This should probably moved to a dedicated class
  Ini_setting {
    path   => '/etc/puppet/puppet.conf',
    ensure => present,
  }

  ini_setting { 'puppet_user':
    section => 'agent',
    setting => 'user',
    value   => 'puppet',
  }
}
