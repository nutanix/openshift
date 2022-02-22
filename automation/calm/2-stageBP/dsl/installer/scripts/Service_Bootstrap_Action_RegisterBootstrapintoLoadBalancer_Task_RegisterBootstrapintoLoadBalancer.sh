echo "set server machine-config-server/bootstrap addr @@{address}@@" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999
echo "set server machine-config-server/bootstrap state ready" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999

echo "set server openshift-api-server/bootstrap addr @@{address}@@" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999
echo "set server openshift-api-server/bootstrap state ready" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999
