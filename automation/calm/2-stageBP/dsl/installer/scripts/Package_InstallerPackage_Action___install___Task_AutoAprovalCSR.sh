export KUBECONFIG=~/openshift/auth/kubeconfig

echo """export KUBECONFIG=~/openshift/auth/kubeconfig
~/openshift/oc get csr -oname | xargs ~/openshift/oc adm certificate approve""" > openshift/csrjob.sh
chmod +x openshift/csrjob.sh

(crontab -l; echo "* * * * * /home/core/openshift/csrjob.sh")|awk '!x[$0]++'|crontab -