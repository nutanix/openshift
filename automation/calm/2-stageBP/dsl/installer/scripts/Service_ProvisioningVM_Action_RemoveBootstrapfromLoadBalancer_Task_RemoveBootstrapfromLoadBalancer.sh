echo "set server machine-config-server/bootstrap state maint" | socat stdio tcp4-connect:@@{LBDNS.address}@@:9999
echo "set server openshift-api-server/bootstrap state maint" | socat stdio tcp4-connect:@@{LBDNS.address}@@:9999
