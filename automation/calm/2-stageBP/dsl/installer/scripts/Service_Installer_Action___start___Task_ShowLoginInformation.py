print "Installation completed"
print "For logging into Console please use the following URL:"
print "https://console-openshift-console.apps.{}.{}".format('@@{OPENSHIFT_SUBDOMAIN}@@','@@{BASE_DOMAIN}@@')
print "Credentials: kubeadmin / {}".format(base64.b64decode('@@{KUBEADMINB64}@@'))
print "For CLI access you can also connect to LBDNS-Console."
print "Please run 'export KUBECONFIG=~/openshift/auth/kubeconfig' before using OC CLI Tool"