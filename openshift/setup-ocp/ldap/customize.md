## OAUTH STUFF

  ### Local Password and LDAP Authentication Configuration
1. Create the htpasswd secret from the htpasswd file in the openshift-config namespace: \
```oc create secret generic htpasswd --from-file=htpasswd -n openshift-config```

2. Create the idm-tls-ca ConfigMap: \
```oc create configmap -n openshift-config idm-tls-ca --from-file=ca.crt=idm-ca.crt```

3. Create the opentlc-ipa-bind-password secret: \
```oc  create secret generic -n openshift-config  idm-bind-password --from-literal=bindPassword='J5rdfv5e4!'```

4. Replace the OAuth configuration with the LDAP version in the oauth-config.yaml file: \
```oc replace -f oauth-both.yaml```

5. Create a new group called local-admin: \
```oc adm groups new local-admin```

6. Add the ocpadmin user to the local-admin group: \
```oc adm groups add-users local-admin ocpadmin```

 ### Update the default ingress cert...

7. Create a ConfigMap that includes the certificate authority used to signed the new certificate: \
```oc create configmap custom-ca --from-file=ca-bundle.crt=ca-homeland.crt -n openshift-config```

8. Update the cluster-wide proxy configuration with the newly created ConfigMap: \
```oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'```

9. Create a secret that contains the wildcard certificate and key: \
```oc create secret tls wildcard  --cert=_.apps.openshift.redcloud.land.crt --key=_.apps.openshift.redcloud.land.key -n openshift-ingress```

10. Update the Ingress Controller configuration with the newly created secret: \
```oc patch ingresscontroller.operator default --type=merge -p  '{"spec":{"defaultCertificate": {"name": "wildcard"}}}'  -n openshift-ingress-operator```

 ### Add RBAC Roles to Groups...

11. Run and Verify Group Synchronization \
```oc adm groups sync  --sync-config=oauth-ldap-sync.yaml --whitelist=ldap-whitelist-groups.txt  --confirm```

12. Create a cluster role binding to give cluster-admin rights to members of the local-admin group: \
```oc adm policy add-cluster-role-to-group cluster-admin local-admin``` \
```oc adm policy add-cluster-role-to-group cluster-admin ocp-admins```

13. Create the openshift-cluster-ops project for group sync resources: \
```oc adm new-project openshift-cluster-ops```

14. Create a cluster role binding to grant sudoer rights to members of the ocp-production group: \
```oc adm policy add-cluster-role-to-group sudoer ocp-production```

15. Restrict ocp-developers from creating projects: \
```oc annotate clusterrolebinding self-provisioners --overwrite 'rbac.authorization.kubernetes.io/autoupdate=false'``` \
```oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth``` \
```oc patch projects.config.openshift.io cluster --type=merge -p "$(cat ocp-dev-message.json)"```

16. Allow Production Administrators to Create Projects: \
```oc adm policy add-cluster-role-to-group self-provisioner ocp-production```

17. Remove kubeadmin: \
```oc delete secrets kubeadmin -n kube-system```