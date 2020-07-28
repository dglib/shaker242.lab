## SETUP REDCLOUD

### Accept all CSR's 
``` oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve ```


  ## Replace the default api certificate
1. Create the api-bundle certificate, in order indicated. \
``` cat api.crt intermediate.crt ca.crt > api-bundle.crt ```

2. Create the a secret to store the api-bundle. \
``` oc create secret tls api-redcloud-bundle --cert=api-bundle.crt --key=api.key -n openshift-config ```

3. Patch the API server with the new secret/api-bundle. \
``` oc patch apiserver cluster --type=merge -p '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.openshift.redcloud.land"],"servingCertificate": {"name": "api-redcloud-bundle"}}]}}}' ```

*You'll lose access with the .kube/config file; replace the data field "certificate-authority-data" with a base64 hash of your ca-bundle.crt below OR better yet, start over with the CA added. 

  ## Update the default ingress certificate

4. Create a ConfigMap that includes the certificate authority used to signed the new certificate: \
``` cat intermediate.crt ca.crt > ca-bundle.crt ``` \
``` oc create configmap custom-ca --from-file=ca-bundle.crt=ca-bundle.crt -n openshift-config ```

5. Update the cluster-wide proxy configuration with the newly created ConfigMap: \
``` oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}' ```

6. Create a secret that contains the wildcard certificate and key: \
``` oc create secret tls wildcard  --cert=apps.openshift.redcloud.land.crt --key=apps.openshift.redcloud.land.key -n openshift-ingress ```

7. Update the Ingress Controller configuration with the newly created secret: \
``` oc patch ingresscontroller.operator default --type=merge -p  '{"spec":{"defaultCertificate": {"name": "wildcard"}}}'  -n openshift-ingress-operator ```

  ## Local Password and LDAP Authentication Configuration

8. Create the htpasswd secret from the htpasswd file in the openshift-config namespace: \
``` oc create secret generic htpasswd --from-file=htpasswd -n openshift-config ```

9. Create the idm-tls-ca ConfigMap: \
``` oc create configmap -n openshift-config idm-tls-ca --from-file=ca.crt=idm-ca.crt ```

10. Create the opentlc-ipa-bind-password secret: \
``` oc  create secret generic -n openshift-config  idm-bind-password --from-literal=bindPassword='J5rdfv5e4!' ```

11. Replace the OAuth configuration with the LDAP version in the oauth-config.yaml file: \
``` oc replace -f oauth-both.yaml ```

12. Create a new group called local-admin: \
``` oc adm groups new local-admin ```

13. Add the ocpadmin user to the local-admin group: \
``` oc adm groups add-users local-admin ocpadmin ```


  ## Add RBAC Roles to Groups...

14. Run and Verify Group Synchronization \
``` oc adm groups sync  --sync-config=oauth-ldap-sync.yaml --whitelist=ldap-whitelist-groups.txt  --confirm ```

15. Create a cluster role binding to give cluster-admin rights to members of the local-admin group: \
``` oc adm policy add-cluster-role-to-group cluster-admin local-admin ``` \
``` oc adm policy add-cluster-role-to-group cluster-admin ocp-admins ```

16. Create the openshift-cluster-ops project for group sync resources: \
``` oc adm new-project openshift-cluster-ops ```

17. Cronjob the ldap sync: \
``` sh cronjob.sh ```

18. Create a cluster role binding to grant sudoer rights to members of the ocp-production group: \
``` oc adm policy add-cluster-role-to-group sudoer ocp-production ```

19. Restrict ocp-developers from creating projects: \
``` oc annotate clusterrolebinding self-provisioners --overwrite 'rbac.authorization.kubernetes.io/autoupdate=false' ``` \
``` oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth ``` \
``` oc patch projects.config.openshift.io cluster --type=merge -p "$(cat ocp-dev-message.json)" ```

20. Allow Production Administrators to Create Projects: \
``` oc adm policy add-cluster-role-to-group self-provisioner ocp-production ```

21. Remove kubeadmin: \
``` oc delete secrets kubeadmin -n kube-system ```


  ## Set up the registry

22. Create the PV/PVC Manually: \
``` oc create -f registry-nfs.yaml ```

23. Edit the operator: \
``` oc edit configs.imageregistry.operator.openshift.io ``` 

```
storage:
  pvc:
    claim: image-registry-storage
``` 
24. Add HA configuration by scaling to 2 pods: \
``` oc scale --replicas=2 deployment.apps/image-registry -n openshift-image-registry ```

25. Fix for 4.5 \
```oc patch imagepruner.imageregistry/cluster --patch '{"spec":{"suspend":true}}' --type=merge``` \
```oc -n openshift-image-registry delete jobs --all```


```
$ oc get machines                                                              
NAME                       PHASE   TYPE   REGION   ZONE   AGE
openshift-kkljw-master-0                                  36m
openshift-kkljw-master-1                                  36m
openshift-kkljw-master-2                                  36m

$ oc delete machine openshift-kkljw-master-0 openshift-kkljw-master-1 openshift-kkljw-master-2
machine.machine.openshift.io "openshift-kkljw-master-0" deleted
machine.machine.openshift.io "openshift-kkljw-master-1" deleted
machine.machine.openshift.io "openshift-kkljw-master-2" deleted

$ oc get machinesets                                                                          
NAME                     DESIRED   CURRENT   READY   AVAILABLE   AGE
openshift-kkljw-worker   0         0                             36m

$ oc delete machineset openshift-kkljw-worker                                                 
machineset.machine.openshift.io "openshift-kkljw-worker" deleted
```