#!/bin/bash -e

# Get machine IP
MACHINE_IP="@@{address}@@"
SSH_USER="@@{CRED.username}@@"

# Inject ssh key pair into the VM for provisioning support
mkdir -m 700 -p ~/.ssh
cat <<EOF >~/.ssh/id_rsa
@@{CRED.secret}@@
EOF
chmod 600 ~/.ssh/id_rsa
cat <<EOF > ~/.ssh/id_rsa.pub
@@{CRED.public_key}@@
EOF

# Update resolv.conf
# Env setup
mkdir -p openshift
cd openshift

# Install dependencies
sudo yum -y update
sudo yum -y install jq httpd python3

# Disable selinux
sudo setenforce 0
sudo sed -i.bkp -r 's/(SELINUX=)enforcing/\1disabled/g;s/^SELINUXTYPE=targeted/#&/g' /etc/selinux/config

# Download Openshift installer
curl -o openshift-install-linux.tar.gz "@@{openshift_install_linux}@@"
tar xzf openshift-install-linux.tar.gz
sudo install -m 755 -o root openshift-install /sbin/

# Download coreos-installer
curl -o coreos-installer "@@{coreos_installer}@@"
sudo install -m 755 -o root coreos-installer /sbin/

# Download Openshift client
curl -o openshift-client-linux.tar.gz "@@{openshift_client_linux}@@"
tar xzf openshift-client-linux.tar.gz
sudo install -m 755 -o root oc /sbin/

# Download RHCOS 4.7 iso
curl -o rhcos-live.x86_64.iso "@@{rhcos_live}@@"

# Create Web Repo
mkdir web
cp coreos-installer ~/openshift/web
mv openshift-client-linux.tar.gz ~/openshift/web
mv openshift-install-linux.tar.gz ~/openshift/web

# Change ownership of openshift dir to expose iso and igntion over an http endpoint
sudo chown -R apache: ~/openshift/web
sudo chmod 755 "/home/${USER}"

# Configure and start apache on port 8080
sudo sed -i.bkp 's/Listen 80/&80/g' /etc/httpd/conf/httpd.conf
echo "Alias /openshift /home/${SSH_USER}/openshift/web
<Directory /home/${SSH_USER}/openshift/web>
Options -Indexes
Require all granted
</Directory>" | sudo tee -a /etc/httpd/conf.d/openshift.conf
# Enable and start apache
sudo systemctl enable httpd
sudo systemctl start httpd
