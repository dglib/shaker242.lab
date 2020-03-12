# Kubernetes NFS

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
The second method is dynamic provisioning where a share is provided and volumes are created and claimed on demand with just passing a PersistentVolumeClaim. This is now the "default" for me.

Review which nfs driver is set for default
```
$ kubectl get sc
NAME                            PROVISIONER         AGE
managed-nfs-storage (default)   fuseim.pri/ifs      19d
nfs                             kubernetes.io/nfs   19d
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

### NFS Setup /etc/exports
```
#-----------------

# You have accessed the NFS server for shaker242.lab

- 172.16.1.5
  /nfs/autonfs (container dynamic provisioning)
  /nfs/default (container manual provisioning - driver nfs)

#-----------------

# /etc/exports
#
# See exports(5) for a description.

# use exportfs -arv to reread
#/export    192.168.1.10(rw,no_root_squash)

/nfs/autonfs *(rw,sync,no_subtree_check,no_root_squash) # << Dynamic Provisioning >>
/nfs/default *(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534) # << Manual Provisioning >>
```


My NFS Server is running on Alpine Linux.
```
nfs:~$ ls -l /nfs/
total 4
drwxrwxr-x    7 root     root          4096 Mar 12 13:21 autonfs
drwxr-xr-x    2 nobody   nobody           6 Mar  1 01:32 default
```