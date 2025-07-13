#!/bin/bash

# CLO835 Final Project - Kubernetes Cleanup Script
# This script removes all resources created for the application

set -e

echo "🧹 Starting cleanup of CLO835 Application..."

# Delete all resources in the namespace
echo "🗑️  Deleting all resources in clo835-app namespace..."
kubectl delete all --all -n clo835-app

# Delete PVC
echo "💾 Deleting Persistent Volume Claim..."
kubectl delete pvc mysql-pvc -n clo835-app

# Delete ConfigMaps
echo "⚙️  Deleting ConfigMaps..."
kubectl delete configmap app-config -n clo835-app
kubectl delete configmap mysql-init-config -n clo835-app

# Delete Secrets
echo "🔐 Deleting Secrets..."
kubectl delete secret db-secret -n clo835-app

# Delete Ingress
echo "🌐 Deleting Ingress..."
kubectl delete ingress flask-app-ingress -n clo835-app

# Delete HPA
echo "📈 Deleting Horizontal Pod Autoscaler..."
kubectl delete hpa flask-app-hpa -n clo835-app

# Delete namespace
echo "📦 Deleting namespace..."
kubectl delete namespace clo835-app

echo "✅ Cleanup completed successfully!"
echo ""
echo "Note: If you want to preserve data, backup the PVC before running this script." 