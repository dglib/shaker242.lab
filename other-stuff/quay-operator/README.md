## Installing Quay 3.2 with OCS 4.3 (noobaa/s3) on OCP 4.3 doesn't work right <eye-roll>

## 7 days in and I have an additional fix in place that; for a time, solved my issue.
Evidently when you use a private CA the 'extraCaCert' property doesn't work properly. Go through these steps, and you'll see the CA part at the end I had to use.


Ref: \
https://github.com/redhat-cop/quay-operator/issues/137 \
https://access.redhat.com/solutions/4893721


# Deploy Red Hat Quay on OpenShift with Quay Setup Operator

Red Hat Quay 3.2

OpenShift cluster: You need a privileged account to an OpenShift 4.x cluster on which to deploy the Red Hat Quay Operator. That account must have the ability to create namespaces at the cluster scope. 

In this guide, I'll setup Quay & Clair with self-signed certificates (CA). 

---
### Environmental notes: quay-ecosystem.yaml

* My lab domain for this install is ```redcloud.land```.
* NFS dynamic provisioning is being used, referred as to ```auto-nfs```.
* All default environment accounts/passwords were unmodified.

---
### PreReqs
* An OpenShift 4.x cluster
* Cluster-scope admin privilege to the OpenShift cluster
* Create a namespace for the Operator \
```$ oc create ns quay-enterprise```

* Inject the CA.pem into a stored secret \
```$ oc -n quay-enterprise create secret generic ca-redcloud --from-file=ca.crt=<path_to_file>```

* Inject the URL private crt/key into a secret for hostname mapping \
```$ oc -n quay-enterprise create secret tls custom-quay-ssl --from-file=ssl.key=<ssl_private_key> --from-file=ssl.cert=<ssl_certificate> ```

* Create the pull secret which provides credentials to pull containers from the Quay.io registry: \
``` oc create -f redhat-pull-secret.yaml ```

---
Install the Operator itself, via the UI, navigate to Operators > Operator Hub > Search for "Quay"; you should see the Quay Operator provided by Red Hat, select it and choose "Install".

Once the packages have been installed, visit "Installed Operators" and choose "Quay", if you don't see it; make sure that you have selected the project quay-enterprise or "all projects". Choose ```+Create Instance``` and replace the yaml file presented with your modified verison of ```quay-ecosystem.yaml``` (included for reference).

## *SSL error when deploying Quay with a RHOCS storage backend - fix.*
>> See: https://access.redhat.com/solutions/4893721 for resolution

1. Deploy the QuayEcosystem without any storage configuration and make sure to include the custom CA certificate.

      ## Stop! You have a choice to make here:

      i. Access the config route and setup LDAP/OAUT stuff if you intend to use it and save the config (don't setup storage at this point).
      
      ii. Continue without modifying the config for LDAP, just know that once Noobaa is setup, modifying the configuration may break your setup. Keep that config backup (the one you're about to grap in the below step 2).

2. Reconfigure the generated quay config which is stored in a secret called quay-enterprise-config-secret. \
``` oc get -n quay-enterprise secret quay-enterprise-config-secret -o yaml | grep config.yaml | awk '{ print $2}' | base64 -d > config_tmp.yaml ```

3. Replace the default config with noobaa config:

      ```
      DISTRIBUTED_STORAGE_CONFIG:
        default:tls
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

6. Because I'm using a private CA, I have to modify Clair to use the correct ```ca.crt```. Here I will patch the deployment to use the CA located in ca-redcloud which we created earlier: \
``` oc -n quay-enterprise patch deployment.apps/quay-ecosystem-clair -p '{"spec":{"template":{"spec":{"volumes":[{"name":"quay-ssl","secret":{"secretName":"ca-redcloud","items":[{"key":"ca.crt","path":"ca.crt"}]}}]}}}}' ```

7. Because we have a hacky setup now; Why are you using an Operator? Anyway, I found that the ca.cert in extraCACert wasn't being uploaded in the config. Let's put it there ourselves.

      i. Copy these contents and we'll manually edit the config file: \
      ``` cat ca.crt | base64 -w 0 ```

      ii. Edit the config secret: \
      ``` oc -n quay-enterprise edit secret quay-enterprise-config-secret ```

      iii. Add the entry yourself, I put it after the "data:|config.yaml:" entry and above the ssl.cert, ssl.key: \
      ```
        custom-cert.crt: LS0tLS1CRUdJTiBDRVJUSUZJ...
      ```

      iv. Now restart the pods again: \
      ``` oc delete pod -l quay-enterprise-cr=quay-ecosystem -n quay-enterprise ```


More info ```https://github.com/redhat-cop/quay-operator```