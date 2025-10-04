# Application Manifests

Production-ready Kubernetes manifests for 6 applications managed by ArgoCD.

## 📦 Applications

| Application | Image | Port | Replicas | Status |
|------------|-------|------|----------|--------|
| **Task Management** | temitayocharles/task-management-app:latest | 3000 | 3 | ✅ Production-ready |
| **K8s Deploy Test** | temitayocharles/k8s-deploy-test:latest | 8080 | 2 | ✅ Production-ready |
| **TCA InfraForge Backend** | temitayocharles/tca-infraforge-backend:latest | 3000 | 3 | ✅ Production-ready |
| **TCA InfraForge Frontend** | temitayocharles/tca-infraforge-frontend:latest | 80 | 3 | ✅ Production-ready |
| **Personal Vault** | temitayocharles/personal-vault:latest | 3000 | 2 | ✅ Production-ready |
| **Ecommerce App** | temitayocharles/ecommerce-app:latest | 3000 | 3 | ✅ Production-ready |

**Total Resources:** 16 pods, ~750m CPU, ~1088Mi memory

## 🏗️ Directory Structure

```
application-manifests/
├── 01-namespaces/                    # Namespace definitions
│   └── namespace.yaml
│
├── 02-task-management/               # Task management application
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
│
├── 03-k8s-deploy-test/              # Kubernetes deployment test app
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
│
├── 04-tca-infraforge/               # TCA InfraForge (frontend + backend)
│   ├── backend-deployment.yaml
│   ├── backend-service.yaml
│   ├── backend-ingress.yaml
│   ├── frontend-deployment.yaml
│   ├── frontend-service.yaml
│   └── frontend-ingress.yaml
│
├── 05-personal-vault/               # Personal vault application
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── secrets.yaml
│
├── 06-ecommerce-app/                # Ecommerce application
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
│
└── argocd/                          # ArgoCD application definitions
    ├── application-set.yaml         # Deploy all apps at once
    └── individual-apps/             # Individual app definitions
        ├── namespaces.yaml
        ├── task-management.yaml
        ├── k8s-deploy-test.yaml
        ├── tca-infraforge.yaml
        ├── personal-vault.yaml
        └── ecommerce-app.yaml
```

## 🚀 Quick Start

### Option 1: Deploy Individual Applications One by One (RECOMMENDED)

Deploy each application individually with ArgoCD for better control and resource management:

```bash
# 1. Create namespace first
kubectl apply -f 01-namespaces/namespace.yaml

# 2. Deploy applications one by one
# Deploy and watch each application before moving to the next

# Application 1: Task Management
kubectl apply -f argocd/individual-apps/task-management.yaml
kubectl get application task-management -n argocd -w  # Watch until Synced & Healthy

# Application 2: K8s Deploy Test
kubectl apply -f argocd/individual-apps/k8s-deploy-test.yaml
kubectl get application k8s-deploy-test -n argocd -w

# Application 3: TCA InfraForge (Backend + Frontend)
kubectl apply -f argocd/individual-apps/tca-infraforge.yaml
kubectl get application tca-infraforge -n argocd -w

# Application 4: Personal Vault
kubectl apply -f argocd/individual-apps/personal-vault.yaml
kubectl get application personal-vault -n argocd -w

# Application 5: Ecommerce App
kubectl apply -f argocd/individual-apps/ecommerce-app.yaml
kubectl get application ecommerce-app -n argocd -w

# 3. Verify all applications
kubectl get applications -n argocd
kubectl get pods -n apps
```

**Benefits of Individual Deployment:**
- ✅ Monitor each application deployment separately
- ✅ Identify issues immediately per application
- ✅ Better resource allocation control
- ✅ Deploy only what you need (especially for 3GB systems)
- ✅ Easier troubleshooting

### Option 2: Deploy All Applications at Once (Requires 6GB+ RAM)

```bash
# 1. Create namespace first
kubectl apply -f 01-namespaces/namespace.yaml

# 2. Deploy using ArgoCD ApplicationSet (all 6 apps together)
kubectl apply -f argocd/application-set.yaml

# 3. Watch the deployment
kubectl get applications -n argocd -w
```

⚠️ **Note:** This deploys all 16 pods at once. Only use if you have 6GB+ RAM allocated to Kubernetes.

### Option 3: Manual kubectl Deployment (Without ArgoCD)

