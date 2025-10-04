# Deployment Guide

Step-by-step guide to deploy your applications using ArgoCD.

## Prerequisites

✅ **Already Completed:**
- Kubernetes cluster running (OrbStack)
- ArgoCD installed and accessible
- Ingress-Nginx controller running
- Prometheus & Grafana monitoring active

## Deployment Options

### 🚀 Option 1: GitOps with ArgoCD (Recommended)

Best for: Production, automated deployments, Git as source of truth.

#### Step 1: Push Manifests to Git

```bash
cd /Volumes/512-B/Documents/PERSONAL/TCA-InfraForge-k8s-Lab

# Initialize git (if not already)
git init

# Add manifests
git add application-manifests/

# Commit
git commit -m "Add production-ready application manifests"

# Push to your repository
git push origin main
```

#### Step 2: Update Repository URLs

Edit these files and replace `YOUR-USERNAME/YOUR-REPO`:

```bash
# Open each file and update repoURL
vim application-manifests/argocd/application-set.yaml
vim application-manifests/argocd/individual-apps/*.yaml

# Replace this line in all files:
repoURL: https://github.com/YOUR-USERNAME/YOUR-REPO.git

# With your actual repo:
repoURL: https://github.com/temitayocharles/TCA-InfraForge-k8s-Lab.git
```

Or use this one-liner:

```bash
find application-manifests/argocd -name '*.yaml' -exec sed -i '' 's|YOUR-USERNAME/YOUR-REPO|temitayocharles/TCA-InfraForge-k8s-Lab|g' {} +
```

#### Step 3: Create Namespace

```bash
kubectl apply -f application-manifests/01-namespaces/namespace.yaml
```

**Expected output:**
```
namespace/apps created
```

#### Step 4: Deploy Applications Individually (One by One - RECOMMENDED)

Deploy each application separately and monitor it before moving to the next:

```bash
# Application 1: Task Management
kubectl apply -f application-manifests/argocd/individual-apps/task-management.yaml
echo "Waiting for task-management to sync..."
kubectl get application task-management -n argocd -w
# Press Ctrl+C when you see: Synced & Healthy

# Application 2: K8s Deploy Test
kubectl apply -f application-manifests/argocd/individual-apps/k8s-deploy-test.yaml
echo "Waiting for k8s-deploy-test to sync..."
kubectl get application k8s-deploy-test -n argocd -w

# Application 3: TCA InfraForge (Backend + Frontend)
kubectl apply -f application-manifests/argocd/individual-apps/tca-infraforge.yaml
echo "Waiting for tca-infraforge to sync..."
kubectl get application tca-infraforge -n argocd -w

# Application 4: Personal Vault
kubectl apply -f application-manifests/argocd/individual-apps/personal-vault.yaml
echo "Waiting for personal-vault to sync..."
kubectl get application personal-vault -n argocd -w

# Application 5: Ecommerce App
kubectl apply -f application-manifests/argocd/individual-apps/ecommerce-app.yaml
echo "Waiting for ecommerce-app to sync..."
kubectl get application ecommerce-app -n argocd -w
```

**Why deploy individually?**
- ✅ Monitor each application's deployment separately
- ✅ Catch issues early before deploying more apps
- ✅ Better control over resource usage (important for 3GB systems)
- ✅ Deploy only what you need
- ✅ Easier to troubleshoot specific applications

#### Step 5: Verify All Deployments

```bash
# Check all ArgoCD applications
kubectl get applications -n argocd

# Should show:
NAME                      SYNC STATUS   HEALTH STATUS
task-management           Synced        Healthy
k8s-deploy-test          Synced        Healthy
tca-infraforge           Synced        Healthy
personal-vault           Synced        Healthy
ecommerce-app            Synced        Healthy
```

#### Step 6: Check All Pods

```bash
kubectl get pods -n apps
```

**Expected output:**
```
NAME                                       READY   STATUS    RESTARTS   AGE
task-management-xxx                        1/1     Running   0          5m
k8s-deploy-test-xxx                        1/1     Running   0          4m
tca-infraforge-backend-xxx                 1/1     Running   0          3m
tca-infraforge-frontend-xxx                1/1     Running   0          3m
personal-vault-xxx                         1/1     Running   0          2m
ecommerce-app-xxx                          1/1     Running   0          1m
```

---

### 📦 Option 2: Deploy All at Once with ApplicationSet

Best for: Systems with 6GB+ RAM, deploying everything together.

⚠️ **Warning:** This deploys all 16 pods simultaneously. Only use if you have sufficient resources.

```bash
# Deploy all applications at once using ApplicationSet
kubectl apply -f application-manifests/argocd/application-set.yaml

# Watch all applications sync together
kubectl get applications -n argocd -w
```

---

