## Using these Blueprints
This Set of Calm Blueprints is used to deploy an OpenShift Cluster on Nutanix AHV.
Stage 1 is to deploy a Provisioning VM which fetches resources from Redhat (or an internal Web Service). The Provisioning VM offers an Action to deploy the actual OCP Cluster by collecting all neccessary information and running the Stage 2 Blueprint

Note that creating a cluster needs the following requirements:
  - IPAM-enabled Subnet with Internet-Access

### Deployment Scenarios
There are two Deployment-Scenarios (Same Stage 1 Provisioning VM but different Stage2 Blueprint)
## Deploy new DNS-Server along with Loadbalancer
  - Parameter DNS SERVER should point to an upstream DNS
  - Use OCP-Cluster-4-7 as Blueprint Parameter
## Use existing Microsoft AD DNS Server
  - Parameter DNS SERVER should point to an existing MS AD DNS Server
  - Use OCP-Cluster-4-7-AD as Blueprint Parameter
  **Note: Reverse Lookup-Zone MUST exist within MS AD, otherwise there will be an error when creating DNS-Entries. Will be fixed in next Push.
### Getting Started
1. Import needed Blueprints (OCP-ProvisioningVM.json and OCP-Cluster-4-7/OCP-Cluster-4-7-AD)
2. Within OCP-ProvisioningVM-Blueprint select a valid Subnet for the VM
    Note: Stage 2 Blueprint receives it Subnet for the VMs from Stage 1
3. Store a RSA-Private Key on both Blueprints within CREDENTIALS->CRED->Private Key
   When using AD-Blueprint please also provide AD-User Credentials
4. Deploy OCP-ProvisioningVM as a new App
5. After successful Deployment you can run "Deploy OCP" as Action from within the App
   At least change the following Start-Parameters:
   - OCP_PULL_SECRET
   - BASE_DOMAIN
   - OCP_SUBDOMAIN (lower-letter)
   - OCP_MACHINE_NETWORK
   - DNS SERVER (see Notes regarding different Deployment Scenarios)

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

