# DEVOPS FINAL PROJECT - TEAM 3

## 📖 Overview

A cloud-native name generation application demonstrating modern DevOps practices and container orchestration. This project showcases a complete CI/CD pipeline, infrastructure as code, and comprehensive monitoring using industry-standard tools and practices.

## 🏗️ Architecture

### System Architecture Diagram
![System Architecture Diagram](screenshots/system-architecture-diagram.png)

### Application Flow
1. **Frontend**: HTML/CSS/JavaScript served statically
2. **Backend**: Node.js Express API with REST endpoints
3. **Database**: MongoDB for persistent storage
4. **Load Balancer**: AWS Network Load Balancer for traffic distribution
5. **Monitoring**: Prometheus + Grafana for metrics and visualization

## 🛠️ Technologies Used

### Core Application Stack
- **Runtime**: Node.js 18 LTS
- **Framework**: Express.js
- **Database**: MongoDB 3.6
- **Data Generation**: Faker.js
- **Logging**: Winston

### DevOps & Infrastructure
- **Containerization**: Docker with multi-stage builds
- **Container Registry**: AWS ECR (Elastic Container Registry)
- **Orchestration**: Kubernetes (AWS EKS)
- **Cloud Provider**: Amazon Web Services (AWS)
- **Infrastructure as Code**: eksctl for cluster provisioning
- **Storage**: AWS EBS (Elastic Block Store) with GP3 volumes

### Kubernetes Strategy
- **Deployment Strategy**: Rolling updates for zero-downtime deployments
- **Application Pods**: Deployment with 2 replicas for high availability
- **Database**: StatefulSet for MongoDB with persistent storage
- **Service Mesh**: Kubernetes-native service discovery
- **Storage Class**: Custom EBS-backed storage with encryption
- **Load Balancing**: AWS Network Load Balancer (NLB) with IP mode

### Monitoring & Observability
- **Metrics Collection**: Prometheus
- **Visualization**: Grafana dashboards
- **Application Logging**: Winston with structured logging
- **Health Checks**: Kubernetes liveness and readiness probes

### Security Features
- **Container Security**: Non-root user execution
- **Storage Encryption**: EBS volumes encrypted at rest
- **Network Security**: AWS VPC with proper subnet isolation
- **RBAC**: Kubernetes Role-Based Access Control

## 🚀 How to Run - Step by Step

### Prerequisites
- AWS CLI configured with appropriate permissions
- kubectl installed and configured
- eksctl installed
- Docker installed (for local development)

### Step 1: Create EKS Cluster
```bash
# Create the EKS cluster using the provided configuration
eksctl create cluster -f clusters/team3_cluster.yaml

# Verify cluster creation
kubectl get nodes
```

### Step 2: Configure kubectl Context
```bash
# Update kubeconfig to use the new cluster
aws eks update-kubeconfig --region us-west-2 --name team3-cluster
```

### Step 3: Deploy Storage Class
```bash
# Apply the custom storage class for persistent volumes
kubectl apply -f k8s_manifests/storage_svc.yaml
```

### Step 4: Deploy MongoDB Database
```bash
# Deploy MongoDB StatefulSet and Service
kubectl apply -f k8s_manifests/db_deployment.yaml
kubectl apply -f k8s_manifests/db_srvc.yaml
```

### Step 5: Deploy Application
```bash
# Deploy the application deployment and service
kubectl apply -f k8s_manifests/app_deployment.yaml
kubectl apply -f k8s_manifests/app_srvc.yaml
```

### Step 6: Verify Deployment
```bash
# Check all pods are running
kubectl get pods

# Get service details and external IP
kubectl get services

# Check deployment status
kubectl get deployments
kubectl get statefulsets
```

### Step 7: Access the Application
```bash
# Get the LoadBalancer external IP
kubectl get service namegen-team3-service

# The application will be available at:
# http://<EXTERNAL-IP>/
```

## 📊 Monitoring Setup

### Prometheus + Grafana Integration

