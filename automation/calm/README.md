## Using this Blueprint
This Calm Blueprint is used to deploy an OpenShift Cluster on Nutanix AHV.

Note that creating a cluster needs the following requirements:
  - IPAM-enabled Subnet with Internet-Access
  - Additional free IP for the LB/DNS

### Getting Started
1. Import both Blueprints (OCP-ProvisioningVM.json and OCP-Cluster-4-7)
2. Within OCP-ProvisioningVM-Blueprint select a valid Subnet for the VM
3. Store a RSA-Private Key on both Blueprints within CREDENTIALS->CRED->Private Key
4. Deploy OCP-ProvisioningVM as a new App
5. After successful Deployment you can run "Deploy OCP" as Action from within the App
   At least change the following Start-Parameters:
   - OCP_SUBDOMAIN (lower-letter)
   - BASE_DOMAIN
   - OCP_MACHINE_NETWORK
   - OCP_PULL_SECRET
   - DNS_LB_IP (free IP within your IPAM-enabled Network, will be used as Static IP for LB/DNS)
   - DNS_FORWARDER_1/2 (if you want the local DNS forwarding other requests within your Network)