#oc new-project openshift-cluster-ops

oc --user=admin process --local \
  -f openshift-management/jobs/cronjob-ldap-group-sync-secure.yml \
  -p NAMESPACE='openshift-cluster-ops' \
  -p LDAP_URL=ldaps://idm.redcloud.land:636 \
  -p LDAP_BIND_DN=uid=admin,cn=users,cn=accounts,dc=redcloud,dc=land \
  -p LDAP_BIND_PASSWORD='J5rdfv5e4!' \
  -p LDAP_CA_CERT="$(cat idm-ca.crt)" \
  -p LDAP_GROUP_UID_ATTRIBUTE='dn' \
  -p LDAP_GROUPS_FILTER='(objectClass=groupofnames)' \
  -p LDAP_GROUPS_SEARCH_BASE='cn=groups,cn=accounts,dc=redcloud,dc=land' \
  -p LDAP_GROUPS_WHITELIST="$(cat ldap-whitelist-groups.txt)" \
  -p LDAP_USERS_SEARCH_BASE='cn=users,cn=accounts,dc=redcloud,dc=land' \
  -p SCHEDULE='*/15 * * * *' \
  | oc --user=admin apply -f -
