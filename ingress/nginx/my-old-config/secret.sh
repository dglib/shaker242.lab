cat <<EOF | kubectl apply -f - 
apiVersion: v1 
kind: Secret 
metadata:
  name: default-server-secret 
  namespace: nginx-ingress
data:
  tls.crt: $(sudo -i cat /Users/shaker/shaker242.lab/intermediate/certs/wildcard.crt | base64 | tr -d '\n')
  tls.key: $(sudo -i cat /Users/shaker/shaker242.lab/intermediate/private/wildcard.key | base64 | tr -d '\n')
EOF
