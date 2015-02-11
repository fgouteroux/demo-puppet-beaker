#!/bin/bash

if [ "$#" -lt 1 -o "$#" -gt 2 ]; then
    echo "Wrong argument number!"
    echo "Usage: ./bootstrap.sh <puppet_version> <puppet_environment>"
    echo "Ex: ./bootstrap.sh 3.74. production"
    exit 1
fi

PUPPET_VERSION=$1
PUPPET_ENV=${2:-develop}
echo "Bootstrapping puppet/r10k install (version ${PUPPET_VERSION} with env ${PUPPET_ENV})"

function aptsources_setup() {
  local distro=`lsb_release -i | awk '{print $3}'`
  local release=`lsb_release -c | awk '{print $2}'`
  if [[ "${distro}" == "Ubuntu" ]]
  then
    echo "Modifying apt sources to rely on AWS Europe"
    cat > /etc/apt/sources.list <<EOF
deb http://eu-west-1.ec2.archive.ubuntu.com/ubuntu/ ${release} main restricted universe multiverse
deb http://eu-west-1.ec2.archive.ubuntu.com/ubuntu/ ${release}-updates main restricted universe multiverse
deb http://eu-west-1.ec2.archive.ubuntu.com/ubuntu/ ${release}-security main restricted universe multiverse
EOF
  fi

  if [ -f /etc/apt/sources.list.d/puppetlabs.list ]; then
    echo "Puppetlabs repo already exist"
  else
    echo "Configuring puppetlabs repo for ${distro} ${release}"
    cat > /etc/apt/sources.list.d/puppetlabs.list << EOF
# Puppetlabs products
deb http://apt.puppetlabs.com ${release} main
deb-src http://apt.puppetlabs.com ${release} main

# Puppetlabs dependencies
deb http://apt.puppetlabs.com ${release} dependencies
deb-src http://apt.puppetlabs.com ${release} dependencies

# Puppetlabs devel (uncomment to activate)
# deb http://apt.puppetlabs.com ${release} devel
# deb-src http://apt.puppetlabs.com ${release} devel
EOF

PUPPETLABS_GPGTXTKEY="/etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg.txt"

cat > ${PUPPETLABS_GPGTXTKEY} << EOF
-----BEGIN PGP ARMORED FILE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Use "gpg --dearmor" for unpacking

mQINBEw3u0ABEAC1+aJQpU59fwZ4mxFjqNCgfZgDhONDSYQFMRnYC1dzBpJHzI6b
fUBQeaZ8rh6N4kZ+wq1eL86YDXkCt4sCvNTP0eF2XaOLbmxtV9bdpTIBep9bQiKg
5iZaz+brUZlFk/MyJ0Yz//VQ68N1uvXccmD6uxQsVO+gx7rnarg/BGuCNaVtGwy+
S98g8Begwxs9JmGa8pMCcSxtC7fAfAEZ02cYyrw5KfBvFI3cHDdBqrEJQKwKeLKY
GHK3+H1TM4ZMxPsLuR/XKCbvTyl+OCPxU2OxPjufAxLlr8BWUzgJv6ztPe9imqpH
Ppp3KuLFNorjPqWY5jSgKl94W/CO2x591e++a1PhwUn7iVUwVVe+mOEWnK5+Fd0v
VMQebYCXS+3dNf6gxSvhz8etpw20T9Ytg4EdhLvCJRV/pYlqhcq+E9le1jFOHOc0
Nc5FQweUtHGaNVyn8S1hvnvWJBMxpXq+Bezfk3X8PhPT/l9O2lLFOOO08jo0OYiI
wrjhMQQOOSZOb3vBRvBZNnnxPrcdjUUm/9cVB8VcgI5KFhG7hmMCwH70tpUWcZCN
NlI1wj/PJ7Tlxjy44f1o4CQ5FxuozkiITJvh9CTg+k3wEmiaGz65w9jRl9ny2gEl
f4CR5+ba+w2dpuDeMwiHJIs5JsGyJjmA5/0xytB7QvgMs2q25vWhygsmUQARAQAB
tEdQdXBwZXQgTGFicyBSZWxlYXNlIEtleSAoUHVwcGV0IExhYnMgUmVsZWFzZSBL
ZXkpIDxpbmZvQHB1cHBldGxhYnMuY29tPokCPgQTAQIAKAIbAwYLCQgHAwIGFQgC
CQoLBBYCAwECHgECF4AFAk/x5PoFCQtIMjoACgkQEFS3okvW7DAIKQ/9HvZyf+LH
VSkCk92Kb6gckniin3+5ooz67hSr8miGBfK4eocqQ0H7bdtWjAILzR/IBY0xj6OH
KhYP2k8TLc7QhQjt0dRpNkX+Iton2AZryV7vUADreYz44B0bPmhiE+LL46ET5ITh
LKu/KfihzkEEBa9/t178+dO9zCM2xsXaiDhMOxVE32gXvSZKP3hmvnK/FdylUY3n
WtPedr+lHpBLoHGaPH7cjI+MEEugU3oAJ0jpq3V8n4w0jIq2V77wfmbD9byIV7dX
cxApzciK+ekwpQNQMSaceuxLlTZKcdSqo0/qmS2A863YZQ0ZBe+Xyf5OI33+y+Mr
y+vl6Lre2VfPm3udgR10E4tWXJ9Q2CmG+zNPWt73U1FD7xBI7PPvOlyzCX4QJhy2
Fn/fvzaNjHp4/FSiCw0HvX01epcersyun3xxPkRIjwwRM9m5MJ0o4hhPfa97zibX
Sh8XXBnosBQxeg6nEnb26eorVQbqGx0ruu/W2m5/JpUfREsFmNOBUbi8xlKNS5CZ
ypH3Zh88EZiTFolOMEh+hT6s0l6znBAGGZ4m/Unacm5yDHmg7unCk4JyVopQ2KHM
oqG886elu+rm0ASkhyqBAk9sWKptMl3NHiYTRE/m9VAkugVIB2pi+8u84f+an4Hm
l4xlyijgYu05pqNvnLRyJDLd61hviLC8GYWwAgAD
=zUjW
-----END PGP ARMORED FILE-----
EOF

    gpg --dearmor  < ${PUPPETLABS_GPGTXTKEY} > /etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg
  fi
}

