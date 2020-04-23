# Deploy Red Hat Quay on OpenShift with Quay Setup Operator

Red Hat Quay 3.2

OpenShift cluster: You need a privileged account to an OpenShift 4.x cluster on which to deploy the Red Hat Quay Operator. That account must have the ability to create namespaces at the cluster scope. 

In this guide, I'll setup Quay & Clair with self-signed certificates (CA). 

ENV notes:
* My lab domain for this install is ```redcloud.land```.
* NFS dynamic provisioning is being used, referred as to ```auto-nfs```.
* All default environment accounts/passwords were unmodified.


### PreReqs

* An OpenShift 3.x or 4.x cluster
* Cluster-scope admin privilege to the OpenShift cluster
* Create a namespace for the Operator
```$ oc create ns quay-enterprise```
* Inject the CA.pem into a stored secret 
```$ oc create secret generic quayconfigfile --from-file=<path_to_file>```
* Inject the URL private crt/key into a secret for hostname mapping
```$ oc create secret generic custom-quay-ssl --from-file=ssl.key=<ssl_private_key> --from-file=ssl.cert=<ssl_certificate>```

Install the Operator itself, via the UI, navigate to Operators > Operator Hub > Search for "Quay"; you should see the Quay Operator provided by Red Hat, select it and choose "Install". 

Once the packages have been installed, visit "Installed Operators" and choose "Quay", if you don't see it; make sure that you have selected the project quay-enterprise or "all projects". Choose ```+Create Instance``` and replace the yaml file presented with your modified verison of ```quay-ecosystem.yaml``` (included for reference).

Because I'm using a private CA, I have to modify Clair to use the correct ```ca.crt```. Here I will patch the deployment to use the CA located in quayconfigfile which we created earlier.
```oc patch deployment.apps/quay-ecosystem-clair -p '{"spec":{"template":{"spec":{"volumes":[{"name":"quay-ssl","secret":{"secretName":"quayconfigfile","items":[{"key":"ca.crt","path":"ca.crt"}]}}]}}}}'```

More info ```https://github.com/redhat-cop/quay-operator```