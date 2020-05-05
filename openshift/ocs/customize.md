## Setting up OCS 4.3

1. Create 2 volumes on linux0, linux1 & linux2; chosen since nfs is on the same esxi host as linux1 - so we'll skip linux3 all together. \
   *Performed in ESXi*

2. Search for new disks, 100Gi on /dev/sdb & 10Gi on /dev/sdc \
```echo "- - -" > /sys/class/scsi_host/host0/scan```

   _check with ```fdisk /dev/sdX``` "F"_

3. Create the namespace: \
```oc create -f ocs-namespace.yaml```

4. Install the Operators: \
```oc create -f ocs-operator.yaml -f localstorage-operator.yaml```

5. Install the localstorage classes for mon & osd: \
```oc create -f localstorage-ocs-mon.yaml -f localstorage-ocs-osd.yaml```

6. Install OCS \
```oc create -f storagecluster.yaml```