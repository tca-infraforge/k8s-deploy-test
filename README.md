# k8s-deploy-test CI/CD Setup

This repository is configured for automatic deployment to TCA-InfraForge Kubernetes cluster via GitHub Actions.

## 🚀 Quick Setup

### 1. Configure GitHub Secrets

Go to **Settings** → **Secrets and variables** → **Actions** and add:

| Secret | Description | Example |
|--------|-------------|---------|
| `KUBE_CONFIG` | Base64-encoded kubeconfig for cluster access | `YXBpVmVyc2lvbjogdjEKa2luZDogQ29uZmlnCmNsdXN0ZXJzOgotIGNsdXN0ZXI6CiAgICBpbnNlY3VyZS1za2lwLXRscy12ZXJpZnk6IHRydWUKICAgIHNlcnZlcjogaHR0cHM6Ly8xMjcuMC4wLjE6MjY0NDMKICBuYW1lOiBvcmJzdGFjawpjb250ZXh0czoKLSBjb250ZXh0OgogICAgY2x1c3Rlcjogb3Jic3RhY2sKICAgIHVzZXI6IGdpdGh1Yi1hY3Rpb25zLWRlcGxveWVyCiAgbmFtZTogZ2l0aHViLWFjdGlvbnMtY29udGV4dApjdXJyZW50LWNvbnRleHQ6IGdpdGh1Yi1hY3Rpb25zLWNvbnRleHQKdXNlcnM6Ci0gbmFtZTogZ2l0aHViLWFjdGlvbnMtZGVwbG95ZXIKICB1c2VyOgogICAgdG9rZW46IGV5SmhiR2NpT2lKU1V6STFOaUlzSW10cFpDSTZJa0ZQUTFwSlVYSlNNelJrWDJkMlZqTnBka2QxU2s1aVluTnZXVEkwWVdOeWEwVmpZbUpMU0Rkb2Mwa2lmUS5leUpoZFdRaU9sc2lhSFIwY0hNNkx5OXJkV0psY201bGRHVnpMbVJsWm1GMWJIUXVjM1pqTG1Oc2RYTjBaWEl1Ykc5allXd2lMQ0pyTTNNaVhTd2laWGh3SWpveE56ZzVNemd4TlRZd0xDSnBZWFFpT2pFM05UYzRORFUxTmpBc0ltbHpjeUk2SW1oMGRIQnpPaTh2YTNWaVpYSnVaWFJsY3k1a1pXWmhkV3gwTG5OMll5NWpiSFZ6ZEdWeUxteHZZMkZzSWl3aWFuUnBJam9pWXpJNFlUVXdNMkl0Tm1OaU5TMDBZek5qTFdJd05UZ3RNV1ZpTkdFek1qVXpPV0kxSWl3aWEzVmlaWEp1WlhSbGN5NXBieUk2ZXlKdVlXMWxjM0JoWTJVaU9pSnJkV0psTFhONWMzUmxiU0lzSW5ObGNuWnBZMlZoWTJOdmRXNTBJanA3SW01aGJXVWlPaUpuYVhSb2RXSXRZV04wYVc5dWN5MWtaWEJzYjNsbGNpSXNJblZwWkNJNklqSTFNV0l3WTJJMExUVmpPREF0TkRBNE9DMWhPRGxsTFdWall6ZGxOVGd3TkRNNE1TSjlmU3dpYm1KbUlqb3hOelUzT0RRMU5UWXdMQ0p6ZFdJaU9pSnplWE4wWlcwNmMyVnlkbWxqWldGalkyOTFiblE2YTNWaVpTMXplWE4wWlcwNloybDBhSFZpTFdGamRHbHZibk10WkdWd2JHOTVaWElpZlEuTWhjdTYtaG9OeHJQaG05aVVjLVEyWkM2OWtMbWZ1Xzhhdk1xQkhxbVNDVXVaOFBpdURINmdDWV8zQkpkamxDWm5vc3JjLTZSSTVtOEZhajE5ck1McU9rWVMyRWJrWldvS0x6bGpVV2F0NHFLYUdvOVNVTG1wVkZ3QS1aaXNWZ0hJczk3bXh3VnQ5LWxWR2ZSOVVCbG04dmktS05XMVRuT2wyQWtOcjlYVkl0anhGQ3hYYWpUMXYxV1Y1R0Z2VXBFT2R5bGJaeDR3SnpHQnBMUnJmdjQ4eU9rcGJfbkdvTExDOU9uVDk5N3NuSHVqZTdBdVdjeGptT2hUdEd5RkNnby12OHhtVVFIZnRhbkhjQWpPT0tDYmFCRzAwUmVYRHd3YXNvVWhfVTR4OXBpTXBvWEFDLXRoU2FlWENYY1g2MXJOWjRMNTEtR2hXUlV6VXVaa2l1YThnCg==` |
| `DOCKER_USERNAME` | Docker Hub username | `temitayocharles` |
| `DOCKER_PASSWORD` | Docker Hub access token | Your Docker Hub token |

