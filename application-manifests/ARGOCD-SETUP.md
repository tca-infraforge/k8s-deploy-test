# ArgoCD Setup Guide

Complete guide to integrate your applications with ArgoCD for GitOps workflow.

## What is ArgoCD?

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It:
- Monitors Git repositories for changes
- Automatically syncs applications to match desired state
- Provides a visual UI for application management
- Supports rollback, health monitoring, and notifications

## Prerequisites

✅ **Already Completed:**
- ArgoCD installed in `argocd` namespace
- ArgoCD server accessible via port-forward
- Git repository with application manifests

## ArgoCD Application Strategies

We provide **two deployment strategies**:

### Strategy 1: ApplicationSet (Recommended)

**Use when:** Deploying all applications together with consistent configuration.

**File:** `argocd/application-set.yaml`

**Advantages:**
- Deploy all 6 applications with one YAML file
- Consistent sync policies across all apps
- Easy to manage sync waves (deployment order)
- Bulk operations (sync all, delete all)

**Deployment:**
```bash
kubectl apply -f application-manifests/argocd/application-set.yaml
```

### Strategy 2: Individual Applications

**Use when:** Need different configurations per app or selective deployment.

**Files:** `argocd/individual-apps/*.yaml`

**Advantages:**
- Different sync policies per application
- Deploy only specific applications
- Fine-grained control over each app
- Independent lifecycle management

**Deployment:**
```bash
kubectl apply -f application-manifests/argocd/individual-apps/
```

---

## Step-by-Step Setup

### Step 1: Prepare Your Git Repository

#### Option A: Use This Repository

If you want to use the current workspace as your Git source:

```bash
cd /Volumes/512-B/Documents/PERSONAL/TCA-InfraForge-k8s-Lab

# Check if Git is initialized
git status

# If not initialized
git init
git add application-manifests/
git commit -m "Add application manifests"

# Add remote (if not exists)
git remote add origin https://github.com/temitayocharles/TCA-InfraForge-k8s-Lab.git

# Push
git push -u origin main
```

#### Option B: Create Separate Repository

```bash
# Create new repository on GitHub
# Name: k8s-applications

# Clone it
git clone https://github.com/temitayocharles/k8s-applications.git
cd k8s-applications

# Copy manifests
cp -r /Volumes/512-B/Documents/PERSONAL/TCA-InfraForge-k8s-Lab/application-manifests/* .

# Commit and push
git add .
git commit -m "Initial commit: Application manifests"
git push origin main
```

### Step 2: Update Repository URLs

**IMPORTANT:** Replace placeholder URLs in ArgoCD YAML files.

```bash
cd application-manifests/argocd

# Update ApplicationSet
vim application-set.yaml
# Change: repoURL: https://github.com/YOUR-USERNAME/YOUR-REPO.git
# To:     repoURL: https://github.com/temitayocharles/TCA-InfraForge-k8s-Lab.git

# Update individual apps
cd individual-apps
for file in *.yaml; do
  vim "$file"
  # Change the same repoURL in each file
done
```

**Or use this automated script:**

```bash
cd /Volumes/512-B/Documents/PERSONAL/TCA-InfraForge-k8s-Lab

# Replace YOUR-USERNAME/YOUR-REPO with your actual repository
REPO_URL="temitayocharles/TCA-InfraForge-k8s-Lab"

find application-manifests/argocd -name '*.yaml' \
  -exec sed -i '' "s|YOUR-USERNAME/YOUR-REPO|$REPO_URL|g" {} +

echo "✅ Repository URLs updated"
```

### Step 3: Configure Git Credentials (If Private Repository)

If your repository is private, ArgoCD needs authentication:

#### Method A: HTTPS with Token

```bash
# Create GitHub personal access token
# Go to: https://github.com/settings/tokens
# Scope: repo (full control)

# Add credentials to ArgoCD
kubectl create secret generic github-creds \
  -n argocd \
  --from-literal=username=temitayocharles \
  --from-literal=password=YOUR_GITHUB_TOKEN

# Label the secret
kubectl label secret github-creds \
  -n argocd \
  argocd.argoproj.io/secret-type=repository
```

#### Method B: SSH Key

```bash
# Generate SSH key (if not exists)
ssh-keygen -t ed25519 -C "argocd@k8s-cluster" -f ~/.ssh/argocd

# Add public key to GitHub
# Go to: https://github.com/settings/keys
# Add content of: cat ~/.ssh/argocd.pub

# Add private key to ArgoCD
kubectl create secret generic github-ssh \
  -n argocd \
  --from-file=sshPrivateKey=$HOME/.ssh/argocd

# Label the secret
kubectl label secret github-ssh \
  -n argocd \
  argocd.argoproj.io/secret-type=repository
```

### Step 4: Deploy Applications

#### Option A: Using ApplicationSet

