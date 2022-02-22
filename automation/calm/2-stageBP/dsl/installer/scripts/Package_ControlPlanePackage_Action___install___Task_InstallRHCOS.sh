#!/bin/bash -e
#Wait for Bootstrap to be finished
BOOTSTRAP_STATUS="@@{Bootstrap.BOOTSTRAP_STATUS}@@"

#Fetch Network-Settings
#GW=$(ip route list dev ens3 | awk ' /^default/ {print $3}')
#IPADDR=$(nmcli d show ens3 | awk ' /IP4.ADDRESS/ {print $2}')
#DNS=$(nmcli d show ens3 | awk ' /IP4.DNS/ {print $2}' | xargs -d'\n'| sed 's/ /,/g')


# Configure ssh agent
SSH_CRED="@@{CRED.secret}@@"
eval `ssh-agent -s`
ssh-add - <<<"${SSH_CRED}"

#Configure Local Network as Static
#sudo nmcli connection mod 'Wired connection 1' \
#  ipv4.method manual \
#  ipv4.addresses $IPADDR \
#  ipv4.gateway $GW \
#  ipv4.dns $DNS \
#  connection.autoconnect yes

sudo coreos-installer install /dev/sda --ignition-url http://@@{PROVISIONING_VM}@@:8080/openshift/master_@@{OPENSHIFT_SUBDOMAIN}@@.ign --insecure-ignition #--copy-network
