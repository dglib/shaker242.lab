# Kubernetes Ingress for hotcuppa.co

Please note that I have pinned the default-http-backend service to specific labeled nodes:

`kubectl label nodes <node-name> <label-key>=<label-value>`

```
      nodeSelector: 
        role: ingress
```
I have also specified which nodePorts should be used to help make configurating external load balancing easier.

## NGINX

```
  ports:
  - name: http
    port: 80
    nodePort: 30080 # HTTP from Loadbalancer
    targetPort: 80
    protocol: TCP
  - name: https
    port: 443
    nodePort: 30443 # HTTPS from Loadbalancer
    targetPort: 443
    protocol: TCP
```
## TRAEFIK
### This configuration may not be complete, it's kind of a pain in the ass to setup.

```
  ports:
    - protocol: TCP
      port: 80
      nodePort: 30080
      name: web
```
