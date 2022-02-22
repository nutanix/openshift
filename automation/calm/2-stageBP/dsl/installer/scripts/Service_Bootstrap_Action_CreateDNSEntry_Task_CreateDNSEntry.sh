## Configure ssh agent
SSH_CRED="@@{CRED.secret}@@"
eval `ssh-agent -s`
ssh-add - <<<"${SSH_CRED}"

## Update DNS zones and LB config for Bootstrap ###
ssh core@@@{LBDNS.address}@@ -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null << EOF
echo "@@{address}@@ bootstrap.@@{OPENSHIFT_SUBDOMAIN}@@.@@{BASE_DOMAIN}@@" | sudo tee -a /etc/hosts
EOF