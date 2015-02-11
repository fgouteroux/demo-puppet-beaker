# Based on a script from Hashicorp
# https://raw.githubusercontent.com/hashicorp/puppet-bootstrap/master/debian.sh
#
#!/usr/bin/env sh
# arg1: puppet version to install
PUPPET_VERSION=$1
PUPPET_ENV=${2:-develop}

if [ "$#" -lt 1 -o "$#" -gt 2 ]; then
    echo "Wrong argument number!"
    echo "Usage: ./bootstrap <puppet_version> <puppet_environment>"
    echo "Ex: ./bootstrap 3.7.4 production"
    exit 1
fi


# Test if puppet already installed on the box
which puppet >/dev/null

if [ $? -eq 0 ]; then
    PUPPET_VER_INSTALLED=`puppet --version`
    if [ "${PUPPET_VER_INSTALLED}" == "${PUPPET_VERSION}" ]; then
      echo "Puppet ${PUPPET_VERSION} already installed"
      exit 0
    fi
    echo "Wrong puppet version detected! I'll replace puppet ver. ${PUPPET_VER_INSTALLED} with ${PUPPET_VERSION}"
    apt-get -y purge puppet-common puppet
fi

# This bootstraps Puppet on Debian
set -e

# Do the initial apt-get update
echo "Initial apt-get update..."
apt-get update >/dev/null

# Older versions of Debian don't have lsb_release by default, so
# install that if we have to.
which lsb_release || apt-get install -y lsb-release

# Load up the release information
release=$(lsb_release -c -s)

function aptsources_setup () {
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
}

#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT
#--------------------------------------------------------------------
if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Install wget if we have to (some older Debian versions)
echo "Installing wget..."
apt-get install -y wget >/dev/null

echo "Installing Augeas"
apt-get install -y libaugeas-ruby > /dev/null

# Install the PuppetLabs repo
echo "Configuring PuppetLabs repo..."
repo_deb_path=$(mktemp)
aptsources_setup
apt-get update >/dev/null

# Install Puppet
echo "Installing Puppet ${PUPPET_VERSION} ..."
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppet=$1-1puppetlabs1 puppet-common=$1-1puppetlabs1 >/dev/null

echo "Puppet ${PUPPET_VERSION} installed!"

# Set Default Puppet Environment with Current Branch
echo "Set Puppet default environment:${PUPPET_ENV}"
cat >> /etc/puppet/puppet.conf <<EOF
[agent]
environment=${PUPPET_ENV}
EOF
