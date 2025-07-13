# Phase 2: Kubernetes Manifests - CLO835 Final Project

## Overview
This directory contains all the Kubernetes manifests required to deploy the enhanced Flask + MySQL application to Amazon EKS.

## File Structure

```
k8s/
├── namespace.yaml              # Application namespace
├── configmap.yaml              # Application configuration
├── secret.yaml                 # Database credentials
├── pvc.yaml                    # MySQL persistent storage
├── mysql-init-configmap.yaml   # MySQL initialization script
├── mysql-deployment.yaml       # MySQL deployment
├── mysql-service.yaml          # MySQL service
├── app-deployment.yaml         # Flask application deployment
├── app-service.yaml            # Flask application service
├── ingress.yaml                # External access configuration
├── hpa.yaml                    # Horizontal Pod Autoscaler
├── deploy.sh                   # Deployment script
├── cleanup.sh                  # Cleanup script
└── README.md                   # This file
```

## Components

### 1. Namespace
- **File**: `namespace.yaml`
- **Purpose**: Isolates all application resources
- **Name**: `clo835-app`

### 2. Configuration Management
- **ConfigMap**: `configmap.yaml`
  - Application settings (colors, student name, etc.)
  - Database configuration
  - S3 settings
- **Secret**: `secret.yaml`
  - Database credentials
  - AWS credentials (if needed)

### 3. Database Layer
- **PVC**: `pvc.yaml`
  - 1GB persistent storage for MySQL
  - Uses AWS EBS (gp2 storage class)
- **MySQL Deployment**: `mysql-deployment.yaml`
  - MySQL 8.0 with persistent storage
  - Resource limits and health checks
- **MySQL Service**: `mysql-service.yaml`
  - Internal service for database access

### 4. Application Layer
- **Flask Deployment**: `app-deployment.yaml`
  - 2 replicas for high availability
  - Health checks and resource limits
  - Environment variables from ConfigMaps/Secrets
- **Flask Service**: `app-service.yaml`
  - Internal service for application access

### 5. Networking
- **Ingress**: `ingress.yaml`
  - AWS ALB Ingress Controller
  - External access configuration
  - Health checks and routing

### 6. Auto-scaling (Bonus)
- **HPA**: `hpa.yaml`
  - CPU and memory-based scaling
  - 2-10 replicas range
  - 70% CPU, 80% memory thresholds

## Prerequisites

### 1. EKS Cluster
```bash
# Create EKS cluster
eksctl create cluster \
  --name clo835-cluster \
  --region us-west-2 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4
```

### 2. AWS Load Balancer Controller
```bash
# Install AWS Load Balancer Controller
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=clo835-cluster
```

### 3. Metrics Server (for HPA)
```bash
# Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Deployment

### Quick Deployment
```bash
# Make scripts executable
chmod +x deploy.sh cleanup.sh

# Deploy everything
./deploy.sh
```

### Manual Deployment
```bash
# Create namespace
kubectl apply -f namespace.yaml

# Apply ConfigMaps
kubectl apply -f configmap.yaml
kubectl apply -f mysql-init-configmap.yaml

# Apply Secrets
kubectl apply -f secret.yaml

# Deploy database
kubectl apply -f pvc.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml

# Deploy application
kubectl apply -f app-deployment.yaml
kubectl apply -f app-service.yaml

# Deploy networking
kubectl apply -f ingress.yaml
kubectl apply -f hpa.yaml
```

## Configuration

### Environment Variables
Update `configmap.yaml` and `secret.yaml` with your values:

```yaml
# In configmap.yaml
data:
  STUDENT_NAME: "Your Name"
  APP_COLOR: "blue"
  BACKGROUND_IMAGE_URL: "https://your-image-url.com/image.jpg"

# In secret.yaml
data:
  DBPWD: <base64-encoded-password>
  DBUSER: <base64-encoded-username>
```

### ECR Registry
Update `app-deployment.yaml` with your ECR registry:

```yaml
image: ${ECR_REGISTRY}/clo835-app:latest
# Replace with: 123456789012.dkr.ecr.us-west-2.amazonaws.com/clo835-app:latest
```

## Monitoring and Management

### Check Deployment Status
```bash
kubectl get all -n clo835-app
kubectl get pods -n clo835-app
kubectl get services -n clo835-app
kubectl get ingress -n clo835-app
```

### View Logs
```bash
# Application logs
kubectl logs -f deployment/flask-app-deployment -n clo835-app

# Database logs
kubectl logs -f deployment/mysql-deployment -n clo835-app
```

### Scale Application
```bash
# Manual scaling
kubectl scale deployment flask-app-deployment --replicas=5 -n clo835-app

# Check HPA status
kubectl get hpa -n clo835-app
```

## Cleanup

### Complete Cleanup
```bash
./cleanup.sh
```

### Manual Cleanup
```bash
kubectl delete namespace clo835-app
```

## Security Considerations

1. **Secrets Management**: Use AWS Secrets Manager or external secret operators for production
2. **Network Policies**: Implement network policies to restrict pod-to-pod communication
3. **RBAC**: Set up proper role-based access control
4. **Image Security**: Use image scanning and signed images
5. **Pod Security**: Implement pod security standards

## Troubleshooting

### Common Issues

1. **PVC Not Bound**
   ```bash
   kubectl describe pvc mysql-pvc -n clo835-app
   ```

2. **Pods Not Starting**
   ```bash
   kubectl describe pod <pod-name> -n clo835-app
   kubectl logs <pod-name> -n clo835-app
   ```

3. **Ingress Not Working**
   ```bash
   kubectl describe ingress flask-app-ingress -n clo835-app
   ```

4. **HPA Not Scaling**
   ```bash
   kubectl describe hpa flask-app-hpa -n clo835-app
   kubectl top pods -n clo835-app
   ```

## Next Steps

After successful deployment, proceed to:
1. **Phase 3**: Set up CI/CD pipeline with GitHub Actions
2. **Phase 4**: Configure monitoring and logging
3. **Phase 5**: Implement Flux for GitOps (bonus) 