```bash
# Deploy everything manually (no GitOps)
kubectl apply -f 01-namespaces/
kubectl apply -f 02-task-management/
kubectl apply -f 03-k8s-deploy-test/
kubectl apply -f 04-tca-infraforge/
kubectl apply -f 05-personal-vault/
kubectl apply -f 06-ecommerce-app/
```

## 🔧 Configuration

### Update Git Repository

**IMPORTANT:** Edit all ArgoCD application files and replace the placeholder repository URL:

```yaml
# Change this in all ArgoCD YAML files:
repoURL: https://github.com/YOUR-USERNAME/YOUR-REPO.git

# To your actual repository:
repoURL: https://github.com/yourusername/your-repo.git
```

Files to update:
- `argocd/application-set.yaml`
- All files in `argocd/individual-apps/`

### Local Access via Ingress

Add these entries to your `/etc/hosts` file:

```bash
# Add these lines
127.0.0.1  task-management.local
127.0.0.1  k8s-test.local
127.0.0.1  tca-infraforge.local
127.0.0.1  vault.local
127.0.0.1  ecommerce.local
```

Or use this one-liner:

```bash
echo "127.0.0.1  task-management.local k8s-test.local tca-infraforge.local vault.local ecommerce.local" | sudo tee -a /etc/hosts
```

### Access URLs

Once deployed and `/etc/hosts` is configured:

- **Task Management:** http://task-management.local
- **K8s Deploy Test:** http://k8s-test.local
- **TCA InfraForge:** http://tca-infraforge.local (frontend + /api for backend)
- **Personal Vault:** http://vault.local
- **Ecommerce App:** http://ecommerce.local

## 📊 Production Features

### ✅ Security
- Non-root containers
- Read-only root filesystem where possible
- Dropped all capabilities
- No privilege escalation
- Security contexts applied

### ✅ Reliability
- Liveness probes (detect dead containers)
- Readiness probes (control traffic flow)
- Multiple replicas for high availability
- Resource requests and limits

### ✅ Observability
- Prometheus scraping annotations
- Proper labels and metadata
- Health check endpoints

### ✅ GitOps Ready
- ArgoCD ApplicationSet for bulk deployment
- Individual Application manifests available
- Auto-sync and self-healing enabled
- Sync waves for deployment ordering

## 🔍 Monitoring

### Check Application Status

```bash
# Check all pods
kubectl get pods -n apps

# Check services
kubectl get services -n apps

# Check ingresses
kubectl get ingress -n apps

# Check ArgoCD applications
kubectl get applications -n argocd

# Watch ArgoCD sync status
watch kubectl get applications -n argocd
```

### View Logs

```bash
# Task management
kubectl logs -n apps -l app=task-management --tail=50 -f

# K8s deploy test
kubectl logs -n apps -l app=k8s-deploy-test --tail=50 -f

# TCA InfraForge backend
kubectl logs -n apps -l app=tca-infraforge,component=backend --tail=50 -f

# TCA InfraForge frontend
kubectl logs -n apps -l app=tca-infraforge,component=frontend --tail=50 -f

# Personal vault
kubectl logs -n apps -l app=personal-vault --tail=50 -f

# Ecommerce app
kubectl logs -n apps -l app=ecommerce-app --tail=50 -f
```

### Access via Port-Forward (Alternative to Ingress)

```bash
# Task management
kubectl port-forward -n apps svc/task-management 3000:3000

# K8s deploy test
kubectl port-forward -n apps svc/k8s-deploy-test 8080:8080

# TCA InfraForge frontend
kubectl port-forward -n apps svc/tca-infraforge-frontend 8081:80

# TCA InfraForge backend
kubectl port-forward -n apps svc/tca-infraforge-backend 3001:3000

# Personal vault
kubectl port-forward -n apps svc/personal-vault 3002:3000

# Ecommerce app
kubectl port-forward -n apps svc/ecommerce-app 3003:3000
```

## 🛠️ Customization

### Adjust Resource Limits

Edit the `deployment.yaml` files and modify:

```yaml
resources:
  requests:
    memory: "128Mi"   # Minimum guaranteed
    cpu: "100m"       # Minimum guaranteed
  limits:
    memory: "256Mi"   # Maximum allowed
    cpu: "200m"       # Maximum allowed
```

### Change Replica Count

```yaml
spec:
  replicas: 3  # Change this number
```

### Adjust Health Checks

```yaml
livenessProbe:
  initialDelaySeconds: 30  # Wait before first check
  periodSeconds: 10        # Check every N seconds
  timeoutSeconds: 5        # Timeout for check
  failureThreshold: 3      # Restart after N failures
```

