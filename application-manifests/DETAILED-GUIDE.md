# 📖 Detailed Guide

Only read this if you want to understand what's happening under the hood.

## 🎯 What You're Deploying

| App | What It Does | Pods | Memory |
|-----|-------------|------|--------|
| **TCA InfraForge** | Your main app (frontend + backend) | 6 | 384Mi |
| **Personal Vault** | Secure storage | 2 | 128Mi |
| **Task Management** | Task tracking | 3 | 128Mi |
| **K8s Deploy Test** | Testing app | 2 | 64Mi |
| **Ecommerce** | Shop platform | 3 | 256Mi |

**Total:** 16 pods, ~960Mi RAM (fits in 3GB!)

---

## 🏗️ What's Inside

```
application-manifests/
├── 01-namespaces/        # Creates 'apps' namespace
├── 02-task-management/   # Task app K8s manifests
├── 03-k8s-deploy-test/   # Test app manifests
├── 04-tca-infraforge/    # Main app (6 files!)
├── 05-personal-vault/    # Vault app manifests
├── 06-ecommerce-app/     # Ecommerce manifests
└── argocd/               # ArgoCD definitions
    ├── application-set.yaml          # Deploy all at once
    └── individual-apps/*.yaml        # Deploy one by one ⭐
```

---

## 🔄 How ArgoCD Works

1. You apply an ArgoCD Application manifest
2. ArgoCD reads it and connects to your Git repo
3. ArgoCD syncs the K8s manifests from Git to your cluster
4. ArgoCD monitors and keeps everything in sync

**Benefits:**
- Git is your source of truth
- Automatic deployments on Git push
- Easy rollbacks
- Visual UI to see everything

---

## 🎮 Interactive Script Options

```bash
./setup.sh
```

| Option | What It Does | When to Use |
|--------|-------------|-------------|
| **1** | Update Git URLs | First time setup |
| **2** | Verify structure | Check files are correct |
| **3** | Test manifests | Validate YAML syntax |
| **4** | Deploy all at once | Only if you have 6GB+ RAM |
| **5** ⭐ | Deploy one by one | **RECOMMENDED** - Start here |
| **6** | Check status | See what's running |
| **7** | Scale apps | Adjust replica counts |
| **8** | Update /etc/hosts | Access via .local domains |
| **9** | View URLs | See all app URLs |
| **10** | Open ArgoCD UI | Visual interface |
| **11** | Open Grafana | Monitoring dashboards |
| **12** | View docs | Read documentation |

---

## 📝 Manual Deployment Steps

If you prefer doing it manually without the script:

### 1. Update Git URLs
```bash
find argocd -name '*.yaml' -exec sed -i '' 's|YOUR-USERNAME/YOUR-REPO|temitayocharles/TCA-InfraForge-k8s-Lab|g' {} +
```

### 2. Create Namespace
```bash
kubectl apply -f 01-namespaces/namespace.yaml
```

### 3. Deploy Each App
```bash
# TCA InfraForge
kubectl apply -f argocd/individual-apps/tca-infraforge.yaml
kubectl get application tca-infraforge -n argocd -w

# Personal Vault
kubectl apply -f argocd/individual-apps/personal-vault.yaml
kubectl get application personal-vault -n argocd -w

# Repeat for other apps...
```

### 4. Configure Access
```bash
echo "127.0.0.1  tca-infraforge.local vault.local task-management.local k8s-test.local ecommerce.local" | sudo tee -a /etc/hosts
```

### 5. Access Apps
Open in browser:
- http://tca-infraforge.local
- http://vault.local
- etc.

---

## 🔧 Customization

### Change Replica Counts

Edit the deployment files:
```yaml
spec:
  replicas: 3  # Change this number
```

### Change Resources

```yaml
resources:
  requests:
    memory: "128Mi"  # Minimum
    cpu: "100m"
  limits:
    memory: "256Mi"  # Maximum
    cpu: "200m"
```

### Use Different Images

```yaml
image: temitayocharles/app-name:v2.0  # Change tag or image
```

---

## 🎓 Understanding the Files

### Deployment
- Defines: What container to run, how many replicas, resources
- Example: `02-task-management/deployment.yaml`

### Service
- Defines: How to access the pods internally
- Type: ClusterIP (internal only)
- Example: `02-task-management/service.yaml`

### Ingress
- Defines: External HTTP access rules
- Maps: domain → service
- Example: `02-task-management/ingress.yaml`

### ArgoCD Application
- Defines: What Git repo to sync from
- Config: Auto-sync, self-heal, prune
- Example: `argocd/individual-apps/task-management.yaml`

---

## 💾 Backup Your Work

```bash
# Backup manifests
tar -czf manifests-backup.tar.gz application-manifests/

# Backup cluster state
kubectl get all -n apps -o yaml > apps-backup.yaml
```

---

## 🚀 Advanced: CI/CD Integration

1. **Build Docker image** on code push
2. **Update manifest** with new image tag
3. **Commit to Git**
4. **ArgoCD auto-syncs** new version
5. **Rolling update** happens automatically

---

## 🔍 Monitoring

### Check Everything
```bash
kubectl get all -n apps
```

### Check Resources
```bash
kubectl top nodes
kubectl top pods -n apps
```

### Watch Deployments
```bash
kubectl get pods -n apps -w
```

### View Logs
```bash
kubectl logs -n apps -l app=tca-infraforge --tail=100 -f
```

---

## 🔐 Security Features

- ✅ Non-root containers
- ✅ No privilege escalation  
- ✅ Capabilities dropped
- ✅ Resource limits enforced
- ✅ Network policies ready
- ✅ Secrets management ready

---

## 📊 Resource Profiles

### Development (8 pods, ~512Mi)
```bash
./setup.sh → Option 7 → Development
```

### Production-Lite (10 pods, ~1.3GB)
```bash
./setup.sh → Option 7 → Production-Lite
```

### Production (16 pods, ~2.7GB)
```bash
# Default configuration
```

---

## 🎯 Deployment Strategies

### Strategy 1: Minimal (3GB RAM)
Deploy only critical apps:
1. TCA InfraForge
2. Personal Vault

**Result:** 8 pods, ~512Mi ✅

### Strategy 2: Balanced (3GB RAM)
Add secondary apps:
1. TCA InfraForge
2. Personal Vault
3. Task Management
4. K8s Deploy Test

**Result:** 13 pods, ~704Mi ✅

### Strategy 3: Full (6GB RAM)
Deploy everything:
1. All 6 applications

**Result:** 16 pods, ~960Mi (needs more RAM)

---

## 🔄 Updating Applications

### Update via Git (GitOps way)
```bash
# Edit manifest
vim application-manifests/02-task-management/deployment.yaml

# Commit and push
git add .
git commit -m "Update task-management"
git push

# ArgoCD auto-syncs in ~3 minutes
```

### Manual Update
```bash
kubectl set image deployment/task-management \
  task-management=temitayocharles/task-management-app:v2 \
  -n apps
```

---

## 🗑️ Cleanup

### Delete One App
```bash
kubectl delete application <app-name> -n argocd
```

### Delete Everything
```bash
kubectl delete namespace apps
kubectl delete applications -n argocd --all
```

---

**Questions?** Check `TROUBLESHOOTING.md` or `QUICKSTART.md`
