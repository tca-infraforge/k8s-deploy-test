# 🐛 Troubleshooting - Quick Fixes

## 🔴 Pods Not Starting

```bash
# Check what's wrong
kubectl get pods -n apps
kubectl describe pod <pod-name> -n apps

# Common fixes:
# 1. Out of memory → Scale down
kubectl scale deployment <app-name> -n apps --replicas=1

# 2. Image pull failed → Check image name
kubectl get deployment <app-name> -n apps -o yaml | grep image:
```

---

## 🔴 Application Not Syncing in ArgoCD

```bash
# Force refresh
kubectl get application <app-name> -n argocd

# Check logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=50

# Force sync
kubectl patch application <app-name> -n argocd \
  -p '{"metadata": {"annotations": {"argocd.argoproj.io/refresh": "hard"}}}' \
  --type merge
```

---

## 🔴 Can't Access http://app.local URLs

```bash
# Check if /etc/hosts is configured
cat /etc/hosts | grep local

# Add entries if missing
echo "127.0.0.1  tca-infraforge.local vault.local" | sudo tee -a /etc/hosts

# Alternative: Use port-forward
kubectl port-forward -n apps svc/tca-infraforge-frontend 8080:80
# Then open: http://localhost:8080
```

---

## 🔴 Out of Memory

```bash
# Check usage
kubectl top nodes
kubectl top pods -n apps

# Quick fix: Scale down everything
./setup.sh
# Select Option 7 → Development profile

# Or manually scale down
kubectl scale deployment -n apps --replicas=1 --all
```

---

## 🔴 Git Repository URL Not Working

```bash
# Update URLs again
./setup.sh
# Select Option 1

# Verify it worked
grep "temitayocharles" argocd/individual-apps/*.yaml
```

---

## 🔴 Ingress Not Working

```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress resources
kubectl get ingress -n apps

# Restart if needed
kubectl rollout restart deployment -n ingress-nginx
```

---

## 🆘 Still Stuck?

1. Check ArgoCD UI: `./setup.sh` → Option 10
2. Check Grafana: `./setup.sh` → Option 11  
3. View logs: `kubectl logs -n apps -l app=<app-name> --tail=100`
4. Delete and redeploy: `kubectl delete application <app-name> -n argocd`

---

**Most Common Issue:** Not enough RAM → Scale down with `./setup.sh` Option 7
