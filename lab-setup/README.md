# SHAKER242 K8s Lab Setup

## Installing K8s shaker242.lab

haproxy 172.16.1.15
kubenfs 172.16.1.5

K8s masters (172.16.1.11, 12, 13)
K8s linux workers (172.16.1.21, 22, 23)
K8s windows workers (172.16.1.31, 32 ,33) *reserved

1. sshd-copy-id {all nodes}
2. kubeadm config images pull {all managers}
3. create kubeadm-config.yaml with the internal-lb of the master nodes and port:6443
```
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "172.16.1.15:6443"
networking:
  serviceSubnet: "10.96.0.0/12"
  #podSubnet: "192.168.0.0/16" (used for Calico)
  dnsDomain: "shaker242.lab"
```

4. Initialized the install and let kubeadm manage cert uploads
```
sudo kubeadm init --config=kubeadm-config.yaml --upload-certs
```

Configure management access on first controller
To start using your cluster, you need to run the following as a regular user:
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

5. follow instructions to join controllers/managers and worker nodes using kubeadm
6. apply networking, this install I'm using Weave Net vs Calico
```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
..* note: for Calico the init phase (step 4) would include the cidr string "--pod-network-cidr=192.168.0.0/16"  

7. deploy the cluster wide metrics server
```
kubectl create -f deploy/1.8+/
```

## Optional - Deploy and access the Kubernetes Dashboard

Create a service account with cluster-admin role that will have access to all your resources.
```
kubectl create serviceaccount cluster-admin-dashboard-sa
kubectl create clusterrolebinding cluster-admin-dashboard-sa \
  --clusterrole=cluster-admin \
  --serviceaccount=default:cluster-admin-dashboard-sa
```

Copy the token from the generated secret

```
kubectl get secret | grep cluster-admin-dashboard-sa
cluster-admin-dashboard-sa-token-mpc47   kubernetes.io/service-account-token   3      18s

kubectl describe secret cluster-admin-dashboard-sa-token-mpc47
Name:         cluster-admin-dashboard-sa-token-mpc47
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: cluster-admin-dashboard-sa
              kubernetes.io/service-account.uid: 7f38e80b-0d57-490f-898b-f8effc85a313

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImNsdXN0ZXItYWRtaW4tZGFzaGJvYXJkLXNhLXRva2VuLW1wYzQ3Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImNsdXN0ZXItYWRtaW4tZGFzaGJvYXJkLXNhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiN2YzOGU4MGItMGQ1Ny00OTBmLTg5OGItZjhlZmZjODVhMzEzIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6Y2x1c3Rlci1hZG1pbi1kYXNoYm9hcmQtc2EifQk2x3FB4GYbZcyx0yOX1lbgKkjOLiG7TzNtsztmWqupJHL2jnO_464aZ0mC4REpq1Gbt2lnY5otLpwpQSAW53sjZB_9GQs6Itecl41NRPgIVGHnSFCeMRYxKYT3YkQvYKUsupPxqm1X8sZdZOKqTcfN9hwvl6Sc2pUeaq2RoGvtsdQ21WA-hXzLkKedytEpmTi6hdKJQNMgTT21c8YZPjsDdpoWpLArXlkgv28BIDKun7x62xS4ERnqXoeLa_JNvQDqid9phfTmEC5gQUAkeV45kyFl-lgAySSjf8zmXpc-n255m-XRuop0mwl_QmqyefMbYEKtGaOifEReyBMa4_uA
```
***Use this token to log into the dashboard.***

## Deploy the kubernetes-dashboard
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

Enable the proxy from your admin (.kube/config) workstation.
```
kubectl proxy
```

Access the dashboard via this URL
```
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```
