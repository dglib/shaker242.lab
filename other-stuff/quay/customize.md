# Deploy Red Hat Quay on OpenShift with Quay Setup Operator

Red Hat Quay 3.2

OpenShift cluster: You need a privileged account to an OpenShift 4.x cluster on which to deploy the Red Hat Quay Operator. That account must have the ability to create namespaces at the cluster scope. 

In this guide, I'll setup Quay & Clair with self-signed certificates (CA). 

---
### Environmental notes:

* My lab domain for this install is ```redcloud.land```.
* NFS dynamic provisioning is being used, referred as to ```auto-nfs```.
* All default environment accounts/passwords were unmodified.

---
### PreReqs
* An OpenShift 3.x or 4.x cluster
* Cluster-scope admin privilege to the OpenShift cluster
* Create a namespace for the Operator \
```$ oc create ns quay-enterprise```
* Inject the CA.pem into a stored secret \
```$ oc -n quay-enterprise create secret generic ca-redcloud --from-file=ca.crt=<path_to_file>```
* Inject the URL private crt/key into a secret for hostname mapping \
```$ oc -n quay-enterprise create secret generic custom-quay-ssl --from-file=ssl.key=<ssl_private_key> --from-file=ssl.cert=<ssl_certificate> ```

---
Install the Operator itself, via the UI, navigate to Operators > Operator Hub > Search for "Quay"; you should see the Quay Operator provided by Red Hat, select it and choose "Install".

Once the packages have been installed, visit "Installed Operators" and choose "Quay", if you don't see it; make sure that you have selected the project quay-enterprise or "all projects". Choose ```+Create Instance``` and replace the yaml file presented with your modified verison of ```quay-ecosystem.yaml``` (included for reference).

## *SSL error when deploying Quay with a RHOCS storage backend - fix.*
>> See: https://access.redhat.com/solutions/4893721 for resolution

1. Deploy the QuayEcosystem without any storage configuration and make sure to include the custom CA certificate.

2. Reconfigure the generated quay config which is stored in a secret called quay-enterprise-config-secret. \
```oc get -n quay-enterprise secret quay-enterprise-config-secret -o yaml | grep config.yaml | awk '{ print $2}' | base64 -d > config_tmp.yaml```

3. Replace the default config with noobaa config. 
```
DISTRIBUTED_STORAGE_CONFIG:
  default:
  - LocalStorage
  - storage_path: /datastorage/registry
DISTRIBUTED_STORAGE_DEFAULT_LOCATIONS: []
```
example:
```
DISTRIBUTED_STORAGE_CONFIG:
  default:
  - RHOCSStorage
  - access_key: YOUR_ACCESSKEY
    bucket_name: YOUR_BUCKETNAME
    hostname: s3.openshift-storage.svc
    is_secure: true
    port: '443'
    secret_key: YOUR_SECRETKEY
    storage_path: /datastorage/registry
DISTRIBUTED_STORAGE_DEFAULT_LOCATIONS: []
```

4. Patch the quay-enterprise-config-secret. \
``` export CONFIG=`cat config_tmp.yaml|base64 -w0` ``` \
``` oc patch -n quay-enterprise secret quay-enterprise-config-secret -p "{\"data\":{\"config.yaml\":\"$CONFIG\"}}" ```

5. Restart the Red Hat Quay pods. \
``` oc delete pod -l quay-enterprise-cr=quay-ecosystem -n quay-enterprise ```

6. Because I'm using a private CA, I have to modify Clair to use the correct ```ca.crt```. Here I will patch the deployment to use the CA located in ca-redcloud which we created earlier. 

``` oc -n quay-enterprise patch deployment.apps/quay-ecosystem-clair -p '{"spec":{"template":{"spec":{"volumes":[{"name":"quay-ssl","secret":{"secretName":"ca-redcloud","items":[{"key":"ca.crt","path":"ca.crt"}]}}]}}}}' ```

~~7. If Clair is used, it must also be aware of the custom certificate, otherwise it can't connect to the RHOCS NooBaa S3 service. In order to do that, created a separate Secret containing the certificate and patched the quay-clair deployment: \
``` cat openshift-service.ca > ca.crt ``` \
``` oc create secret generic quay-cert --from-file=ca.crt ``` \
``` oc set volume deployment/quay-clair --add --name=quay-ssl --type=secret --secret-name=quay-cert --overwrite ```~~

~~* If a custom SSL certificate is used in Red Hat Quay (sslCertificatesSecretName in QuayEcosystem) and if this custom SSL certificate is signed by a custom CA, Clair will not be able to connect to the quay instance, as Clair checks for the signer, not for the certificate itself.
In this case the ca certificate (the signer) also needs to be part of the previously mentioned ca.crt file. Concatenate it before creating the secret:~~

More info ```https://github.com/redhat-cop/quay-operator```