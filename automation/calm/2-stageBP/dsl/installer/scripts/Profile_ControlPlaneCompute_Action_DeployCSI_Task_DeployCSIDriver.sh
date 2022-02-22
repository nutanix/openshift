export KUBECONFIG=~/openshift/auth/kubeconfig
echo """apiVersion: v1
kind: Secret
metadata:
  name: ntnx-secret
  namespace: ntnx-system
stringData:
  key: @@{PE_IP}@@:9440:@@{PE_ADMIN}@@:@@{PE_PW}@@""" > ntnx-secret.yaml
echo """apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ntnx-system-r8czl
  namespace: ntnx-system
spec:
  targetNamespaces:
  - ntnx-system""" > operatorgroup.yaml
echo """apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: nutanixcsioperator
  namespace: ntnx-system
spec:
  channel: stable
  name: nutanixcsioperator
  installPlanApproval: Automatic
  source: certified-operators
  sourceNamespace: openshift-marketplace""" > subscription.yaml
echo """apiVersion: crd.nutanix.com/v1alpha1
kind: NutanixCsiStorage
metadata:
  name: nutanixcsistorage
  namespace: ntnx-system
spec:
  namespace: ntnx-system""" > instance.yaml
  
oc create ns ntnx-system
oc create -f ntnx-secret.yaml
oc create -f operatorgroup.yaml
oc create -f subscription.yaml

ATTEMPTS=0
ROLLOUT_STATUS_CMD="oc wait --for=condition=available --timeout=120s -n ntnx-system deployments nutanix-csi-operator-controller-manager"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 12 ]; do
  $ROLLOUT_STATUS_CMD
  ATTEMPTS=$((attempts + 1))
  sleep 10
done

# Check deployment rollout status every 10 seconds (max 2 minutes) until complete.
ATTEMPTS=0
ROLLOUT_STATUS_CMD="oc get NutanixCsiStorage -n ntnx-system"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 12 ]; do
  $ROLLOUT_STATUS_CMD
  ATTEMPTS=$((attempts + 1))
  sleep 10
done

oc create -f instance.yaml