#### Deploy Prometheus
```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Install Prometheus
helm install my-prometheus prometheus-community/prometheus --version 27.30.0

```

#### Deploy Grafana
```bash
# Add Grafana Helm repository
helm repo add grafana https://grafana.github.io/helm-charts

# Install Grafana
helm install my-grafana grafana/grafana --version 9.3.2
```



## 📸 Screenshots

### Application Interface
![Application Homepage](screenshots/app-homepage.png)
*Main application interface showing the name generation functionality*

### Kubernetes Dashboard
![Kubernetes Pods](screenshots/k8s-pods.png)
*Kubernetes dashboard showing running pods and their status*

### Grafana Monitoring
![Grafana Dashboard](screenshots/grafana-dashboard.png)
*Grafana dashboard displaying application and infrastructure metrics*

### AWS EKS Cluster
![EKS Cluster](screenshots/eks-cluster.png)
*AWS EKS console showing cluster details and node groups*

## 🔧 Configuration

### Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `MONGODB_URL` | MongoDB connection string | `mongodb://mongo-team3:27017/namegen` |
| `PORT` | Application port | `8080` |
| `NODE_ENV` | Environment mode | `production` |

### Kubernetes Resources
| Resource | Replicas | CPU Request | Memory Request |
|----------|----------|-------------|----------------|
| NameGen App | 2 | 100m | 128Mi |
| MongoDB | 1 | 200m | 256Mi |

## 🚨 Troubleshooting

### Common Issues

#### Pods Not Starting
```bash
# Check pod status and events
kubectl describe pod <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp
```

#### Database Connection Issues
```bash
# Check MongoDB service
kubectl get service mongo-team3
kubectl logs -l app=mongo-team3
```

#### LoadBalancer Not Accessible
```bash
# Check service status
kubectl get service namegen-team3-service
kubectl describe service namegen-team3-service
```

## 🧹 Cleanup & Resource Management

### Deleting the EKS Cluster

When you're done with the project and want to clean up all AWS resources to avoid charges:

#### Option 1: Delete using eksctl (Recommended)
```bash
# Delete the entire cluster and all associated resources
eksctl delete cluster --name team3-cluster --region us-west-2

# This will automatically delete:
# - EKS cluster
# - Node groups
# - VPC and subnets (if created by eksctl)
# - Security groups
# - Load balancers
# - EBS volumes
```

#### Option 2: Delete Kubernetes resources first, then cluster
```bash
# Step 1: Delete all deployed applications
kubectl delete -f k8s_manifests/

# Step 2: Delete any persistent volumes
kubectl delete pv --all

# Step 3: Delete the cluster
eksctl delete cluster --name team3-cluster --region us-west-2
```

#### Option 3: Manual cleanup (if eksctl delete fails)
```bash
# Delete cluster from AWS console or CLI
aws eks delete-cluster --name team3-cluster --region us-west-2

# Clean up node groups
aws eks delete-nodegroup --cluster-name team3-cluster --nodegroup-name <nodegroup-name> --region us-west-2

# Clean up VPC and other resources if they were created specifically for this cluster
```

### Verify Cleanup
```bash
# Check that cluster is deleted
eksctl get cluster --region us-west-2

# Check AWS console for any remaining resources:
# - EC2 instances
# - Load balancers
# - EBS volumes
# - VPC components
```

### Cost Optimization Tips
- Delete the cluster when not in use to avoid ongoing charges
- Monitor AWS billing dashboard for unexpected costs
- Use `kubectl get pv` to check for orphaned persistent volumes
- Review CloudFormation stacks for any remaining eksctl resources

## 📝 Additional Notes

### Important Considerations
- Deleting the cluster will permanently remove all data stored in the MongoDB persistent volumes
- Make sure to backup any important data before deletion
- The deletion process may take 10-15 minutes to complete
- Some AWS resources may have a small delay before being fully cleaned up

*This project demonstrates enterprise-grade DevOps practices including containerization, orchestration, monitoring, and cloud-native deployment strategies.*