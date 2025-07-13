#!/bin/bash

# CLO835 Final Project - Kubernetes Cleanup Script
# This script removes all resources created for the application

set -e

echo "🧹 Starting cleanup of CLO835 Application..."

# Delete all resources in the namespace
echo "🗑️  Deleting all resources in final namespace..."
kubectl delete all --all -n final

# Delete PVC
echo "💾 Deleting Persistent Volume Claim..."
kubectl delete pvc mysql-pvc -n final

# Delete ConfigMaps
echo "⚙️  Deleting ConfigMaps..."
kubectl delete configmap app-config -n final
kubectl delete configmap mysql-init-config -n final

# Delete Secrets
echo "🔐 Deleting Secrets..."
kubectl delete secret db-secret -n final

# Delete ServiceAccount and RBAC
echo "🔐 Deleting ServiceAccount and RBAC..."
kubectl delete -f serviceaccount.yaml

# Delete Ingress
echo "🌐 Deleting Ingress..."
kubectl delete ingress flask-app-ingress -n final

# Delete HPA
echo "📈 Deleting Horizontal Pod Autoscaler..."
kubectl delete hpa flask-app-hpa -n final

# Delete namespace
echo "📦 Deleting namespace..."
kubectl delete namespace final

echo "✅ Cleanup completed successfully!"
echo ""
echo "Note: If you want to preserve data, backup the PVC before running this script." 