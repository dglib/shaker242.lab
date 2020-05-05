## Setting up OCS 4.3

1. Create 2 volumes on linux0, linux1 & linux2; chosen since nfs is on the same esxi host as linux1 - so we'll skip linux3 all together. \
   *Performed in ESXi*

2. Search for new disks, 100Gi on /dev/sdb & 10Gi on /dev/sdc \
```echo "- - -" > /sys/class/scsi_host/host0/scan```

   _check with ```fdisk /dev/sdX``` "F"_

3. Label the nodes for OCS: \
```oc label nodes linux0 linux1 linux2 cluster.ocs.openshift.io/openshift-storage=''```

4. Create the namespace: \
```oc create -f ocs-namespace.yaml```

5. Install the Operators: \
```oc create -f ocs-operator.yaml -f localstorage-operator.yaml```

6. Install the localstorage classes for mon & osd: \
```oc create -f localstorage-ocs-mon.yaml -f localstorage-ocs-osd.yaml```

7. Install OCS \
```oc create -f storagecluster.yaml```

8. Enable the toolbox \
```oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'```


## Clean volumes if you have to... 
```
#!/usr/bin/env bash
DISK="/dev/sdb"
# Zap the disk to a fresh, usable state (zap-all is important, b/c MBR has to be clean)
# You will have to run this step for all disks.
sgdisk --zap-all $DISK
dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
```

## Forcefully remove a namespace...
```
#!/bin/bash

###############################################################################
# Copyright (c) 2018 Red Hat Inc
#
# See the NOTICE file(s) distributed with this work for additional
# information regarding copyright ownership.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License 2.0 which is available at
# http://www.eclipse.org/legal/epl-2.0
#
# SPDX-License-Identifier: EPL-2.0
###############################################################################

set -eo pipefail

die() { echo "$*" 1>&2 ; exit 1; }

need() {
        which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

# checking pre-reqs

need "jq"
need "curl"
need "kubectl"

PROJECT="$1"
shift

test -n "$PROJECT" || die "Missing arguments: kill-ns <namespace>"

kubectl proxy &>/dev/null &
PROXY_PID=$!
killproxy () {
        kill $PROXY_PID
}
trap killproxy EXIT

sleep 1 # give the proxy a second

kubectl get namespace "$PROJECT" -o json | jq 'del(.spec.finalizers[] | select("kubernetes"))' | curl -s -k -H "Content-Type: application/json" -X PUT -o /dev/null --data-binary @- http://localhost:8001/api/v1/namespaces/$PROJECT/finalize && echo "Killed namespace: $PROJECT"

# proxy will get killed by the trap
```
