echo "set server machine-config-server/controlplane@@{calm_array_index}@@ addr @@{address}@@" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999
echo "set server machine-config-server/controlplane@@{calm_array_index}@@ state ready" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999

echo "set server openshift-api-server/controlplane@@{calm_array_index}@@ addr @@{address}@@" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999
echo "set server openshift-api-server/controlplane@@{calm_array_index}@@ state ready" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999