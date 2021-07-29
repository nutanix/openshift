# Red Hat OpenShift Container Platform Manual Installation on Nutanix AOS (AHV)

**Note: Red Hat OpenShift Container Platform versions 4.6 and 4.7 have been tested for specific compatibility on Nutanix AOS 5.15.6 and 5.20.1.**

## Installation Prerequisites

1. Before installing OpenShift Container Platform, download the installation file on a local computer. A computer that runs Linux or macOS, with 500 MB of local disk space is required.
2. Access the [Platform Agnostic User-Provisioned Infrastructure](https://console.redhat.com/openshift/install/metal/user-provisioned) page on the Red Hat OpenShift Cluster Manager site. If you have a Red Hat account, log in with your credentials. If you do not, create an account.
3. Follow the steps to download the OpenShift installer, pull secret, command-line tools (CLI), and Red Hat Enterprise Linux CoreOS (RHCOS) ISO. Additional details can be found in the OpenShift documentation ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_platform_agnostic/installing-platform-agnostic.html#installation-obtaining-installer_installing-platform-agnostic)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_platform_agnostic/installing-platform-agnostic.html#installation-obtaining-installer_installing-platform-agnostic)).
4. Review the User Provisioned Infrastructure documentation for the version of OpenShift Container Platform you wish to install ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_bare_metal/installing-bare-metal.html)).

### Additional Infrastructure Requirements

1. Follow OpenShift documentation to:
    1. Configure Networking requirements for user-provisioned infrastructure ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html#installation-network-user-infra_installing-bare-metal)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_bare_metal/installing-bare-metal.html#installation-network-user-infra_installing-bare-metal)). This includes:
        1. Network topology requirements
            1. API load balancer
            2. Application Ingress load balancer
        2. NTP configuration
        3. DNS requirements
    2. Generate an SSH private key and add it to the agent ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html#ssh-agent-using_installing-bare-metal)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_bare_metal/installing-bare-metal.html#ssh-agent-using_installing-bare-metal)). This key is used to access the bootstrap machine in a public cluster to troubleshoot installation issues.

### Create and stage the Installation Config and Manifests

1. Follow OpenShift documentation to:
    1. Manually create the installation configuration file ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html#installation-initializing-manual_installing-bare-metal)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_bare_metal/installing-bare-metal.html#installation-initializing-manual_installing-bare-metal))_._
    2. Create the Kubernetes manifest and Ignition config files ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html#installation-user-infra-generate-k8s-manifest-ignition_installing-bare-metal)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_bare_metal/installing-bare-metal.html#installation-user-infra-generate-k8s-manifest-ignition_installing-bare-metal)).
2. Configure a web server that is accessible from the network attached to the OpenShift VMs. This server will host the ignition config files.
3. Copy the ignition files onto the web server so they can be passed to the OpenShift VMs for installation.

## RHCOS Virtual Machine Creation

1. Access the Prism Central or Prism Element instance managing the AOS cluster where you would like to install OpenShift.
2. From the main menu, browse to **Virtual Infrastructure → Images**, and follow prompts to upload the RHCOS iso downloaded as part of the prerequisites. Prism Element users will find image configuration by browsing to ⚙ → Image Configuration. 
3. If a new subnet is required, browse to **Network & Security → Subnets** and create it. If this network is not configured with Nutanix IPAM and doesn’t have DHCP (with reservation) available, VMs will require manual network configuration at boot.
4. Create the VMs that will be used in the OpenShift cluster. Machine requirements and their minimum resource requirements can be found in the OpenShift documentation ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html#installation-requirements-user-infra_installing-bare-metal)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_bare_metal/installing-bare-metal.html#installation-requirements-user-infra_installing-bare-metal)).
    1. Browse to **Virtual Infrastructure → VMs**, then **Create VM** and follow prompts to create VMs using the settings below.
        1. Specify the number of vCPUs and memory as required.
        2. Attach the RHCOS iso by cloning the uploaded image.

            <img src="images/attach_cdrom.png" height="50%" width="50%">
 
        3. Attach an additional disk meeting the storage requirements of the VM.

            <img src="images/attach_disk.png" height="50%" width="50%">

        4. Attach the required subnet to the VM. If this network is configured with IP Address Management (IPAM), choose Assign Static IP and specify the appropriate address. Note that for subnets without IPAM or DHCP (with reservation), VMs will initially require manual network configuration at boot.

            <img src="images/attach_subnet.png" height="50%" width="50%">

        5. Under Boot Configuration, choose Legacy BIOS Mode with Default Boot Order.
        6. Add any required Categories, choose UTC Timezone, and No Guest Customization.
        7. Review settings and complete VM creation.
5. From the main menu, browse to **Virtual Infrastructure → VMs**. From the List view, select each VM, power it on, and launch the console from the Action menu. Depending on the type of machine, run the following example command in the console:

   **Note: The commands below assume the provisioned subnet has IPAM or DHCP (with reservation) configured and VMs have a static IP assigned. If manual network configuration is required, follow the steps documented in OpenShift documentation ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html#installation-user-infra-machines-static-network_installing-bare-metal)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_bare_metal/installing-bare-metal.html#installation-user-infra-machines-static-network_installing-bare-metal)).**

  * Bootstrap
   
     `sudo coreos-installer install /dev/sda --copy-network --ignition-url=https://host/bootstrap.ign`
  * Control Plane
   
     `sudo coreos-installer install /dev/sda --copy-network --ignition-url=http://host/master.ign`
  * Compute
     
     `coreos-installer install /dev/sda --copy-network --ignition-url=http://host/worker.ign`

6. After RHCOS installs, unmount the iso and reboot the VM. During the reboot, the Ignition config file is applied. 

## Creating the OpenShift Cluster

1. Follow OpenShift documentation to:
    1. Create and log into the cluster ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html#installation-installing-bare-metal_installing-bare-metal)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_bare_metal/installing-bare-metal.html#installation-installing-bare-metal_installing-bare-metal)).
    2. Approve certificate signing requests and watch the cluster components come online ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html#installation-approve-csrs_installing-bare-metal)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_bare_metal/installing-bare-metal.html#installation-approve-csrs_installing-bare-metal)).
    3. Monitor for cluster completion ([4.6](https://docs.openshift.com/container-platform/4.6/installing/installing_bare_metal/installing-bare-metal.html#installation-complete-user-infra_installing-bare-metal)/[4.7](https://docs.openshift.com/container-platform/4.7/installing/installing_bare_metal/installing-bare-metal.html#installation-complete-user-infra_installing-bare-metal)).
