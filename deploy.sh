#!/bin/bash

# CLO835 Final Project - Kubernetes Deployment Script
# This script deploys the entire application to Kubernetes

set -e

echo "🚀 Starting CLO835 Application Deployment..."

# Create namespace
echo "📦 Creating namespace..."
kubectl apply -f namespace.yaml

# Apply ConfigMaps
echo "⚙️  Applying ConfigMaps..."
kubectl apply -f configmap.yaml
kubectl apply -f mysql-init-configmap.yaml

# Apply Secrets
echo "🔐 Applying Secrets..."
kubectl apply -f secret.yaml

# Apply Persistent Volume Claim
echo "💾 Creating Persistent Volume Claim..."
kubectl apply -f pvc.yaml

# Wait for PVC to be bound
echo "⏳ Waiting for PVC to be bound..."
kubectl wait --for=condition=Bound pvc/mysql-pvc -n clo835-app --timeout=60s

# Deploy MySQL
echo "🗄️  Deploying MySQL..."
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
kubectl wait --for=condition=available deployment/mysql-deployment -n clo835-app --timeout=300s

# Deploy Flask Application
echo "🐍 Deploying Flask Application..."
kubectl apply -f app-deployment.yaml
kubectl apply -f app-service.yaml

# Wait for Flask app to be ready
echo "⏳ Waiting for Flask app to be ready..."
kubectl wait --for=condition=available deployment/flask-app-deployment -n clo835-app --timeout=300s

# Apply Ingress
echo "🌐 Applying Ingress..."
kubectl apply -f ingress.yaml

# Apply HPA (optional)
echo "📈 Applying Horizontal Pod Autoscaler..."
kubectl apply -f hpa.yaml

echo "✅ Deployment completed successfully!"
echo ""
echo "📊 Deployment Status:"
kubectl get all -n clo835-app
echo ""
echo "🌐 To access the application:"
echo "   kubectl get ingress -n clo835-app"
echo ""
echo "📝 To view logs:"
echo "   kubectl logs -f deployment/flask-app-deployment -n clo835-app"
echo ""
echo "🔧 To scale the application:"
echo "   kubectl scale deployment flask-app-deployment --replicas=3 -n clo835-app" 