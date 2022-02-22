echo "set server ingress-http/compute@@{calm_array_index}@@ addr @@{address}@@" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999
echo "set server ingress-http/compute@@{calm_array_index}@@ state ready" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999

echo "set server ingress-https/compute@@{calm_array_index}@@ addr @@{address}@@" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999
echo "set server ingress-https/compute@@{calm_array_index}@@ state ready" | socat stdio tcp4-connect:@@{LB_TARGET}@@:9999