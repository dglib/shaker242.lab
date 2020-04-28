cat <<EOF | kubectl apply -f - 
apiVersion: v1 
kind: Secret 
metadata:
  name: rook-tls 
  namespace: rook-ceph
data:
  tls.crt: $(sudo -i cat /Users/shaker/Downloads/_.apps.openshift.redcloud.land.crt | base64 | tr -d '\n')
  tls.key: $(sudo -i cat /Users/shaker/Downloads/_.apps.openshift.redcloud.land.key | base64 | tr -d '\n')
EOF
