#!/bin/bash -e

mkdir -p openshift
cd openshift

# Install dependencies
# sudo yum -y update
sudo yum -y install jq python3 socat haproxy dnsmasq

# Disable selinux
sudo setenforce 0
sudo sed -i.bkp -r 's/(SELINUX=)enforcing/\1disabled/g;s/^SELINUXTYPE=targeted/#&/g' /etc/selinux/config

# Download Openshift installer
curl -o openshift-install-linux.tar.gz http://@@{PROVISIONING_VM}@@:8080/openshift/openshift-install-linux.tar.gz
tar xzf openshift-install-linux.tar.gz
sudo install -m 755 -o root openshift-install /sbin/

# Download Openshift client
curl -o openshift-client-linux.tar.gz http://@@{PROVISIONING_VM}@@:8080/openshift/openshift-client-linux.tar.gz
tar xzf openshift-client-linux.tar.gz
sudo install -m 755 -o root oc /sbin/
