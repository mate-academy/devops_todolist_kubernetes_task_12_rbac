Instructions to Validate Changes
Spin Up a Kind Cluster: Use the kind create cluster --config cluster.yml command to create a cluster.

Apply RBAC Manifest: Run kubectl apply -f security/rbac.yaml to apply the RBAC configuration.

Apply Deployment Manifest: Run kubectl apply -f deployment.yaml to deploy the application.

Check Deployment Logs: Use kubectl logs -f <pod-name> to view the output of the curl command.

Validate Secret Listing: Ensure that the deployment successfully lists secrets from the Kubernetes API.