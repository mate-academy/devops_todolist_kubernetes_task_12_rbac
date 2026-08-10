# Forwards cluster MySQL to localhost:3307 (avoids conflict with local MySQL on 3306).
kubectl port-forward -n mysql svc/mysql 3307:3306
