## Configure ssh agent
SSH_CRED="@@{CRED.secret}@@"
eval `ssh-agent -s`
ssh-add - <<<"${SSH_CRED}"

## Update DNS zones and LB config
ssh core@@@{LB_TARGET}@@ -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null << EOF
sudo sed -i '/compute-@@{calm_array_index}@@/d' /etc/hosts
EOF