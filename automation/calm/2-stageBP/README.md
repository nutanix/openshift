## Using these Blueprints
This Set of Calm Blueprints is used to deploy an OpenShift Cluster on Nutanix AHV.
Stage 1 is to deploy a Provisioning VM which fetches resources from Redhat (or an internal Web Service). The Provisioning VM offers an Action to deploy the actual OCP Cluster by collecting all neccessary information and running the Stage 2 Blueprint

Note that creating a cluster needs the following requirements:
  - IPAM-enabled Subnet with Internet-Access and IP-Pool for the VMs
  - existing DNS-Server (with possibility to create a DNS-Delegation for the Subdomain we are creating)

### Prequisite: DNS Settings
Before running the Blueprint please create a NS-Record or DNS-Delegation for the desired OCP-Subdomain. The Delegation Target-IP is used as Bastion-IP in our Blueprint.

As example when using Microsoft DNS run a command like this example:

```
Add-DnsServerZoneDelegation -Name "ntnxlab.local" -Nameserver "lbdns-ocp1.ntnxlab.local" -ChildZoneName "ocp1" -IPAddress 10.42.26.11 -PassThru -Verbose

``` 

### Getting Started
1. Import needed Blueprints (OCP-ProvisioningVM.json and OCP-MasterOnly/OCP-MasterWorker)
2. Within OCP-ProvisioningVM-Blueprint select a valid Subnet for the VM
    Note: Stage 2 Blueprint receives it Subnet for the VMs from Stage 1
3. Store a RSA-Private Key on both Blueprints within CREDENTIALS->CRED->Private Key
4. Deploy OCP-ProvisioningVM as a new App
5. After successful Deployment you can run "Deploy OCP" as Action from within the App
   At least change the following Start-Parameters:
   - Static IP of your LBDNS-Service
   - Number of Worker
   - OCP_PULL_SECRET
   - BASE_DOMAIN
   - OCP_SUBDOMAIN (lower-letter, DNS-compliant)
   - OCP_MACHINE_NETWORK
 
## Logging into Openshift Console
After succesfull deployment the auto-created Login-Information are accessible via Audit-Log->Create->OS_Status_Check Start->Show Login Information

## Install CSI-Drivers
The Stage 2 Blueprint offers a Action to deploy Nutanix CSI Drivers. While running this Action additonal Information like PrismElement IP and Credentials are collected.

## Configure Image Registry
This enables Openshift Image Registry on 100G Nutanix Volumes. While running this Action additonal Information like DataServices IP and Nutanix Storage Container are collected.

  **Note: Block storage volumes like Nutanix Volumes with ReadWriteOnce configuration are supported but not recommended for use with the image registry on production clusters. An installation where the registry is configured on block storage is not highly available because the registry cannot have more than one replica.