```bash
# Create namespace first
kubectl apply -f application-manifests/01-namespaces/namespace.yaml

# Deploy ApplicationSet (all apps)
kubectl apply -f application-manifests/argocd/application-set.yaml

# Verify
kubectl get applicationset -n argocd
kubectl get applications -n argocd
```

#### Option B: Using Individual Applications

```bash
# Deploy namespaces
kubectl apply -f application-manifests/argocd/individual-apps/namespaces.yaml

# Deploy all apps
kubectl apply -f application-manifests/argocd/individual-apps/

# Or deploy selectively
kubectl apply -f application-manifests/argocd/individual-apps/task-management.yaml
kubectl apply -f application-manifests/argocd/individual-apps/tca-infraforge.yaml
```

### Step 5: Access ArgoCD UI

```bash
# Port-forward ArgoCD server
kubectl port-forward -n argocd svc/argocd-server 8080:80

# Get admin password
kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Open browser
open http://localhost:8080

# Login:
# Username: admin
# Password: <output from above command>
```

### Step 6: Verify Applications in UI

In the ArgoCD UI, you should see:

```
┌────────────────────────────────────────┐
│  Applications (6)                      │
├────────────────────────────────────────┤
│  ✅ task-management      Synced Healthy│
│  ✅ k8s-deploy-test     Synced Healthy│
│  ✅ tca-infraforge-backend Synced Healthy│
│  ✅ tca-infraforge-frontend Synced Healthy│
│  ✅ personal-vault      Synced Healthy│
│  ✅ ecommerce-app       Synced Healthy│
└────────────────────────────────────────┘
```

---

## ArgoCD Features Configuration

### Auto-Sync

Already enabled in manifests. ArgoCD automatically syncs every 3 minutes.

```yaml
syncPolicy:
  automated:
    prune: true        # Delete removed resources
    selfHeal: true     # Fix manual changes
    allowEmpty: false  # Prevent accidental deletions
```

### Sync Waves

Controls deployment order. Lower numbers deploy first.

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"  # Deploy first
```

**Our sync wave order:**
1. Wave 0: Namespaces (automatic)
2. Wave 2: task-management
3. Wave 3: k8s-deploy-test
4. Wave 4: tca-infraforge-backend
5. Wave 5: tca-infraforge-frontend
6. Wave 6: personal-vault
7. Wave 7: ecommerce-app

### Health Checks

ArgoCD monitors application health using:
- Deployment status (replicas ready)
- Pod status (running, healthy)
- Readiness probes
- Custom health checks

### Pruning

Automatically remove resources deleted from Git:

```yaml
syncPolicy:
  automated:
    prune: true
```

**Example:** Delete `deployment.yaml` from Git → ArgoCD deletes deployment from cluster

---

## GitOps Workflow

### 1. Make Changes

```bash
# Edit manifest locally
vim application-manifests/02-task-management/deployment.yaml

# Change replicas: 3 → 5
spec:
  replicas: 5
```

### 2. Commit to Git

```bash
git add application-manifests/02-task-management/deployment.yaml
git commit -m "Scale task-management to 5 replicas"
git push origin main
```

### 3. ArgoCD Auto-Syncs

ArgoCD detects change and syncs automatically (within 3 minutes).

```bash
# Watch sync progress
kubectl get applications -n argocd -w

# Or use ArgoCD CLI
argocd app sync task-management
```

### 4. Verify

```bash
# Check replicas
kubectl get deployment task-management -n apps

# Should show: READY 5/5
```

---

## Manual Operations

### Sync Application

```bash
# Via kubectl
kubectl patch application task-management -n argocd \
  -p '{"metadata": {"annotations": {"argocd.argoproj.io/refresh": "hard"}}}' \
  --type merge

# Via ArgoCD CLI (if installed)
argocd app sync task-management
```

### Rollback Application

```bash
# Via kubectl (revert to previous Git commit)
git revert HEAD
git push origin main

# ArgoCD automatically syncs to previous state
```

### Disable Auto-Sync

```bash
# Edit application
kubectl edit application task-management -n argocd

# Remove or set to false:
syncPolicy:
  automated: null  # Disable auto-sync
```

### Force Sync

```bash
# Ignore differences and force sync
argocd app sync task-management --force
```

---

## Monitoring and Alerts

### View Sync Status

```bash
# All applications
kubectl get applications -n argocd

# Specific application
kubectl describe application task-management -n argocd

# Watch continuously
watch kubectl get applications -n argocd
```

### Check Sync History

In ArgoCD UI:
1. Click on application
2. Go to "History & Rollback" tab
3. See all sync events with timestamps

### Application Metrics

ArgoCD exposes Prometheus metrics:

```bash
# Port-forward ArgoCD metrics
kubectl port-forward -n argocd svc/argocd-metrics 8082:8082