## 🔐 Secrets Management

The `personal-vault` application includes a secrets template. **DO NOT commit actual secrets to Git!**

### Using Kubernetes Secrets (Basic)

```bash
# Create secret manually
kubectl create secret generic personal-vault-secrets \
  --from-literal=VAULT_TOKEN=your-token \
  --from-literal=ENCRYPTION_KEY=your-key \
  -n apps
```

### Using Sealed Secrets (Recommended)

Install Sealed Secrets controller:

```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml
```

Seal your secrets:

```bash
# Install kubeseal
brew install kubeseal

# Seal the secret
kubeseal --format yaml < secrets.yaml > sealed-secrets.yaml

# Commit sealed-secrets.yaml to Git (it's encrypted)
```

## 📈 Resource Usage

| Resource | Request | Limit | Count | Total Request | Total Limit |
|----------|---------|-------|-------|---------------|-------------|
| Task Management | 100m / 128Mi | 200m / 256Mi | 3 | 300m / 384Mi | 600m / 768Mi |
| K8s Deploy Test | 50m / 64Mi | 100m / 128Mi | 2 | 100m / 128Mi | 200m / 256Mi |
| TCA Backend | 200m / 256Mi | 400m / 512Mi | 3 | 600m / 768Mi | 1200m / 1536Mi |
| TCA Frontend | 100m / 128Mi | 200m / 256Mi | 3 | 300m / 384Mi | 600m / 768Mi |
| Personal Vault | 100m / 128Mi | 200m / 256Mi | 2 | 200m / 256Mi | 400m / 512Mi |
| Ecommerce | 200m / 256Mi | 400m / 512Mi | 3 | 600m / 768Mi | 1200m / 1536Mi |
| **TOTAL** | | | **16** | **2100m / 2688Mi** | **4200m / 5376Mi** |

**Summary:**
- **Minimum required:** 2.1 CPU cores, 2.7GB memory
- **Maximum burst:** 4.2 CPU cores, 5.4GB memory
- **Your system:** 8 CPU cores, 3GB allocated

⚠️ **Note:** This exceeds your 3GB Kubernetes allocation. Consider:
1. Reducing replica counts (3→2, 2→1)
2. Lowering resource requests/limits
3. Deploying only critical applications
4. Increasing OrbStack memory allocation to 6GB

## 🐛 Troubleshooting

### Pods not starting?

```bash
# Check pod status
kubectl get pods -n apps

# Describe pod for events
kubectl describe pod <pod-name> -n apps

# Check logs
kubectl logs <pod-name> -n apps
```

### ImagePullBackOff error?

```bash
# Check if image exists
docker pull temitayocharles/task-management-app:latest

# Check image pull policy
# Change imagePullPolicy: Always → IfNotPresent
```

### Ingress not working?

```bash
# Check ingress controller is running
kubectl get pods -n ingress-nginx

# Check ingress resources
kubectl get ingress -n apps

# Check /etc/hosts is configured
cat /etc/hosts | grep local
```

### Out of memory?

```bash
# Check resource usage
kubectl top nodes
kubectl top pods -n apps

# Reduce replicas
kubectl scale deployment task-management -n apps --replicas=2
```

## 🚦 Next Steps

1. ✅ **Update Git URLs** in ArgoCD application files
2. ✅ **Adjust resources** to fit your 3GB allocation
3. ✅ **Configure secrets** for personal-vault
4. ✅ **Add /etc/hosts entries** for local access
5. ✅ **Deploy applications** using ArgoCD
6. ✅ **Monitor in Grafana** (dashboard #315)
7. ✅ **Set up CI/CD** to auto-update images

## 📚 Additional Documentation

- [Deployment Guide](./DEPLOYMENT-GUIDE.md) - Step-by-step deployment
- [ArgoCD Setup](./ARGOCD-SETUP.md) - ArgoCD integration
- [Values Configuration](./values.yaml) - Customization values

## 🤝 Support

- Check logs: `kubectl logs -n apps -l app=<app-name>`
- Check events: `kubectl get events -n apps --sort-by='.lastTimestamp'`
- Check ArgoCD UI: `kubectl port-forward -n argocd svc/argocd-server 8080:80`

---

**Created for:** OrbStack Kubernetes (3GB memory, 8 CPU cores)  
**GitOps Ready:** ArgoCD ApplicationSet + Individual Apps  
**Production Features:** Security, reliability, observability  
**Status:** ✅ Ready to deploy
