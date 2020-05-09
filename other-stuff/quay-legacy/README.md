# Deploy Red Hat Quay on OpenShift without the Quay Setup Operator (legacy)

Red Hat Quay 3.2

In this guide, I'll setup Quay & Clair with self-signed certificates (CA). 

---
### Environmental notes:

* My lab domain for this install is ```redcloud.land```.
* NFS dynamic provisioning is being used, referred as to ```auto-nfs```.
* We will use OCS 4.3 (S3/noobaa) for the registry storage bucket.

---
### PreReqs
* An OpenShift 4.x cluster
* Cluster-scope admin privilege to the OpenShift cluster
* Create a namespace for the Operator \
```$ oc create -f k8s/quay-enterprise-namespace.yaml```
* Inject the CA.pem into a stored secret \
```$ oc -n quay-enterprise create secret generic ca-redcloud --from-file=ca.crt=<path_to_file>```
* Inject the URL private crt/key into a secret for hostname mapping \
```$ oc -n quay-enterprise create secret generic custom-quay-ssl --from-file=ssl.key=<ssl_private_key> --from-file=ssl.cert=<ssl_certificate> ```

### Installation 
