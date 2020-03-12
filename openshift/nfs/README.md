# Kubernetes NFS on Docker Enterprise 2.1

 I am presenting two methonds, the first supports the default nfs native provisioning driver. To use this one, you will require the storage class and then pre-provision persistent volumes that can then be claimed by deployments. PersistentVolume and PersistentVolumeClaim's may be a part of your Kubernetes YAML.

```
# In deployments... (example)
        volumeMounts:
        - name: app-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: app-persistent-storage
        persistentVolumeClaim:
          claimName: app-pv1-claim
```
The second method is dynamic provisioning where a share is provided and volumes are created and claimed on demand.

Review which nfs driver is set for default
```
$ kubectl get sc
NAME                  PROVISIONER         AGE
managed-nfs-storage   auto-nfs            1d
nfs (default)         kubernetes.io/nfs   1d
```
Add annotations to specify alternate drivers should be used.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pv1-claim
    annotations:
     volume.beta.kubernetes.io/storage-class: "managed-nfs-storage"
  labels:
    app: myapp
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```