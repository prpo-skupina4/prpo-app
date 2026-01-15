# GitHub Actions Workflow for Microservice Repositories

This document describes the GitHub Actions workflow that should be added to each microservice repository to build and push Docker images to Docker Hub.

## Repositories

The following microservice repositories need this workflow:

1. `prpo-skupina4/user-managment-ms`
2. `prpo-skupina4/kosilo-ms`
3. `prpo-skupina4/boolean-ms`
4. `prpo-skupina4/optimizator-ms`
5. `prpo-skupina4/Event-view-ms`
6. `prpo-skupina4/iCal-ms`

## Prerequisites

### Docker Hub Setup
- Docker Hub account with organization: `adrian4096`
- Docker Hub Access Token created

### GitHub Secrets
Each repository must have the following secrets configured:
- `DOCKERHUB_USERNAME` - Docker Hub username
- `DOCKERHUB_TOKEN` - Docker Hub access token

To add secrets to a repository:
1. Go to repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add both `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`

## Workflow File

Create the file `.github/workflows/dockerhub.yml` in each microservice repository with the content below.

**Important**: Update the `IMAGE_NAME` environment variable for each service to match the correct Docker Hub repository name.

### Template: `.github/workflows/dockerhub.yml`

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main
      - dev
  workflow_dispatch:

env:
  # UPDATE THIS for each microservice!
  # user-managment-ms:    IMAGE_NAME: adrian4096/user-managment-ms
  # kosilo-ms:            IMAGE_NAME: adrian4096/kosilo-ms
  # boolean-ms:           IMAGE_NAME: adrian4096/boolean-ms
  # optimizator-ms:       IMAGE_NAME: adrian4096/optimizator-ms
  # Event-view-ms:        IMAGE_NAME: adrian4096/event-view-ms
  # iCal-ms:              IMAGE_NAME: adrian4096/ical-ms
  IMAGE_NAME: adrian4096/CHANGE-ME

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.IMAGE_NAME }}
          tags: |
            type=raw,value=latest,enable={{is_default_branch}}
            type=sha,prefix=,format=short
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Per-Repository Configuration

For each repository, create `.github/workflows/dockerhub.yml` with the appropriate `IMAGE_NAME`:

### 1. user-managment-ms
```yaml
env:
  IMAGE_NAME: adrian4096/user-managment-ms
```

### 2. kosilo-ms
```yaml
env:
  IMAGE_NAME: adrian4096/kosilo-ms
```

### 3. boolean-ms
```yaml
env:
  IMAGE_NAME: adrian4096/boolean-ms
```

### 4. optimizator-ms
```yaml
env:
  IMAGE_NAME: adrian4096/optimizator-ms
```

### 5. Event-view-ms
```yaml
env:
  IMAGE_NAME: adrian4096/event-view-ms
```

### 6. iCal-ms
```yaml
env:
  IMAGE_NAME: adrian4096/ical-ms
```

## Workflow Behavior

### Triggers
- **Automatic**: Pushes to `main` or `dev` branches
- **Manual**: Via "Run workflow" button in GitHub Actions tab (workflow_dispatch)

### Image Tags
The workflow creates two tags for each build:
1. **`latest`** - Only on the default branch (usually `main`)
2. **Short SHA** - Git commit SHA (first 7 characters), e.g., `abc1234`

Examples:
- Push to main: `adrian4096/kosilo-ms:latest` and `adrian4096/kosilo-ms:abc1234`
- Push to dev: `adrian4096/kosilo-ms:abc1234` (no `latest` tag)

### Build Process
1. Checks out the repository code
2. Sets up Docker Buildx for advanced build features
3. Logs into Docker Hub using secrets
4. Extracts metadata and generates tags
5. Builds Docker image from `./Dockerfile` with context `.`
6. Pushes image to Docker Hub
7. Uses GitHub Actions cache to speed up builds

## Dockerfile Requirements

Each repository must have a `Dockerfile` in the root directory that:
- Exposes port 8000
- Implements a `/health` endpoint
- Can be built with context `.`

Example minimal Dockerfile structure:
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Verification

### Check Workflow Status
1. Go to repository → Actions tab
2. Find the "Build and Push Docker Image" workflow
3. Check that the workflow completes successfully

### Verify Docker Hub
1. Go to https://hub.docker.com/u/adrian4096
2. Check that the image repository exists
3. Verify that tags are present (latest and SHA)

### Test Image Pull
```bash
docker pull adrian4096/kosilo-ms:latest
docker run -p 8000:8000 adrian4096/kosilo-ms:latest
curl http://localhost:8000/health
```

## Troubleshooting

### Authentication Failed
- Verify `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets are set correctly
- Ensure the Docker Hub token has write permissions
- Check that the token hasn't expired

### Dockerfile Not Found
- Ensure `Dockerfile` exists in the repository root
- Check that the file is named exactly `Dockerfile` (case-sensitive)
- Verify the repository structure matches expectations

### Push Permission Denied
- Verify the Docker Hub username in `IMAGE_NAME` is correct
- Ensure the user has push permissions to the Docker Hub organization
- Check that the repository name in `IMAGE_NAME` matches Docker Hub

### Build Failures
- Check the Dockerfile syntax
- Ensure all dependencies are available
- Review build logs in GitHub Actions for specific errors

## Integration with Deployment

Once the workflow is set up and images are pushed to Docker Hub, they can be deployed to AKS using:

```bash
# Deploy latest images
cd deployment
./deploy-aks.sh

# Deploy specific version by SHA
TAG=abc1234 ./deploy-aks.sh
```

## Additional Notes

- The workflow uses GitHub Actions cache to speed up subsequent builds
- BuildKit is enabled for better build performance
- Multi-platform builds can be added by specifying `platforms` in the build-push action
- The workflow can be extended with additional steps (tests, security scanning, etc.)

## Example Complete Workflow

Here's a complete example for the `kosilo-ms` repository:

**File**: `prpo-skupina4/kosilo-ms/.github/workflows/dockerhub.yml`

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main
      - dev
  workflow_dispatch:

env:
  IMAGE_NAME: adrian4096/kosilo-ms

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.IMAGE_NAME }}
          tags: |
            type=raw,value=latest,enable={{is_default_branch}}
            type=sha,prefix=,format=short
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Hub](https://hub.docker.com/)