### 🔧 Option 3: Manual kubectl (No ArgoCD)

Best for: Testing, development, no Git required.

```bash
# Deploy in order
kubectl apply -f application-manifests/01-namespaces/
kubectl apply -f application-manifests/02-task-management/
kubectl apply -f application-manifests/03-k8s-deploy-test/
kubectl apply -f application-manifests/04-tca-infraforge/
kubectl apply -f application-manifests/05-personal-vault/
kubectl apply -f application-manifests/06-ecommerce-app/

# Verify
kubectl get pods -n apps
kubectl get svc -n apps
kubectl get ingress -n apps
```

---

## Access Your Applications

### Method 1: Via Ingress (Local hostnames)

**Step 1: Configure /etc/hosts**

```bash
# Add local DNS entries
echo "127.0.0.1  task-management.local k8s-test.local tca-infraforge.local vault.local ecommerce.local" | sudo tee -a /etc/hosts
```

**Step 2: Access applications in browser**

- Task Management: http://task-management.local
- K8s Deploy Test: http://k8s-test.local
- TCA InfraForge: http://tca-infraforge.local
- Personal Vault: http://vault.local
- Ecommerce: http://ecommerce.local

### Method 2: Via Port-Forward

```bash
# Task Management
kubectl port-forward -n apps svc/task-management 3000:3000
# Access: http://localhost:3000

# K8s Deploy Test
kubectl port-forward -n apps svc/k8s-deploy-test 8080:8080
# Access: http://localhost:8080

# TCA InfraForge Frontend
kubectl port-forward -n apps svc/tca-infraforge-frontend 8081:80
# Access: http://localhost:8081

# TCA InfraForge Backend (API)
kubectl port-forward -n apps svc/tca-infraforge-backend 3001:3000
# Access: http://localhost:3001

# Personal Vault
kubectl port-forward -n apps svc/personal-vault 3002:3000
# Access: http://localhost:3002

# Ecommerce
kubectl port-forward -n apps svc/ecommerce-app 3003:3000
# Access: http://localhost:3003
```

---

## Verification Checklist

### ✅ 1. Namespaces

```bash
kubectl get namespaces apps
```

Expected: `Active` status

### ✅ 2. Deployments

```bash
kubectl get deployments -n apps
```

Expected: All deployments show `READY X/X` (e.g., `3/3`)

### ✅ 3. Pods

```bash
kubectl get pods -n apps
```

Expected: All pods show `Running` status and `1/1` ready

### ✅ 4. Services

```bash
kubectl get svc -n apps
```

Expected: 6 services with `ClusterIP` type

### ✅ 5. Ingresses

```bash
kubectl get ingress -n apps
```

Expected: 6 ingress resources with hostnames configured

### ✅ 6. ArgoCD Applications

```bash
kubectl get applications -n argocd | grep -E 'task-management|k8s-deploy-test|tca-infraforge|personal-vault|ecommerce'
```

Expected: All show `Synced` and `Healthy` status

---

## Monitoring Your Applications

### View in ArgoCD UI

```bash
# Port-forward ArgoCD server
kubectl port-forward -n argocd svc/argocd-server 8080:80

# Open browser
open http://localhost:8080

# Login with credentials from earlier setup
# Default username: admin
# Password: kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

### View in Grafana

```bash
# Port-forward Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Open browser
open http://localhost:3000

# Login: admin / <password-from-setup>
# Navigate to: Dashboards → Kubernetes Dashboard (#315)
```

### Check Resource Usage

```bash
# Overall cluster resources
kubectl top nodes

# Pod resource usage
kubectl top pods -n apps

# Detailed pod info
kubectl describe pod <pod-name> -n apps
```

---

## Updating Applications

### With ArgoCD (Automatic)

ArgoCD automatically syncs changes from Git every 3 minutes.

```bash
# Make changes to manifests
vim application-manifests/02-task-management/deployment.yaml

# Commit and push
git add application-manifests/
git commit -m "Update task-management deployment"
git push origin main

# Watch ArgoCD sync
kubectl get applications -n argocd -w
```

### Manual Sync

```bash
# Trigger immediate sync
kubectl patch application task-management -n argocd \
  -p '{"metadata": {"annotations": {"argocd.argoproj.io/refresh": "hard"}}}' \
  --type merge
```

### Without ArgoCD

```bash
# Edit deployment
kubectl edit deployment task-management -n apps

# Or apply updated manifests
kubectl apply -f application-manifests/02-task-management/
```

---

## Scaling Applications

### Scale Up

```bash
# Scale task-management to 5 replicas
kubectl scale deployment task-management -n apps --replicas=5

