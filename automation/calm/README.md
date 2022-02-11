### 01/31/22 Actual Information
We are switching to a new Deployment Strategy which only uses a Single Blueprint to make the Deployment even more simpler.
Find the old 2-Stage BPs in this Folder:
[a relative link](2-stageBP/README.md)

IMPORTANT: This new Blueprint uses a Openstack-Image which is not supported by RedHat on Nutanix. Using this Blueprint will deploy a Cluster who is not supported by RedHat. This will change as soon there is a dedicated Nutanix Image.
If you need a RedHat-supported Cluster use the 2-Stage BP as this is based on the Platform-agnostic-Install Process.


## Using the Blueprint
This Blueprint is used to deploy an OpenShift Cluster on Nutanix AHV.

Note that creating a cluster needs the following requirements:
  - IPAM-enabled Subnet with Internet-Access and configured IP-Pool for the VMs.
  - Static IP for our Bastion (which runs HAProxy and dnsmasq), must be outside of the IP-Pool.
  - existing DNS-Server (with possibility to create a DNS-Delegation for the Subdomain we are creating)
  - access to RHCOS Image (this is only available .gz compressed and needs to be extracted and imported before running the Blueprint)

## Caution
This Blueprints uses an RHCOS-Openstack Base Image. Running Openstack-Images on any Platform is not supported, so do not use this in Production environment. With upcomming Openshift 4.10 there will be a dedicated Nutanix Image.
    
### Prequisite: DNS Settings
Before running the Blueprint please create a NS-Record or DNS-Delegation for the desired OCP-Subdomain. The Delegation Target-IP is used as Bastion-IP in our Blueprint.

As example when using Microsoft DNS run a command like this example:

```
Add-DnsServerZoneDelegation -Name "ntnxlab.local" -Nameserver "lbdns-ocp1.ntnxlab.local" -ChildZoneName "ocp1" -IPAddress 10.42.26.11 -PassThru -Verbose

```

### Prequisite: RHCOS Image
Please import the following QCOW2 image into the Nutanix AHV cluster :
RHCOS OpenStack image (ex: https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.9/latest/rhcos-4.9.0-x86_64-openstack.x86_64.qcow2.gz)
If you import it manually please assign the Image to the three Services (Bootstrap, Master, Worker).
As an Alternative you can provide access to the Image via HTTP and configure the URI in CONFIGURATION->DOWNLOADABLE IMAGE CONFIGURATION->RHCOS->Source URI
(Important: the pre-configured path needs to be changed when running the Blueprint outside of NTNX-Environments)
### Customization (HAProxy/DNS)
By default a HAProxy is installed on LB_DNS-Service where the Services register into (and remove when doing a ScaleIn). You can replace the Code inside of these Actions if you want to use RestAPI against somekind of 3rd Party LoadBalancer as example.
There are also Actions for Register/Remove DNS-Entries which can be modified to fit into your environment.

### Getting Started
1. Import  Blueprint
2. Within the Blueprint select a valid Subnet for all VMs
3. Store a RSA-Private Key within CREDENTIALS->CRED->Private Key
4. Deploy Blueprint as new App
5. provide at least the following Start-Parameters:
   - IP of your Bastion VM (this is the Target-IP from your DNS-Delegation)
   - Number of Worker
   - OCP_PULL_SECRET
   - BASE_DOMAIN
   - OCP_SUBDOMAIN (lower-letter, DNS-compliant)
   - OCP_MACHINE_NETWORK
 
## Logging into Openshift Console
After succesfull deployment the auto-created Login-Information are accessible via Audit-Log->Create->OS_Status_Check Start->Show Login Information

  **Note: For using Web-Console your Client needs to use the matching DNS-Server, otherwise create Hosts-Entries like this:
  a.b.c.d oauth-openshift.apps.SUBDOMAIN.BASEDOMAIN
  a.b.c.d console-openshift-console.apps.SUBDOMAIN.BASEDOMAIN

## Install CSI-Drivers
The Stage 2 Blueprint offers a Action to deploy Nutanix CSI Drivers. While running this Action additonal Information like PrismElement IP and Credentials are collected.

## Configure Image Registry
This enables Openshift Image Registry on 100G Nutanix Volumes. While running this Action additonal Information like DataServices IP and Nutanix Storage Container are collected.

  **Note: Block storage volumes like Nutanix Volumes with ReadWriteOnce configuration are supported but not recommended for use with the image registry on production clusters. An installation where the registry is configured on block storage is not highly available because the registry cannot have more than one replica.

