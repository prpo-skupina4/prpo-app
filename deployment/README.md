# Deployment Guide for FRITIME on Azure AKS

This directory contains deployment scripts and Kubernetes manifests for deploying the FRITIME application to Azure Kubernetes Service (AKS) using App Routing.

## Prerequisites

### Azure AKS Cluster
- An existing AKS cluster must be provisioned
- AKS App Routing must be enabled on the cluster
- Example command to enable App Routing:
  ```bash
  az aks approuting enable --resource-group prpo-dev --name fritime
  ```

### Local Environment
- `kubectl` CLI installed and configured
- kubectl context configured to point to your AKS cluster
- Verify with: `kubectl cluster-info`

### Docker Images
- All microservice Docker images must be built and pushed to Docker Hub
- Images are hosted under the `adrian4096` Docker Hub organization
- Required images:
  - `adrian4096/user-managment-ms`
  - `adrian4096/kosilo-ms`
  - `adrian4096/boolean-ms`
  - `adrian4096/optimizator-ms`
  - `adrian4096/event-view-ms`
  - `adrian4096/ical-ms`

## Architecture

### Microservices
The application consists of 6 microservices:

1. **user-managment-ms** - Authentication and authorization
2. **kosilo-ms** - Lunch scheduling
3. **boolean-ms** - Shared schedule management
4. **optimizator-ms** - Schedule optimization
5. **event-view-ms** - Schedule display
6. **ical-ms** - iCal data integration

All services expose port 8000 internally and have `/health` endpoints for liveness/readiness probes.

### Networking
- **Namespace**: `prpo`
- **Ingress Controller**: Azure App Routing (`webapprouting.kubernetes.azure.com`)
- **Ingress Type**: Path-based routing
- **Service Type**: ClusterIP (internal only)

### Routing Paths
The application is accessible through the following URL paths:

- `/user-management` → user-managment-ms service
- `/kosilo` → kosilo-ms service
- `/boolean` → boolean-ms service
- `/optimizator` → optimizator-ms service
- `/event-view` → event-view-ms service
- `/ical` → ical-ms service

## Deployment

### Quick Start
To deploy with default settings (namespace: `prpo`, image tag: `latest`):

```bash
cd deployment
./deploy-aks.sh
```

### Custom Configuration
You can customize the deployment using environment variables:

#### Deploy to a different namespace:
```bash
NAMESPACE=prpo-staging ./deploy-aks.sh
```

#### Deploy a specific image tag:
```bash
TAG=v1.2.3 ./deploy-aks.sh
```

#### Combine multiple options:
```bash
NAMESPACE=prpo-prod TAG=v1.2.3 ./deploy-aks.sh
```

### What the Script Does

The `deploy-aks.sh` script performs the following steps:

1. Validates that `kubectl` is installed and configured
2. Creates the namespace (if it doesn't exist)
3. Substitutes the `${TAG}` placeholder in all manifest files with the specified tag
4. Applies all Kubernetes manifests:
   - Namespace
   - Deployments and Services for all microservices
   - Ingress resource for path-based routing
5. Waits for all deployments to successfully roll out (timeout: 5 minutes per deployment)
6. Displays the status of pods and ingress

### Manual Deployment
If you prefer to deploy manually:

```bash
# Set your desired tag
export TAG=latest

# Apply namespace
kubectl apply -f manifests/namespace.yaml

# Apply service manifests (with TAG substitution)
for manifest in manifests/*.yaml; do
    if [[ "$manifest" != *"namespace.yaml"* ]] && [[ "$manifest" != *"ingress.yaml"* ]]; then
        sed "s/\${TAG}/${TAG}/g" "$manifest" | kubectl apply -f -
    fi
done

# Apply ingress
kubectl apply -f manifests/ingress.yaml

# Wait for rollouts
kubectl rollout status deployment/user-managment-ms -n prpo
kubectl rollout status deployment/kosilo-ms -n prpo
kubectl rollout status deployment/boolean-ms -n prpo
kubectl rollout status deployment/optimizator-ms -n prpo
kubectl rollout status deployment/event-view-ms -n prpo
kubectl rollout status deployment/ical-ms -n prpo
```

## Verification

### Check Pod Status
```bash
kubectl get pods -n prpo
```

All pods should be in `Running` state with ready status `1/1`.

### Check Services
```bash
kubectl get svc -n prpo
```

### Check Ingress
```bash
kubectl get ingress -n prpo
```

The ingress should show an external IP or hostname after a few minutes.

### Test Endpoints
Once the ingress has an external address, you can test the services:

```bash
# Get ingress address
INGRESS_ADDRESS=$(kubectl get ingress prpo-ingress -n prpo -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test health endpoints
curl http://${INGRESS_ADDRESS}/user-management/health
curl http://${INGRESS_ADDRESS}/kosilo/health
curl http://${INGRESS_ADDRESS}/boolean/health
curl http://${INGRESS_ADDRESS}/optimizator/health
curl http://${INGRESS_ADDRESS}/event-view/health
curl http://${INGRESS_ADDRESS}/ical/health
```

## Troubleshooting

### Pods not starting
```bash
# Check pod logs
kubectl logs -n prpo <pod-name>

# Describe pod for events
kubectl describe pod -n prpo <pod-name>
```

### Deployment stuck
```bash
# Check deployment status
kubectl describe deployment -n prpo <deployment-name>

# Check for image pull errors
kubectl get events -n prpo --sort-by='.lastTimestamp'
```

### Ingress not working
```bash
# Check ingress details
kubectl describe ingress prpo-ingress -n prpo

# Verify ingress controller is running
kubectl get pods -n app-routing-system
```

### Image pull errors
Ensure all Docker images are:
- Built and pushed to Docker Hub
- Tagged correctly (matching the TAG variable)
- Publicly accessible or credentials are configured

## Updating the Deployment

### Update to a new image version:
```bash
TAG=v1.2.4 ./deploy-aks.sh
```

The script will apply the new configuration and wait for rolling updates to complete.

### Update individual service:
```bash
kubectl set image deployment/user-managment-ms user-managment-ms=adrian4096/user-managment-ms:v1.2.4 -n prpo
kubectl rollout status deployment/user-managment-ms -n prpo
```

## Cleanup

### Remove all resources:
```bash
kubectl delete namespace prpo
```

This will remove all deployments, services, and the ingress in the namespace.

## CI/CD Integration

For automated deployments, the script can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Deploy to AKS
  env:
    TAG: ${{ github.sha }}
  run: |
    cd deployment
    ./deploy-aks.sh
```

## Additional Resources

- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Azure App Routing](https://learn.microsoft.com/en-us/azure/aks/app-routing)
