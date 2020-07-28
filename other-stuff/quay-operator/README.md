## Installing Quay 3.3 with OCS 4.4 (noobaa/s3) on OCP 4.4 


# Deploy Red Hat Quay on OpenShift with Quay Setup Operator

Red Hat Quay 3.3

OpenShift cluster: You need a privileged account to an OpenShift 4.x cluster on which to deploy the Red Hat Quay Operator. That account must have the ability to create namespaces at the cluster scope. 

In this guide, I'll setup Quay & Clair with private self-signed certificates and ca, but only partially. 

---
### Environmental notes: quay-ecosystem.yaml

* My lab domain for this install is `redcloud.land`.
* NFS dynamic provisioning is being used, referred as to `auto-nfs`.
* All default environment accounts/passwords were unmodified.

---
### PreReqs
* An OpenShift 4.x cluster
* Cluster-scope admin privilege to the OpenShift cluster
* Create a namespace for the Operator \
``` oc new-project quay-enterprise --display-name "Red Hat Quay" ```

* Inject the CA.pem into a stored secret \
``` oc -n quay-enterprise create secret generic ca-redcloud --from-file=ca.crt=</path/to/ca.crt> ```

* Inject the URL private crt/key into a secret for hostname mapping \
``` cat quay.crt intermediate.crt ca.crt > quay-bundle.crt ``` \
``` oc create secret tls custom-quay-ssl --key=<quay.key> --cert=quay-bundle.crt ```

* Create the pull secret which provides credentials to pull containers from the Quay.io registry: \
``` oc create -f redhat-pull-secret.yaml ```

---
1. Install the Operator itself, via the UI, navigate to Operators > Operator Hub > Search for "Quay"; you should see the Quay Operator provided by Red Hat, select it and choose "Install".

2. Once the packages have been installed, visit "Installed Operators" and choose "Quay", if you don't see it; make sure that you have selected the project quay-enterprise or "all projects". Choose `+Create Instance` and replace the yaml file presented with your modified verison of `quay-ecosystem.yaml` (included for reference).

3. Deploy the QuayEcosystem without any storage configuration and make sure to include the custom CA certificate.

4. Access the quayconfig URL and select to Modify Configuration; and do so as you need. \
Add the setting for your Noobaa storage and LDAP. For Noobaa, use the endpoint and not the service if you're using a private cert... 

5. If you are using a private CA, inject it into the certificate section at the top. \
` Endpoint: s3-openshift-storage.apps.openshift.redcloud.land:443 `

6. Quay is kinda horrible... but to get it to work manually add the ca.crt (base64) into the quay-enterprise-config secret if you get a ssl error.




Troubleshooting Ref: \
https://github.com/redhat-cop/quay-operator/issues/137 \
https://access.redhat.com/solutions/4893721


More info ```https://github.com/redhat-cop/quay-operator```