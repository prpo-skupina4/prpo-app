# Deployment Setup - Next Steps

This document outlines the next steps required to complete the deployment setup for the FRITIME application.

## ✅ Completed in This PR

### 1. Deployment Configuration (prpo-app repository)
- [x] Created `deployment/` folder with all necessary files
- [x] Created `deploy-aks.sh` script with TAG substitution and rollout waiting
- [x] Created comprehensive `README.md` with documentation
- [x] Created `GITHUB_ACTIONS_GUIDE.md` with workflow instructions
- [x] Created all Kubernetes manifests for 6 microservices
- [x] Created ingress manifest with path-based routing
- [x] Validated all YAML files
- [x] Made deploy script executable

## 📋 Next Steps - Action Required

### 1. Configure GitHub Secrets in Microservice Repositories

For each of the following repositories, add Docker Hub secrets:

**Repositories:**
1. `prpo-skupina4/user-managment-ms`
2. `prpo-skupina4/kosilo-ms`
3. `prpo-skupina4/boolean-ms`
4. `prpo-skupina4/optimizator-ms`
5. `prpo-skupina4/Event-view-ms`
6. `prpo-skupina4/iCal-ms`

**Required Secrets:**
- `DOCKERHUB_USERNAME` - Your Docker Hub username
- `DOCKERHUB_TOKEN` - Your Docker Hub access token

**How to Add Secrets:**
1. Go to each repository on GitHub
2. Navigate to: Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add both secrets listed above

### 2. Add GitHub Actions Workflow to Each Microservice

For each microservice repository, create the file `.github/workflows/dockerhub.yml` with the workflow template from `deployment/GITHUB_ACTIONS_GUIDE.md`.

**Important:** Update the `IMAGE_NAME` environment variable for each service:

#### user-managment-ms
```yaml
env:
  IMAGE_NAME: adrian4096/user-managment-ms
```

#### kosilo-ms
```yaml
env:
  IMAGE_NAME: adrian4096/kosilo-ms
```

#### boolean-ms
```yaml
env:
  IMAGE_NAME: adrian4096/boolean-ms
```

#### optimizator-ms
```yaml
env:
  IMAGE_NAME: adrian4096/optimizator-ms
```

#### Event-view-ms
```yaml
env:
  IMAGE_NAME: adrian4096/event-view-ms
```

#### iCal-ms
```yaml
env:
  IMAGE_NAME: adrian4096/ical-ms
```

**Full workflow template available in:** `deployment/GITHUB_ACTIONS_GUIDE.md`

### 3. Verify Docker Images Build Successfully

After adding workflows:
1. Push a commit to the `main` or `dev` branch in each repository
2. Go to the Actions tab and verify the workflow runs successfully
3. Check Docker Hub to confirm images are pushed: https://hub.docker.com/u/adrian4096

### 4. Verify AKS Cluster Prerequisites

Before deploying, ensure:
- [x] AKS cluster exists (confirmed: `fritime` in resource group `prpo-dev`)
- [x] AKS App Routing is enabled
  ```bash
  az aks approuting enable --resource-group prpo-dev --name fritime
  ```
- [ ] kubectl is configured to connect to the cluster
  ```bash
  az aks get-credentials --resource-group prpo-dev --name fritime
  kubectl cluster-info
  ```

### 5. Deploy to AKS

Once Docker images are available and kubectl is configured:

```bash
cd deployment
./deploy-aks.sh
```

Or with custom configuration:
```bash
# Deploy with specific tag
TAG=abc1234 ./deploy-aks.sh

# Deploy to different namespace
NAMESPACE=prpo-staging ./deploy-aks.sh

# Combine options
NAMESPACE=prpo-prod TAG=v1.0.0 ./deploy-aks.sh
```

### 6. Verify Deployment

After deployment completes:

```bash
# Check pods
kubectl get pods -n prpo

# Check services
kubectl get svc -n prpo

# Check ingress
kubectl get ingress -n prpo

# Get ingress IP/hostname
kubectl get ingress prpo-ingress -n prpo -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

### 7. Test Endpoints

Once ingress has an external address:

```bash
INGRESS_IP=$(kubectl get ingress prpo-ingress -n prpo -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl http://${INGRESS_IP}/user-management/health
curl http://${INGRESS_IP}/kosilo/health
curl http://${INGRESS_IP}/boolean/health
curl http://${INGRESS_IP}/optimizator/health
curl http://${INGRESS_IP}/event-view/health
curl http://${INGRESS_IP}/ical/health
```

## 📚 Documentation

- **Deployment Guide**: `deployment/README.md`
- **GitHub Actions Guide**: `deployment/GITHUB_ACTIONS_GUIDE.md`
- **Kubernetes Manifests**: `deployment/manifests/`

## 🔄 CI/CD Workflow

Once everything is set up:

1. Developer pushes code to microservice repository (`main` or `dev` branch)
2. GitHub Actions builds Docker image and pushes to Docker Hub with:
   - Tag: `latest` (for main branch)
   - Tag: `<short-sha>` (git commit hash)
3. Deploy to AKS using the deploy script:
   ```bash
   TAG=<short-sha> ./deploy-aks.sh
   ```

## ⚠️ Important Notes

- **Service Name Spelling**: The service is intentionally named `user-managment-ms` (note the spelling). The ingress path `/user-management` is correctly spelled and is just the URL path.
- **Port Configuration**: All services expose container port 8000 internally, but are accessed via ClusterIP service on port 80.
- **Health Checks**: All services must implement a `/health` endpoint for Kubernetes liveness/readiness probes.
- **Namespace**: Default namespace is `prpo` but can be changed via the `NAMESPACE` environment variable.

## 🆘 Troubleshooting

Refer to the troubleshooting sections in:
- `deployment/README.md` - For deployment issues
- `deployment/GITHUB_ACTIONS_GUIDE.md` - For CI/CD issues

## ✅ Success Criteria

Your deployment is successful when:
- [ ] All 6 microservice workflows run successfully in GitHub Actions
- [ ] All 6 Docker images are available on Docker Hub
- [ ] kubectl can connect to the AKS cluster
- [ ] `./deploy-aks.sh` completes without errors
- [ ] All 6 pods are running: `kubectl get pods -n prpo`
- [ ] Ingress has an external IP: `kubectl get ingress -n prpo`
- [ ] All `/health` endpoints return successful responses

---

**For questions or issues, refer to the comprehensive guides in the `deployment/` folder.**
