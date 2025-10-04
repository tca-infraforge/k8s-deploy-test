# 📋 Cheat Sheet - Copy & Paste Commands

## 🚀 Initial Setup (One Time)

```bash
cd application-manifests
./setup.sh  # Select Option 1, enter: temitayocharles/TCA-InfraForge-k8s-Lab
kubectl apply -f 01-namespaces/namespace.yaml
```

---

## 🎮 Deploy Apps

```bash
./setup.sh  # Select Option 5, choose app number
```

**OR manually:**

```bash
kubectl apply -f argocd/individual-apps/tca-infraforge.yaml
kubectl apply -f argocd/individual-apps/personal-vault.yaml
kubectl apply -f argocd/individual-apps/task-management.yaml
kubectl apply -f argocd/individual-apps/k8s-deploy-test.yaml
kubectl apply -f argocd/individual-apps/ecommerce-app.yaml
```

---

## 👀 Check Status

```bash
# Quick overview
kubectl get applications -n argocd
kubectl get pods -n apps

# Watch deployment
kubectl get application <app-name> -n argocd -w

# Detailed status
kubectl describe application <app-name> -n argocd
```

---

## 📊 Monitor Resources

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -n apps

# Watch pods
kubectl get pods -n apps -w
```

---

## 🔍 Debug Problems

```bash
# Pod logs
kubectl logs -n apps -l app=<app-name> --tail=50

# Pod details
kubectl describe pod <pod-name> -n apps

# Events
kubectl get events -n apps --sort-by='.lastTimestamp'
```

---

## ⚙️ Scale Apps

```bash
# Scale up/down
kubectl scale deployment <app-name> -n apps --replicas=2

# Scale all to 1
kubectl scale deployment -n apps --replicas=1 --all
```

---

## 🌐 Access Apps

```bash
# Add to /etc/hosts
echo "127.0.0.1  tca-infraforge.local vault.local task-management.local k8s-test.local ecommerce.local" | sudo tee -a /etc/hosts

# Port forward (alternative)
kubectl port-forward -n apps svc/<service-name> 8080:80
```

**URLs:**
- http://tca-infraforge.local
- http://vault.local
- http://task-management.local
- http://k8s-test.local
- http://ecommerce.local

---

## 🔄 Update Apps

```bash
# Force ArgoCD sync
kubectl patch application <app-name> -n argocd \
  -p '{"metadata": {"annotations": {"argocd.argoproj.io/refresh": "hard"}}}' \
  --type merge

# Change image
kubectl set image deployment/<app-name> \
  <container-name>=<new-image>:tag \
  -n apps
```

---

## 🗑️ Delete Apps

```bash
# Delete one app
kubectl delete application <app-name> -n argocd

# Delete all apps
kubectl delete applications -n argocd --all

# Delete namespace (removes everything)
kubectl delete namespace apps
```

---

## 🎯 Common App Names

- `tca-infraforge`
- `personal-vault`
- `task-management`
- `k8s-deploy-test`
- `ecommerce-app`

---

## 🆘 Emergency Fixes

```bash
# Out of memory - scale down everything
kubectl scale deployment -n apps --replicas=1 --all

# Restart deployment
kubectl rollout restart deployment <app-name> -n apps

# Delete stuck pod
kubectl delete pod <pod-name> -n apps --force --grace-period=0

# Restart ingress controller
kubectl rollout restart deployment -n ingress-nginx
```

---

## 📦 Backup & Restore

```bash
# Backup
kubectl get all -n apps -o yaml > backup.yaml

# Restore
kubectl apply -f backup.yaml
```

---

## 🎛️ Interactive Script

```bash
./setup.sh
```

- **1** = Update Git URLs
- **5** = Deploy apps (RECOMMENDED)
- **6** = Check status
- **7** = Scale apps
- **8** = Configure /etc/hosts
- **10** = Open ArgoCD UI
- **11** = Open Grafana

---

**Pro Tip:** Bookmark this page for quick reference! 🔖
