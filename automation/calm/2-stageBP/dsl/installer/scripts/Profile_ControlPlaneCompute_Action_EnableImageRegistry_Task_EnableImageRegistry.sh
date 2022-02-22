export KUBECONFIG=~/openshift/auth/kubeconfig
echo """apiVersion: storage.k8s.io/v1
kind: StorageClass
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
  dataServiceEndPoint: @@{DS_IP}@@:3260
  storageContainer: @@{PE_CONTAINER}@@
  storageType: NutanixVolumes
  #whitelistIPMode: ENABLED
  #chapAuth: ENABLED
allowVolumeExpansion: true
reclaimPolicy: Delete""" > storageclass.yaml
echo """kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: image-registry-claim
  namespace: openshift-image-registry
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: nutanix-volume""" > pvc.yaml

oc create -f storageclass.yaml
oc create -f pvc.yaml

# Patch OC Image Registry to use created PVC
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Managed","storage":{"pvc":{"claim":"image-registry-claim"}},"rolloutStrategy": "Recreate"}}'
