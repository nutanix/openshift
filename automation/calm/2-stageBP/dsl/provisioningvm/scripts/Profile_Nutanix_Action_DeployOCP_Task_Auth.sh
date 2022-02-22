cd openshift/auth
echo KUBECONFIG="$(base64 -w 0 kubeconfig)"
echo KUBEADMIN="$(base64 -w 0 kubeadmin-password)"

rm kubeconfig
rm kubeadmin-password