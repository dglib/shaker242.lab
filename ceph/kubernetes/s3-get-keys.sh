kubectl -n rook-ceph get secret rook-ceph-rgw-s3-store-a-keyring -o yaml | grep AccessKey | awk '{print $2}' | base64 --decode
kubectl -n rook-ceph get secret rook-ceph-object-user-s3-store-s3-user -o yaml | grep SecretKey | awk '{print $2}' | base64 --decode