# Verify
kubectl get pods -n apps -l app=task-management
```

### Scale Down

```bash
# Scale to 1 replica (development mode)
kubectl scale deployment task-management -n apps --replicas=1
```

### Scale All Applications

```bash
# Scale all to 2 replicas (resource conservation)
for app in task-management k8s-deploy-test tca-infraforge-backend tca-infraforge-frontend personal-vault ecommerce-app; do
  kubectl scale deployment $app -n apps --replicas=2
done
```

---

## Troubleshooting

### Issue: Pods stuck in `Pending`

**Cause:** Insufficient resources

```bash
# Check resource availability
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name> -n apps
```

**Solution:** Scale down replicas or increase OrbStack memory allocation.

### Issue: `ImagePullBackOff`

**Cause:** Image not found or registry issue

```bash
# Check pod events
kubectl describe pod <pod-name> -n apps

# Verify image exists
docker pull temitayocharles/task-management-app:latest
```

**Solution:** Check image name/tag in deployment.yaml

### Issue: `CrashLoopBackOff`

**Cause:** Application crashing on startup

```bash
# Check logs
kubectl logs <pod-name> -n apps

# Check previous logs
kubectl logs <pod-name> -n apps --previous
```

**Solution:** Fix application configuration or environment variables.

### Issue: Ingress not working

**Cause:** Ingress controller not running or /etc/hosts not configured

```bash
# Check ingress-nginx
kubectl get pods -n ingress-nginx

# Check ingress resources
kubectl describe ingress -n apps

# Verify /etc/hosts
cat /etc/hosts | grep local
```

**Solution:** Ensure ingress-nginx is running and /etc/hosts is configured.

### Issue: ArgoCD shows `OutOfSync`

**Cause:** Local changes or Git repository mismatch

```bash
# Check what's different
kubectl describe application task-management -n argocd

# Force hard refresh
kubectl patch application task-management -n argocd \
  -p '{"metadata": {"annotations": {"argocd.argoproj.io/refresh": "hard"}}}' \
  --type merge
```

---

## Resource Optimization

### Current Total Usage

- **16 pods** across 6 applications
- **~2.1 CPU cores** requested
- **~2.7GB memory** requested

### Optimization Strategy 1: Reduce Replicas

```bash
# Scale down to 1 replica each (testing/dev)
kubectl scale deployment -n apps --replicas=1 task-management k8s-deploy-test personal-vault ecommerce-app

# Scale down to 2 replicas (production-lite)
kubectl scale deployment -n apps --replicas=2 tca-infraforge-backend tca-infraforge-frontend

# New total: 8 pods, ~1.05 CPU, ~1.35GB memory
```

### Optimization Strategy 2: Deploy Selectively

```bash
# Deploy only critical apps
kubectl apply -f application-manifests/argocd/individual-apps/tca-infraforge.yaml
kubectl apply -f application-manifests/argocd/individual-apps/personal-vault.yaml

# Total: 5 pods, ~600m CPU, ~768Mi memory
```

### Optimization Strategy 3: Lower Resource Requests

Edit each `deployment.yaml` and reduce:

```yaml
resources:
  requests:
    memory: "64Mi"    # Was 128Mi
    cpu: "50m"        # Was 100m
  limits:
    memory: "128Mi"   # Was 256Mi
    cpu: "100m"       # Was 200m
```

---

## Cleanup

### Delete Individual Applications

```bash
# Delete specific app
kubectl delete application task-management -n argocd

# Delete all ArgoCD applications
kubectl delete applications -n argocd -l managed-by=argocd
```

### Delete All Manifests

```bash
# Delete everything
kubectl delete -f application-manifests/06-ecommerce-app/
kubectl delete -f application-manifests/05-personal-vault/
kubectl delete -f application-manifests/04-tca-infraforge/
kubectl delete -f application-manifests/03-k8s-deploy-test/
kubectl delete -f application-manifests/02-task-management/
kubectl delete -f application-manifests/01-namespaces/
```

### Nuclear Option

```bash
# Delete entire namespace (removes all apps)
kubectl delete namespace apps
```

---

## Next Steps

1. ✅ **Monitor in Grafana** - Dashboard #315 shows all pods
2. ✅ **Set up CI/CD** - Auto-build images on Git push
3. ✅ **Configure secrets** - Use Sealed Secrets for personal-vault
4. ✅ **Add custom domains** - Replace .local with real domains
5. ✅ **Enable TLS** - Add cert-manager for HTTPS
6. ✅ **Set up backups** - Velero for disaster recovery

---

**Need Help?**
- Check logs: `kubectl logs -n apps -l app=<app-name>`
- Check events: `kubectl get events -n apps --sort-by='.lastTimestamp'`
- ArgoCD UI: `kubectl port-forward -n argocd svc/argocd-server 8080:80`
- Grafana: `kubectl port-forward -n monitoring svc/grafana 3000:3000`
