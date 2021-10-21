## Using these Blueprints
This Set of Calm Blueprints is used to deploy an OpenShift Cluster on Nutanix AHV.
Stage 1 is to deploy a Provisioning VM which fetches resources from Redhat (or an internal Web Service). The Provisioning VM offers an Action to deploy the actual OCP Cluster by collecting all neccessary information and running the Stage 2 Blueprint

Note that creating a cluster needs the following requirements:
  - IPAM-enabled Subnet with Internet-Access
  - existing DNS-Server (with possibility to run comands against it, like PoSH for MS AD or 'samba-tool dns')
  - optionally an existing Loadbalancer (with possibility to run comands against it, like RestAPI), a basic HAProxy is part of Stage2 Blueprint
  - For Running Powershell-Scripts against the Microsoft DNS it is mandantory to create a Runbook-Endpoint which is able to connect against your Environment.

    <img src="../docs/images/calm_endpoint.png" height="50%" width="50%">

### Deployment Scenarios
There are two Deployment-Scenarios (Same Stage 1 Provisioning VM but different Stage2 Blueprint)
## MasterOnly Openshift Cluster
  - Set Number of Workers to Zero, use OCP-MasterOnly as Blueprint Parameter
## Master+Worker Openshift Cluster
  - Set Number of Workers to 2+, use OCP-MasterWorker as Blueprint Parameter

  This Blueprint offers also ScaleOut/ScaleIn as Day2-Action. This is still work in Progress, please keep in mind that actually there is no Cordon/Draining of Nodes when ScaleIn.
  
### Customize DNS / LoadBalancer Integration
The Stage2 Blueprints contains custom Actions in Bootstrap/Master/Worker(if used) Services. 

  <img src="../docs/images/calm_customactions.png" height="50%" width="50%">

By default a HAProxy is installed on LB_DNS-Service where the Services register into (and remove when doing a ScaleIn). You can replace the Code inside of these Actions if you want to use RestAPI against somekind of 3rd Party LoadBalancer as example.
There are also Actions for Register/Remove DNS-Entries which can be modified to fit into your environment.

### Getting Started
1. Create Endpoint for Powershell-Actions against DNS
2. Import needed Blueprints (OCP-ProvisioningVM.json and OCP-MasterOnly/OCP-MasterWorker)
3. Within OCP-ProvisioningVM-Blueprint select a valid Subnet for the VM
    Note: Stage 2 Blueprint receives it Subnet for the VMs from Stage 1
4. Store a RSA-Private Key on both Blueprints within CREDENTIALS->CRED->Private Key
5. Assign previously created Endpoint to Register/RemoveDNS-Actions in Stage2 Blueprint Bootstrap/Master/Worker(if used) Services

  <img src="../docs/images/calm_assignendpoint.png" height="50%" width="50%">

5. Deploy OCP-ProvisioningVM as a new App
6. After successful Deployment you can run "Deploy OCP" as Action from within the App
   At least change the following Start-Parameters:
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