function install_puppet() {
  echo "Updating apt cache"
  apt-get update > /dev/null
  echo "Installing puppet(${PUPPET_VERSION}), rubygems and git"
  apt-get install -y puppet=${PUPPET_VERSION}-1puppetlabs1 puppetmaster=${PUPPET_VERSION}-1puppetlabs1 puppet-common=${PUPPET_VERSION}-1puppetlabs1 ruby rubygems ruby-dev git> /dev/null 2>&1
}

function puppet_setup() {
  echo "Activate directory environments"
  sed  -i '/\[main\]/a environmentpath=$confdir/environments' /etc/puppet/puppet.conf
  echo "Enable autosign certificate"
  sed  -i '/\[master\]/a autosign=true' /etc/puppet/puppet.conf
  service puppetmaster restart
}

function hiera_setup() {
  echo "Creating hiera.yaml"
  # Basic hiera config (bootstrap)
  cat > /etc/puppet/hiera.yaml <<EOF
---
:backends:
  - yaml

:hierarchy:
  - "%{::tier}/roles/%{::role}"
  - "%{::tier}/fqdn/%{::fqdn}"
  - "%{::tier}/common"

:yaml:
  :datadir: /etc/puppet/environments/%{::environment}/hieradata
EOF
}

function r10k_setup() {
  echo "Creating r10k.yaml"
  cat > /etc/r10k.yaml <<EOF
---
:cachedir: /var/cache/r10k
:sources:
  :local:
    remote: http://192.168.59.103/puppet/puppet.git
    basedir: /etc/puppet/environments
EOF

  #Test if r10k gem is installed
  if $(gem list r10k -i); then
     echo "r10k gem is already installed"
  else
     echo "Installing r10k gem"
     gem install r10k --no-ri --no-rdoc > /dev/null
  fi
}

function r10k_deploy() {
  echo "Deploying with r10k"
  r10k deploy environment ${PUPPET_ENV} -pv
  echo "Validate puppetmaster setup"
  puppet agent -t
}

function main() {
  aptsources_setup
  which puppet >/dev/null

  if [ $? -eq 0 ]; then
      PUPPET_VER_INSTALLED=`puppet --version`
      if [ "${PUPPET_VER_INSTALLED}" == "${PUPPET_VERSION}" ]; then
        echo "Puppet ${PUPPET_VERSION} already installed"
        hiera_setup
        r10k_setup
        r10k_deploy
      else
        echo "Wrong puppet version detected! I'll replace puppet ver. ${PUPPET_VER_INSTALLED} with ${PUPPET_VERSION}"
        apt-get -y purge puppet-common puppet
        install_puppet
        puppet_setup
        hiera_setup
        r10k_setup
        r10k_deploy
      fi
  else
      install_puppet
      puppet_setup
      hiera_setup
      r10k_setup
      r10k_deploy
  fi
}

if [[ "$EUID" -ne "0" ]]; then
echo "This script must be run as root." >&2
  exit 1
fi

main
