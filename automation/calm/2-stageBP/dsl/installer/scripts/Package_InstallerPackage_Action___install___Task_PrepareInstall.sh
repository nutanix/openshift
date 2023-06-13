echo 'export KUBECONFIG=~/openshift/auth/kubeconfig' >> .bash_profile

mkdir -p openshift/auth
cd openshift/auth
echo @@{KUBECONFIGB64}@@ | base64 -d > kubeconfig
echo @@{KUBEADMINB64}@@ | base64 -d > kubeadmin-password
