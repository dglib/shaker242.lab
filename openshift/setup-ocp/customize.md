### Replacing the default ingress certificate 
oc create configmap custom-ca --from-file=ca-bundle.crt=ca-homeland.crt -n openshift-config
oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'
oc create secret tls wildcard --cert=_.apps.openshift.redcloud.land.crt --key=_.apps.openshift.redcloud.land.key -n openshift-ingress
oc patch ingresscontroller.operator default --type=merge -p '{"spec":{"defaultCertificate": {"name": "wildcard"}}}' -n openshift-ingress-operator


### Replace the default api certificate
cat api.crt intermediate.crt ca.crt > api-bundle.crt
oc create secret tls api-redcloud-bundle --cert=api-bundle.crt --key=api.key -n openshift-config
oc patch apiserver cluster --type=merge -p '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.openshift.redcloud.land"],"servingCertificate": {"name": "api-redcloud-bundle"}}]}}}'


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