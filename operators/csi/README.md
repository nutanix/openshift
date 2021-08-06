# Nutanix CSI Operator

## Overview

The Nutanix CSI Operator for Kubernetes packages, deploys, manages, and upgrades the Nutanix CSI Driver on Kubernetes and OpenShift for dynamic provisioning of persistent volumes on the Nutanix Enterprise Cloud platform.

### Nutanix CSI Driver

The Nutanix Container Storage Interface (CSI) Driver for Kubernetes leverages Nutanix Volumes and Nutanix Files to provide scalable and persistent storage for stateful applications.

With Nutanix CSI Provider you can:

 - Provide persistent storage to your containers

   - Leverage PVC ressources to consume dynamicaly Nutanix storage

   - With Files storage classes, applications on multiple pods can access the same storage, and also have the benefit of multi-pod read and write access.

### Installing the Operator

1. Follow OpenShift documentation for Adding Operators to a cluster ([4.6](https://docs.openshift.com/container-platform/4.6/operators/admin/olm-adding-operators-to-cluster.html)/[4.7](https://docs.openshift.com/container-platform/4.7/operators/admin/olm-adding-operators-to-cluster.html)).
    1. Filter by the keyword "Nutanix" to find the CSI Operator.

        <image src=images/operatorhub-csi.png height="50%" width="50%">

    2. Install the Operator by creating a new "ntnx-system" namespace and selecting defaults.

### Install the CSI Driver using the Operator

1. In the OpenShift web console, navigate to the Operators → Installed Operators page.
2. Select **Nutanix CSI Operator**.
3. Select **Create instance** and then **Create**.

    <image src=images/operator-csi-deploy.png height="50%" width="50%">

### Configuring k8s secret and storage class

In order to use this driver, create the relevant storage classes and secrets using the OpenShift CLI, by followinig the below section:

1. Create a secret yaml file like the below example and apply (`oc -n ntnx-system apply -f <filename>`).

    ```
    apiVersion: v1
    kind: Secret
    metadata:
      name: ntnx-secret
      namespace: ntnx-system
    stringData:
      # prism-ip:prism-port:admin:password
      key: 10.0.0.14:9440:admin:password
    ```
2. Create storage class yaml like the below example and apply (`oc apply -f <filename>`).

    ```
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: nutanix-volume
    provisioner: csi.nutanix.com
    parameters:
      csi.storage.k8s.io/provisioner-secret-name: ntnx-secret
      csi.storage.k8s.io/provisioner-secret-namespace: ntnx-system
      csi.storage.k8s.io/node-publish-secret-name: ntnx-secret
      csi.storage.k8s.io/node-publish-secret-namespace: ntnx-system
      csi.storage.k8s.io/controller-expand-secret-name: ntnx-secret
      csi.storage.k8s.io/controller-expand-secret-namespace: ntnx-system
      csi.storage.k8s.io/fstype: ext4
      dataServiceEndPoint: 10.0.0.15:3260
      storageContainer: default-container
      storageType: NutanixVolumes
      #whitelistIPMode: ENABLED
      #chapAuth: ENABLED
    allowVolumeExpansion: true
    reclaimPolicy: Delete
    ```
    
**Note:** By default, new RHCOS based nodes are provisioned with the required scsi-initiator-utils package installed, but with the iscsid service disabled. This can result in messages like "iscsiadm: can not connect to iSCSI daemon (111)!". When this occurs, confirm that the iscsid.service is running on worker nodes. It can be enabled and started globally using the Machine Config Operator or directly on each node using systemctl (`sudo systemctl enable --now iscsid`).
     
See the [Managing Storage section of CSI Driver documentation on the Nutanix Portal](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_3:csi-csi-plugin-storage-c.html) for more information on configuring storage classes. 

