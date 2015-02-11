# Puppet top level file
#
# Roles and Env(ironments)
# (Idea from https://github.com/example42/puppet-example42)
#
# In this module there's usage of 2 Top Scope Variables:
#
# $::role - Identifies groups of nodes that have the same function
#           and general layout
#
# $::tier - Identifies the functional environment of the node
#           For example: dev, test, prod
# This is defined separated from Puppet's internal $environment variable,
# which may be used to define different "Puppet environments" and
# according to custom approaches may or may not be used to identify
# also functional environments.
#

case $::hostname {
  /^app-server-/: {
    include roles::app_server
    $role = 'app_server'
    $tier = 'production'
  }


  /^test-/: {
    include roles::test
    $role = 'test'
    $tier = 'production'
  }

  default: {
    include roles::test
    $role = 'test'
    $tier = 'production'
  }
}
