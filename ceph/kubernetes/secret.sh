cat <<EOF | kubectl apply -f - 
apiVersion: v1 
kind: Secret 
metadata:
  name: rook-tls 
  namespace: rook-ceph
data:
  tls.crt: $(sudo -i cat /ca/intermediate/certs/wildcard.pem | base64 | tr -d '\n')
  tls.key: $(sudo -i cat /ca/intermediate/private/wildcard.key | base64 | tr -d '\n')
EOF