### 2. Repository Structure

Your repository should have:
```
k8s-deploy-test/
├── Dockerfile                    # Container build instructions
├── src/                         # Application source code
├── requirements.txt             # Python dependencies (if applicable)
├── package.json                 # Node.js dependencies (if applicable)
└── TCA-InfraForge/              # Submodule (auto-added)
    ├── .github/workflows/
    │   └── k8s-deploy-test.yml   # Deployment workflow
    └── manifests/apps/
        └── k8s-deploy-test-deployment.yaml
```

### 3. Dockerfile Requirements

Your application must expose port 8080 and have these health endpoints:
- `GET /health` - Liveness probe
- `GET /ready` - Readiness probe

Example Dockerfile:
```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8080

# Health check endpoints
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["python", "app.py"]
```

## 🔄 Deployment Flow

1. **Push to main/master** → GitHub Actions triggers
2. **TCA-InfraForge validation** → Checks cluster infrastructure
3. **Container build** → Builds and pushes Docker image
4. **Kubernetes deployment** → Updates deployment in `services` namespace
5. **Health validation** → Tests application endpoints
6. **Success notification** → Deployment complete

## 📊 Monitoring

- **Grafana Dashboard**: Monitor deployment metrics
- **Kubernetes Dashboard**: View pod status and logs
- **GitHub Actions**: Check deployment logs and status

## 🐛 Troubleshooting

### Deployment Fails
```bash
# Check pod status
kubectl get pods -n services

# View pod logs
kubectl logs -n services deployment/k8s-deploy-test

# Check service endpoints
kubectl get endpoints -n services
```

### Health Check Fails
- Ensure your app exposes `/health` and `/ready` endpoints
- Check that port 8080 is correctly exposed
- Verify application startup time is within readiness probe limits

### Image Pull Issues
- Verify Docker Hub credentials are correct
- Check that image `tca-infraforge/k8s-deploy-test` exists
- Ensure repository is public or credentials have access

## 🔧 Customization

### Environment Variables
Add environment-specific variables in the deployment manifest:
```yaml
env:
- name: TCA_ENV
  value: "development"
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: app-secrets
      key: database-url
```

### Resource Limits
Adjust CPU/memory limits in `manifests/apps/k8s-deploy-test-deployment.yaml`:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

### Scaling
Modify replica count in the deployment manifest or add HPA:
```yaml
spec:
  replicas: 3  # Adjust based on load
```

## 🌍 Multi-Environment

Deploy to different environments using workflow dispatch:

1. Go to **Actions** → **Deploy k8s-deploy-test to TCA-InfraForge**
2. Click **Run workflow**
3. Select environment (development/staging/production)
4. Deploy!

## 📞 Support

For deployment issues:
1. Check GitHub Actions logs
2. Verify TCA-InfraForge cluster status
3. Review Kubernetes events: `kubectl get events -n services`
4. Check application logs: `kubectl logs -n services -l app=k8s-deploy-test`

---

**Happy Deploying! 🚀**