# Scrape metrics
curl http://localhost:8082/metrics
```

**Key metrics:**
- `argocd_app_info` - Application information
- `argocd_app_sync_status` - Sync status (0=synced, 1=out-of-sync)
- `argocd_app_health_status` - Health status

---

## ArgoCD CLI Setup (Optional)

Install ArgoCD CLI for advanced operations:

```bash
# macOS
brew install argocd

# Login
argocd login localhost:8080 --insecure

# List applications
argocd app list

# Sync application
argocd app sync task-management

# Get application details
argocd app get task-management

# View logs
argocd app logs task-management
```

---

## Troubleshooting

### Issue: Application shows `OutOfSync`

**Cause:** Local changes or Git not pushed.

```bash
# Check what's different
kubectl describe application task-management -n argocd

# Force refresh
kubectl patch application task-management -n argocd \
  -p '{"metadata": {"annotations": {"argocd.argoproj.io/refresh": "hard"}}}' \
  --type merge
```

### Issue: Application shows `Degraded`

**Cause:** Pods not healthy or deployment failed.

```bash
# Check pods
kubectl get pods -n apps -l app=task-management

# Check pod logs
kubectl logs -n apps -l app=task-management

# Check events
kubectl get events -n apps --sort-by='.lastTimestamp'
```

### Issue: Can't access ArgoCD UI

**Cause:** Port-forward not running.

```bash
# Check ArgoCD server is running
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server

# Create port-forward
kubectl port-forward -n argocd svc/argocd-server 8080:80

# Check in browser: http://localhost:8080
```

### Issue: Repository authentication failed

**Cause:** Private repo without credentials.

```bash
# Check repository connection
kubectl get secrets -n argocd | grep github

# Re-add credentials (see Step 3)
```

### Issue: Sync fails with "resource not found"

**Cause:** CRD or namespace not created.

```bash
# Ensure namespace exists first
kubectl apply -f application-manifests/01-namespaces/namespace.yaml

# Then sync application
argocd app sync task-management
```

---

## Advanced Configuration

### Multiple Environments

Create separate branches for different environments:

```bash
# Create branches
git checkout -b development
git checkout -b staging
git checkout -b production

# Update ArgoCD applications to use different branches
# In application YAML:
source:
  targetRevision: development  # or staging, production
```

### Helm Integration

If you convert manifests to Helm charts:

```yaml
source:
  repoURL: https://github.com/temitayocharles/TCA-InfraForge-k8s-Lab.git
  targetRevision: main
  path: helm-charts/task-management
  helm:
    values: |
      replicas: 3
      image:
        tag: latest
```

### Kustomize Integration

Use Kustomize for patching:

```yaml
source:
  repoURL: https://github.com/temitayocharles/TCA-InfraForge-k8s-Lab.git
  targetRevision: main
  path: application-manifests/02-task-management
  kustomize:
    namePrefix: prod-
    commonLabels:
      environment: production
```

### Notifications

Configure Slack/Email notifications:

```bash
# Install ArgoCD notifications
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/manifests/install.yaml

# Configure Slack webhook
kubectl create secret generic argocd-notifications-secret \
  -n argocd \
  --from-literal=slack-token=YOUR_SLACK_TOKEN
```

---

## Best Practices

### ✅ 1. Use Git Tags for Releases

```bash
# Tag production release
git tag -a v1.0.0 -m "Production release v1.0.0"
git push origin v1.0.0

# Update ArgoCD application
source:
  targetRevision: v1.0.0  # Instead of 'main'
```

### ✅ 2. Separate Configs from Code

Keep application manifests in separate repository from application code.

### ✅ 3. Use Sync Waves

Deploy dependencies before dependents:
- Wave 1: Databases, secrets
- Wave 2: Backend services
- Wave 3: Frontend services

### ✅ 4. Enable Self-Healing

Let ArgoCD automatically fix manual changes:

```yaml
syncPolicy:
  automated:
    selfHeal: true
```

### ✅ 5. Use ApplicationSets for Consistency

Manage multiple apps with consistent configuration.

### ✅ 6. Monitor Sync Status

Set up alerts for out-of-sync or unhealthy applications.

---

## Next Steps

1. ✅ **Set up CI/CD** - Auto-build images and update manifests
2. ✅ **Configure notifications** - Get alerts on sync failures
3. ✅ **Add resource hooks** - Run migrations before deployments
4. ✅ **Enable SSO** - Use GitHub/Google for ArgoCD login
5. ✅ **Create AppProjects** - Organize applications by team/project

---

**Resources:**
- ArgoCD Docs: https://argo-cd.readthedocs.io
- GitOps Guide: https://www.gitops.tech
- Best Practices: https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/

**Need Help?**
- ArgoCD UI: `kubectl port-forward -n argocd svc/argocd-server 8080:80`
- Check applications: `kubectl get applications -n argocd`
- View logs: `kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server`
