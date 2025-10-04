# 🎯 Individual Deployment Strategy - UPDATED

## ✅ Deployment Approach Changed

The application manifests now **prioritize individual deployment** where each application is deployed **one by one** rather than all at once.

## 🚀 Recommended Deployment Method

### Deploy Applications Individually (One by One)

This is now the **PRIMARY and RECOMMENDED** deployment method:

```bash
cd /Volumes/512-B/Documents/PERSONAL/TCA-InfraForge-k8s-Lab/application-manifests

# Step 1: Update Git URLs (required)
./setup.sh
# Select option 1

# Step 2: Create namespace
kubectl apply -f 01-namespaces/namespace.yaml

# Step 3: Deploy applications ONE BY ONE
# Use the interactive script:
./setup.sh
# Select option 5 (Deploy Individual Application)
# Then select each app: 1, 2, 3, 4, 5 in order

# Or deploy manually one by one:
kubectl apply -f argocd/individual-apps/task-management.yaml
kubectl get application task-management -n argocd -w  # Wait until Synced

kubectl apply -f argocd/individual-apps/k8s-deploy-test.yaml
kubectl get application k8s-deploy-test -n argocd -w

kubectl apply -f argocd/individual-apps/tca-infraforge.yaml
kubectl get application tca-infraforge -n argocd -w

kubectl apply -f argocd/individual-apps/personal-vault.yaml
kubectl get application personal-vault -n argocd -w

kubectl apply -f argocd/individual-apps/ecommerce-app.yaml
kubectl get application ecommerce-app -n argocd -w
```

## ✨ Benefits of Individual Deployment

### 1. **Better Resource Management** (Critical for 3GB systems)
- Deploy only what you need
- Monitor resource usage per application
- Avoid overwhelming your cluster

### 2. **Easier Troubleshooting**
- Identify issues immediately per application
- Clear visibility into which app has problems
- Fix issues before deploying more apps

### 3. **Controlled Rollout**
- Watch each application sync and become healthy
- Ensure one app is working before moving to next
- Progressive deployment reduces risk

### 4. **Flexibility**
- Deploy critical apps first (e.g., TCA InfraForge + Personal Vault)
- Skip non-essential apps if resources are limited
- Scale resources between deployments if needed

### 5. **Learning Opportunity**
- Understand each application's behavior
- See ArgoCD sync process in action per app
- Better grasp of GitOps workflow

## 📋 Deployment Order (Recommended)

For optimal resource allocation on a 3GB system:

### Priority 1: Core Applications (Deploy First)
```bash
# 1. TCA InfraForge (your main application)
kubectl apply -f argocd/individual-apps/tca-infraforge.yaml
# Resources: 6 pods, 300m CPU, 384Mi RAM

# 2. Personal Vault
kubectl apply -f argocd/individual-apps/personal-vault.yaml
# Resources: 2 pods, 100m CPU, 128Mi RAM

# Total so far: 8 pods, 400m CPU, 512Mi RAM ✅ Fits in 3GB!
```

### Priority 2: Secondary Applications (Deploy If Resources Allow)
```bash
# 3. Task Management
kubectl apply -f argocd/individual-apps/task-management.yaml
# Additional: 3 pods, 100m CPU, 128Mi RAM

# 4. K8s Deploy Test
kubectl apply -f argocd/individual-apps/k8s-deploy-test.yaml
# Additional: 2 pods, 50m CPU, 64Mi RAM
```

### Priority 3: Optional Applications
```bash
# 5. Ecommerce App (if you need it)
kubectl apply -f argocd/individual-apps/ecommerce-app.yaml
# Additional: 3 pods, 200m CPU, 256Mi RAM
```

## 📊 Resource Planning by Deployment

| Deployment Stage | Apps | Pods | CPU | RAM | Fits 3GB? |
|-----------------|------|------|-----|-----|-----------|
| **Stage 1** | TCA InfraForge + Personal Vault | 8 | 400m | 512Mi | ✅ Yes |
| **Stage 2** | + Task Management + K8s Test | 13 | 550m | 704Mi | ✅ Yes |
| **Stage 3** | + Ecommerce | 16 | 750m | 960Mi | ✅ Yes |
| **All at Once** | All 6 apps together | 16 | 750m | 960Mi | ⚠️ Risky |

## 🔧 Using the Interactive Script

The `setup.sh` script has been updated to make individual deployment the recommended option:

```bash
./setup.sh
```

**Menu highlights:**
- **Option 5** ⭐ **RECOMMENDED**: Deploy Individual Application
  - Shows resource requirements for each app
  - Offers to watch deployment status
  - Can deploy all remaining apps one by one
  
- **Option 4**: Deploy All at Once (requires 6GB+ RAM)
  - Shows warning before deploying
  - Not recommended for 3GB systems

## 📚 Updated Documentation

All documentation files have been updated to reflect individual deployment:

1. **START-HERE.md** - Quick start now shows one-by-one deployment
2. **README.md** - Individual deployment is Option 1 (primary)
3. **DEPLOYMENT-GUIDE.md** - Detailed step-by-step for each app
4. **setup.sh** - Interactive script prioritizes individual deployment

## 🎯 Quick Reference Commands

### Deploy Next Application
```bash
# Replace with actual app name: task-management, k8s-deploy-test, tca-infraforge, personal-vault, ecommerce-app
kubectl apply -f argocd/individual-apps/<app-name>.yaml
kubectl get application <app-name> -n argocd -w
```

### Check What's Deployed
```bash
kubectl get applications -n argocd
kubectl get pods -n apps
```

### Monitor Resources
```bash
kubectl top nodes
kubectl top pods -n apps
```

### Deploy Next If Resources Allow
```bash
# Check resources first
kubectl top nodes

# If you have headroom, deploy next app
kubectl apply -f argocd/individual-apps/<next-app>.yaml
```

## 💡 Pro Tips

1. **Always wait** for an application to be "Synced" and "Healthy" before deploying the next
2. **Monitor resources** between deployments: `kubectl top nodes`
3. **Start with critical apps** (TCA InfraForge, Personal Vault)
4. **Use the watch flag** (`-w`) to see real-time sync status
5. **Check logs** if an app doesn't sync: `kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server`

## 🚫 What NOT to Do

❌ **Don't deploy all apps at once** on a 3GB system using ApplicationSet  
❌ **Don't skip namespace creation** - always deploy 01-namespaces first  
❌ **Don't deploy next app** while previous is still syncing  
❌ **Don't ignore warnings** in the interactive script  

## ✅ What Changed

### Before (Bulk Deployment)
- Primary method: Deploy all 6 apps at once via ApplicationSet
- Risk: Overwhelm 3GB systems with 16 pods simultaneously
- Hard to troubleshoot when multiple apps fail

### After (Individual Deployment) ⭐
- Primary method: Deploy each app one by one
- Benefit: Control resource usage, easier troubleshooting
- Flexible: Deploy only what you need

## 🎉 Result

You now have a **production-ready, flexible deployment strategy** that:
- ✅ Works perfectly with 3GB systems
- ✅ Provides full control over what gets deployed
- ✅ Makes troubleshooting trivial
- ✅ Scales up or down based on your needs
- ✅ Follows GitOps best practices

---

**Start deploying:** `cd application-manifests && ./setup.sh` → Select Option 5 ⭐

**Questions?** Read the updated documentation:
- `START-HERE.md` - Quick start guide
- `README.md` - Complete overview
- `DEPLOYMENT-GUIDE.md` - Detailed instructions
