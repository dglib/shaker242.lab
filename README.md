# Lab Environment
It is highly possible that what may help you could be found here; althought, it is equally possilbe
that what you find here is merely more frustration. I constantly tweek, break and set my lab on fire.

### Replacing the default ingress certificate 
oc create configmap custom-ca --from-file=ca-bundle.crt=ca-homeland.crt -n openshift-config
oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'
oc create secret tls wildcard --cert=_.apps.openshift.redcloud.land.crt --key=_.apps.openshift.redcloud.land.key -n openshift-ingress
oc patch ingresscontroller.operator default --type=merge -p '{"spec":{"defaultCertificate": {"name": "wildcard"}}}' -n openshift-ingress-operator