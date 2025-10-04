# 🚀 START HERE - 5 Minutes to Deploy

## Step 1️⃣: Update Git URLs (30 seconds)

```bash
cd application-manifests
./setup.sh
```
Select: **Option 1** → Enter your repo: `temitayocharles/TCA-InfraForge-k8s-Lab`

---

## Step 2️⃣: Create Namespace (10 seconds)

```bash
kubectl apply -f 01-namespaces/namespace.yaml
```

---

## Step 3️⃣: Deploy Your First App (2 minutes)

```bash
./setup.sh
```
Select: **Option 5** → Choose **3** (TCA InfraForge)

Wait for: `Synced` ✅ `Healthy` ✅

---

## Step 4️⃣: Deploy More Apps (optional)

Run `./setup.sh` → **Option 5** again for each app:
- **1** = Task Management
- **2** = K8s Deploy Test  
- **4** = Personal Vault
- **5** = Ecommerce

---

## Step 5️⃣: Access Your Apps

```bash
# Add domains to /etc/hosts
./setup.sh
```
Select: **Option 8**

Then open: http://tca-infraforge.local

---

## 🆘 Need Help?

**Check status:**
```bash
kubectl get applications -n argocd
kubectl get pods -n apps
```

**Watch deployment:**
```bash
kubectl get application tca-infraforge -n argocd -w
```

**Something wrong?** → Check `TROUBLESHOOTING.md`

**Want details?** → Check `DETAILED-GUIDE.md`

---

## ⚡ That's It!

You deployed a Kubernetes app with ArgoCD in 5 minutes.

**Next:** Deploy more apps with `./setup.sh` → Option 5
