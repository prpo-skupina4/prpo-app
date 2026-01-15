#!/usr/bin/env bash

set -e

# Configuration
NAMESPACE="${NAMESPACE:-prpo}"
TAG="${TAG:-latest}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="${SCRIPT_DIR}/manifests"

echo "==> Deploying to AKS cluster"
echo "    Namespace: ${NAMESPACE}"
echo "    Image Tag: ${TAG}"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "Error: kubectl is not configured or cannot connect to cluster"
    exit 1
fi

echo "==> Creating namespace (if not exists)"
kubectl apply -f "${MANIFESTS_DIR}/namespace.yaml"

echo ""
echo "==> Applying manifests with TAG=${TAG}"

# Process and apply each manifest file (except namespace and ingress)
for manifest in "${MANIFESTS_DIR}"/*.yaml; do
    filename=$(basename "$manifest")
    
    # Skip namespace.yaml (already applied) and ingress.yaml (apply last)
    if [[ "$filename" == "namespace.yaml" ]] || [[ "$filename" == "ingress.yaml" ]]; then
        continue
    fi
    
    echo "    Processing: $filename"
    # Substitute ${TAG} placeholder and apply
    sed "s/\${TAG}/${TAG}/g" "$manifest" | kubectl apply -f -
done

echo ""
echo "==> Applying ingress manifest"
kubectl apply -f "${MANIFESTS_DIR}/ingress.yaml"

echo ""
echo "==> Waiting for deployments to roll out"

# List of deployments to wait for
DEPLOYMENTS=(
    "user-managment-ms"
    "kosilo-ms"
    "boolean-ms"
    "optimizator-ms"
    "event-view-ms"
    "ical-ms"
)

for deployment in "${DEPLOYMENTS[@]}"; do
    echo "    Waiting for deployment/${deployment}"
    kubectl rollout status deployment/"${deployment}" -n "${NAMESPACE}" --timeout=5m
done

echo ""
echo "==> Deployment complete!"
echo ""
echo "==> Current pod status:"
kubectl get pods -n "${NAMESPACE}"

echo ""
echo "==> Ingress information:"
kubectl get ingress -n "${NAMESPACE}"
