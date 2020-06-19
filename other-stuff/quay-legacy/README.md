# Deploy Red Hat Quay on OpenShift without the Quay Setup Operator (legacy)

Red Hat Quay 3.2

In this guide, I'll setup Quay & Clair with self-signed certificates (CA). 

---
### Environmental notes

* My lab domain for this install is ```redcloud.land```.
* NFS dynamic provisioning is being used for postgres, referred as to ```auto-nfs```.
* We will use OCS 4.3 (S3/noobaa) for the registry storage bucket; hopefully.

---
### PreReqs
* An OpenShift 4.x cluster
* Cluster-scope admin privilege to the OpenShift cluster
* Create a namespace for the Operator \
``` oc create -f k8s/quay-enterprise-namespace.yaml```

* Inject the CA.pem into a stored secret \
``` oc -n quay-enterprise create secret generic ca-redcloud --from-file=ca.crt=ca.crt ```

* Inject the URL private crt/key into a secret for hostname mapping \
``` cat quay.crt intermediate.crt ca.crt > quay-bundle.crt ``` \
``` oc -n quay-enterprise create secret generic custom-quay-ssl --from-file=ssl.key=quay.key --from-file=ssl.cert=quay-bundle.crt ```


### Installation 

1. The documented instructions have you create an empty config secret: \
``` oc create -f k8s/quay-enterprise-config-secret.yaml ```

2. Create the pull secret which provides credentials to pull containers from the Quay.io registry: \
``` oc create -f k8s/redhat-pull-secret.yaml ```

3. Create the postgres database pvc: \
``` oc create -f k8s/db-pvc.yaml ```

4. Create a serviceaccount for the database and grant it anyuid privileges. Running the PostgreSQL deployment under anyuid lets you add persistent storage to the deployment and allow it to store db metadata. \
``` oc create serviceaccount postgres -n quay-enterprise ``` \
``` oc adm policy add-scc-to-user anyuid -z system:serviceaccount:quay-enterprise:postgres scc "anyuid" added to: ["system:serviceaccount:quay-enterprise:system:serviceaccount:quay-enterprise:postgres"] ```

5. Create ROLE & ROLEBINDING: \
``` oc create -f k8s/quay-servicetoken-role-k8s1-6.yaml ``` \
``` oc create -f k8s/quay-servicetoken-role-binding-k8s1-6.yaml ```

6. Install postgres & service: \
``` oc create -f k8s/postgres-deployment.yaml ``` \
``` oc create -f k8s/postgres-service.yaml ```

7. Run the following command, replacing the name of the postgres pod with your pod: \
``` oc exec -it postgres-fcf889dfb-pj2cg -n quay-enterprise -- /bin/bash -c 'echo "CREATE EXTENSION IF NOT EXISTS pg_trgm" | /usr/bin/psql -d quay' ```

8. Create Redis key-value-store: \
``` oc create -f k8s/quay-enterprise-redis.yaml ```

9. Set up to CONFIGURE Red Hat Quay: \
``` oc create -f k8s/quay-enterprise-config.yaml ``` \
``` oc create -f k8s/quay-enterprise-config-service-clusterip.yaml ``` \
``` oc create -f openshift/quay-enterprise-config-route.yaml ```

10. Start the Red Hat Quay application: \
``` oc create -f k8s/quay-enterprise-service-clusterip.yaml ``` \
``` oc create -f k8s/quay-enterprise-app-rc.yaml ``` \
``` oc create -f openshift/quay-enterprise-app-route.yaml ``` 

*Note: The pod/quay-enterprise-app-xxxxxxx will remain in a "ContainerCreating" state until the configuration is complete.

oc create -f k8s/postgres-clair-storage.yaml -f k8s/postgres-clair-deployment.yaml -f k8s/postgres-clair-service.yaml

oc create secret generic clair-scanner-config-secret --from-file=config.yaml=k8s/clair-config.yaml --from-file=security_scanner.pem=security_scanner.pem

oc create -f k8s/clair-service.yaml -f k8s/clair-deployment.yaml