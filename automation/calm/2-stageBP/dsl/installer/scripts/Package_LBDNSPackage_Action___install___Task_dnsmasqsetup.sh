echo "@@{address}@@ helper.@@{OPENSHIFT_SUBDOMAIN}@@.@@{BASE_DOMAIN}@@" | sudo tee -a /etc/hosts
echo "@@{address}@@ api.@@{OPENSHIFT_SUBDOMAIN}@@.@@{BASE_DOMAIN}@@" | sudo tee -a /etc/hosts
echo "@@{address}@@ api-int.@@{OPENSHIFT_SUBDOMAIN}@@.@@{BASE_DOMAIN}@@" | sudo tee -a /etc/hosts

echo "address=/.apps.@@{OPENSHIFT_SUBDOMAIN}@@.@@{BASE_DOMAIN}@@/@@{address}@@" | sudo tee -a /etc/dnsmasq.conf 
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq
