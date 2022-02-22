#!/bin/bash -e

cd ~/openshift

# Create ignition config used for generation of ignition files
cat <<EOF > install-config.yaml
apiVersion: v1
baseDomain: @@{BASE_DOMAIN}@@
metadata:
  name: @@{OCP_SUBDOMAIN}@@
compute:
-  name: worker # add argument
   replicas: @@{COMPUTE_NODES}@@
controlPlane:
  name: master # add argument
  replicas: 3 # default
networking:
  clusterNetwork:
  - cidr: @@{OCP_CLUSTER_NETWORK}@@
    hostPrefix: @@{OCP_CLUSTER_HOSTPREFIX}@@
  serviceNetwork:
   - @@{OCP_SERVICE_NETWORK}@@
  machineNetwork:
  - cidr: @@{OCP_MACHINE_NETWORK}@@
platform:
  none: {}
pullSecret: '@@{OCP_PULL_SECRET}@@'
sshKey: "@@{CRED.public_key}@@"
EOF

# Ignition file generation
# This will generate bootstrap.ign,master.ign and worker.ign files
# Ignition files are used for RCHCOS installation(similar to kickstart for RHEL)
openshift-install create ignition-configs

# Get private IP address of primary interface
# MACHINE_IP=$(ip -4 a show eth0  | awk '/inet/ {gsub(/\/[0-9]+/,"",$2);print $2}')

# Embed MachineConfig for iscsid in ignition files

echo "bootstrap.ign
master.ign
worker.ign"| while read i; do
j=${i%.*}
#Check if self-deployed DNS must be patched into Iginition Files
jq '.systemd.units +=[{"name": "iscsid.service","enabled": true}]' ${i} > ${j}_@@{OCP_SUBDOMAIN}@@.ign

done

# Copy RHCOS Image
# Embed bootstrap ignition config in ISO for first boot
# All VMs initially boot from ISO with embedded bootstrap ignition
# coreos-installer is used to install OS on hdd for specific roles via ignition files after first boot
coreos-installer iso ignition embed -i bootstrap_@@{OCP_SUBDOMAIN}@@.ign rhcos-live.x86_64.iso -o rhcos-@@{OCP_SUBDOMAIN}@@.iso

sudo mv rhcos-@@{OCP_SUBDOMAIN}@@.iso ~/openshift/web
sudo mv *_@@{OCP_SUBDOMAIN}@@.ign ~/openshift/web
sudo chown apache: ~/openshift/web/*

rm *.ign
rm metadata.json

rm .openshift*