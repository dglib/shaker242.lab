## Set up the registry

1. Create the PV/PVC Manually: \
```oc create -f registry-nfs.yaml```

2. Edit the operator: \
```oc edit configs.imageregistry.operator.openshift.io``` 

```
storage:
  pvc:
    claim: image-registry-storage
```