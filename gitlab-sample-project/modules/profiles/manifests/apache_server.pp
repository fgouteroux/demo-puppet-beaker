# Profile for Apache Server
class profiles::apache_server inherits profiles::default {

  class {'apache':}

  $apache_vhost = hiera_hash('apache::vhost', false)
    if $apache_vhost {
      create_resources('apache::vhost', $apache_vhost)
    }
}
