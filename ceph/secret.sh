cat <<EOF | kubectl apply -f - 
apiVersion: v1 
kind: Secret 
metadata:
  name: rook-tls 
  namespace: rook-ceph
data:
  tls.crt: $(sudo -i cat /Users/shaker/certs/_.apps.shaker242.lab.crt  | base64 | tr -d '\n')
  tls.key: $(sudo -i cat /Users/shaker/certs/_.apps.shaker242.lab.key | base64 | tr -d '\n')
EOF
