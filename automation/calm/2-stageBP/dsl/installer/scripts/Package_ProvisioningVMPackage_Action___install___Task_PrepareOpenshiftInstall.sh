#!/bin/bash -e
# Use macro from controlplane set var task to delay task execution
CONTROLPLANE_STATUS="@@{ControlPlane.CONTROLPLANE_STATUS}@@"

cd openshift
# Wait for bootstrap completion
sudo openshift-install wait-for bootstrap-complete --log-level debug