#!/bin/bash
#
# Application Manifests Setup Script
# 
# This script helps you prepare and deploy your Kubernetes applications
#

set -e

MANIFESTS_DIR="/Volumes/512-B/Documents/PERSONAL/TCA-InfraForge-k8s-Lab/application-manifests"
ARGOCD_DIR="$MANIFESTS_DIR/argocd"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════╗"
echo "║   Application Manifests Setup & Deploy               ║"
echo "║   Production-Ready Kubernetes Deployment             ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Main menu
show_menu() {
    echo ""
    echo -e "${GREEN}═════════════════════════════════════════${NC}"
    echo -e "${GREEN}          APPLICATION SETUP MENU         ${NC}"
    echo -e "${GREEN}═════════════════════════════════════════${NC}"
    echo ""
    echo "  1) Update Git Repository URLs"
    echo "  2) Verify Manifest Structure"
    echo "  3) Test Manifest Syntax"
    echo "  4) Deploy with ArgoCD (All Apps at Once - Needs 6GB RAM)"
    echo "  5) Deploy Individual Application ⭐ RECOMMENDED"
    echo "  6) Check Deployment Status"
    echo "  7) Scale Applications"
    echo "  8) Update /etc/hosts"
    echo "  9) View Application URLs"
    echo " 10) Open ArgoCD UI"
    echo " 11) Open Grafana"
    echo " 12) View Documentation"
    echo "  0) Exit"
    echo ""
    echo -e "${GREEN}═════════════════════════════════════════${NC}"
    echo -n "Select option: "
}

# Update Git URLs
update_git_urls() {
    echo ""
    echo -e "${BLUE}📝 Update Git Repository URLs${NC}"
    echo ""
    echo "Current placeholder: YOUR-USERNAME/YOUR-REPO"
    echo ""
    read -p "Enter your Git repository (format: username/repo): " REPO
    
    if [[ -z "$REPO" ]]; then
        echo -e "${RED}❌ Repository cannot be empty${NC}"
        return
    fi
    
    echo ""
    echo -e "${YELLOW}Updating ArgoCD manifests...${NC}"
    
    # Update all ArgoCD files
    find "$ARGOCD_DIR" -name '*.yaml' -exec sed -i '' "s|YOUR-USERNAME/YOUR-REPO|$REPO|g" {} +
    
    # Verify
    UPDATED=$(grep -r "$REPO" "$ARGOCD_DIR" | wc -l | tr -d ' ')
    
    echo -e "${GREEN}✅ Updated $UPDATED references to: $REPO${NC}"
    echo ""
    echo "Files updated:"
    find "$ARGOCD_DIR" -name '*.yaml' -exec basename {} \;
}

# Verify structure
verify_structure() {
    echo ""
    echo -e "${BLUE}🔍 Verifying Manifest Structure${NC}"
    echo ""
    
    # Check directories
    DIRS=(
        "01-namespaces"
        "02-task-management"
        "03-k8s-deploy-test"
        "04-tca-infraforge"
        "05-personal-vault"
        "06-ecommerce-app"
        "argocd"
        "argocd/individual-apps"
    )
    
    echo "Checking directories..."
    for dir in "${DIRS[@]}"; do
        if [[ -d "$MANIFESTS_DIR/$dir" ]]; then
            echo -e "  ${GREEN}✓${NC} $dir"
        else
            echo -e "  ${RED}✗${NC} $dir (missing)"
        fi
    done
    
    echo ""
    echo "Checking manifest files..."
    
    # Count files
    DEPLOYMENT_COUNT=$(find "$MANIFESTS_DIR" -name "*deployment.yaml" | wc -l | tr -d ' ')
    SERVICE_COUNT=$(find "$MANIFESTS_DIR" -name "*service.yaml" | wc -l | tr -d ' ')
    INGRESS_COUNT=$(find "$MANIFESTS_DIR" -name "*ingress.yaml" | wc -l | tr -d ' ')
    ARGOCD_COUNT=$(find "$ARGOCD_DIR" -name "*.yaml" | wc -l | tr -d ' ')
    
    echo "  Deployments: $DEPLOYMENT_COUNT"
    echo "  Services: $SERVICE_COUNT"
    echo "  Ingresses: $INGRESS_COUNT"
    echo "  ArgoCD Apps: $ARGOCD_COUNT"
    
    echo ""
    TOTAL_FILES=$(find "$MANIFESTS_DIR" -name "*.yaml" -o -name "*.md" | wc -l | tr -d ' ')
    echo -e "${GREEN}✅ Total files: $TOTAL_FILES${NC}"
}

# Test manifest syntax
test_syntax() {
    echo ""
    echo -e "${BLUE}🧪 Testing Manifest Syntax${NC}"
    echo ""
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl not found${NC}"
        return
    fi
    
    # Dry-run validation
    echo "Running kubectl dry-run validation..."
    echo ""
    
    ERRORS=0
    for dir in "$MANIFESTS_DIR"/0*; do
        if [[ -d "$dir" ]]; then
            APP=$(basename "$dir")
            echo -n "  Testing $APP... "
            
            if kubectl apply -f "$dir" --dry-run=client &> /dev/null; then
                echo -e "${GREEN}✓${NC}"
            else
                echo -e "${RED}✗${NC}"
                ((ERRORS++))
            fi
        fi
    done
    
    echo ""
    if [[ $ERRORS -eq 0 ]]; then
        echo -e "${GREEN}✅ All manifests are valid${NC}"
    else
        echo -e "${RED}❌ Found $ERRORS errors${NC}"
    fi
}

# Deploy with ArgoCD - All at once (ApplicationSet)
deploy_all() {
    echo ""
    echo -e "${BLUE}🚀 Deploy All Applications with ArgoCD (All at Once)${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  This deploys all 6 applications simultaneously (16 pods)${NC}"
    echo "Recommended only for systems with 6GB+ RAM allocated to Kubernetes."
    echo ""
    echo "For 3GB systems, use Option 5 (Deploy Individual) instead."
    echo ""
    read -p "Continue with bulk deployment? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Cancelled. Use Option 5 to deploy applications one by one."
        return
    fi
    
    # Check if Git URLs are updated
    if grep -q "YOUR-USERNAME/YOUR-REPO" "$ARGOCD_DIR"/*.yaml 2>/dev/null; then
        echo -e "${RED}⚠️  Warning: Git repository URLs not updated!${NC}"
        echo "Please run option 1 first to update Git URLs."
        echo ""
        read -p "Continue anyway? (y/N): " CONFIRM2
        if [[ ! "$CONFIRM2" =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    echo ""
    echo "Step 1: Creating namespace..."
    kubectl apply -f "$MANIFESTS_DIR/01-namespaces/namespace.yaml"
    
    echo ""
    echo "Step 2: Deploying ArgoCD ApplicationSet (all apps)..."
    kubectl apply -f "$ARGOCD_DIR/application-set.yaml"
    
    echo ""
    echo -e "${GREEN}✅ Deployment initiated${NC}"
    echo ""
    echo "Watch deployment progress:"
    echo "  kubectl get applications -n argocd"
    echo ""
    read -p "Watch now? (y/N): " WATCH
    if [[ "$WATCH" =~ ^[Yy]$ ]]; then
        kubectl get applications -n argocd -w
    fi
}

# Deploy individual app (RECOMMENDED)
deploy_individual() {
    echo ""
    echo -e "${BLUE}📦 Deploy Individual Application (One by One - RECOMMENDED)${NC}"
    echo ""
    
    # Check if Git URLs are updated
    if grep -q "YOUR-USERNAME/YOUR-REPO" "$ARGOCD_DIR"/individual-apps/*.yaml 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Note: Git repository URLs not yet updated${NC}"
        echo "Run option 1 first to update Git URLs."
        echo ""
    fi
    
    # Check if namespace exists
    if ! kubectl get namespace apps &>/dev/null; then
        echo -e "${YELLOW}⚠️  Namespace 'apps' doesn't exist yet${NC}"
        echo ""
        read -p "Create namespace now? (Y/n): " CREATE_NS
        if [[ ! "$CREATE_NS" =~ ^[Nn]$ ]]; then
            kubectl apply -f "$MANIFESTS_DIR/01-namespaces/namespace.yaml"
            echo ""
        fi
    fi
    
    echo "Available applications:"
    echo "  1) Task Management (3 replicas, 100m CPU, 128Mi RAM)"
    echo "  2) K8s Deploy Test (2 replicas, 50m CPU, 64Mi RAM)"
    echo "  3) TCA InfraForge (6 replicas total - Backend + Frontend)"
    echo "  4) Personal Vault (2 replicas, 100m CPU, 128Mi RAM)"
    echo "  5) Ecommerce App (3 replicas, 200m CPU, 256Mi RAM)"
    echo "  6) Deploy All Remaining (deploy multiple apps)"
    echo "  0) Back to main menu"
    echo ""
    read -p "Select application (0-6): " APP_NUM
    
    case $APP_NUM in
        0) return ;;
        1) 
            APP_FILE="task-management.yaml"
            APP_NAME="task-management"
            ;;
        2) 
            APP_FILE="k8s-deploy-test.yaml"
            APP_NAME="k8s-deploy-test"
            ;;
        3) 
            APP_FILE="tca-infraforge.yaml"
            APP_NAME="tca-infraforge"
            ;;
        4) 
            APP_FILE="personal-vault.yaml"
            APP_NAME="personal-vault"
            ;;
        5) 
            APP_FILE="ecommerce-app.yaml"
            APP_NAME="ecommerce-app"
            ;;
        6)
            echo ""
            echo "Deploying all remaining applications one by one..."
            for app in task-management k8s-deploy-test tca-infraforge personal-vault ecommerce-app; do
                echo ""
                echo -e "${BLUE}Deploying $app...${NC}"
                kubectl apply -f "$ARGOCD_DIR/individual-apps/$app.yaml"
                sleep 2
            done
            echo ""
            echo -e "${GREEN}✅ All applications deployed${NC}"
            echo ""
            read -p "Watch deployment status? (y/N): " WATCH
            if [[ "$WATCH" =~ ^[Yy]$ ]]; then
                kubectl get applications -n argocd -w
            fi
            return
            ;;
        *)
            echo -e "${RED}Invalid selection${NC}"
            return
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Deploying $APP_FILE...${NC}"
    kubectl apply -f "$ARGOCD_DIR/individual-apps/$APP_FILE"
    
    echo ""
    echo -e "${GREEN}✅ Deployment initiated for $APP_NAME${NC}"
    echo ""
    echo "Watch this application's deployment:"
    echo "  kubectl get application $APP_NAME -n argocd -w"
    echo ""
    read -p "Watch now? (y/N): " WATCH
    if [[ "$WATCH" =~ ^[Yy]$ ]]; then
        echo "Press Ctrl+C when application is Synced & Healthy"
        kubectl get application "$APP_NAME" -n argocd -w
    fi
}

# Check status
check_status() {
    echo ""
    echo -e "${BLUE}📊 Deployment Status${NC}"
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ArgoCD Applications:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    kubectl get applications -n argocd 2>/dev/null || echo "No ArgoCD applications found"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Pods in apps namespace:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    kubectl get pods -n apps 2>/dev/null || echo "Namespace 'apps' not found"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Services:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    kubectl get svc -n apps 2>/dev/null || echo "No services found"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Ingresses:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    kubectl get ingress -n apps 2>/dev/null || echo "No ingresses found"
}

# Scale applications
scale_apps() {
    echo ""
    echo -e "${BLUE}⚖️  Scale Applications${NC}"
    echo ""
    echo "Select scaling profile:"
    echo "  1) Development (8 pods, ~400m CPU, ~512Mi RAM)"
    echo "  2) Production-Lite (10 pods, ~800m CPU, ~1280Mi RAM)"
    echo "  3) Production (16 pods, ~2100m CPU, ~2688Mi RAM)"
    echo "  4) Custom"
    echo ""
    read -p "Select profile (1-4): " PROFILE
    
    case $PROFILE in
        1)
            echo "Scaling to Development profile..."
            kubectl scale deployment -n apps task-management --replicas=1 2>/dev/null
            kubectl scale deployment -n apps k8s-deploy-test --replicas=1 2>/dev/null
            kubectl scale deployment -n apps tca-infraforge-backend --replicas=1 2>/dev/null
            kubectl scale deployment -n apps tca-infraforge-frontend --replicas=1 2>/dev/null
            kubectl scale deployment -n apps personal-vault --replicas=1 2>/dev/null
            kubectl scale deployment -n apps ecommerce-app --replicas=1 2>/dev/null
            ;;
        2)
            echo "Scaling to Production-Lite profile..."
            kubectl scale deployment -n apps task-management --replicas=2 2>/dev/null
            kubectl scale deployment -n apps k8s-deploy-test --replicas=1 2>/dev/null
            kubectl scale deployment -n apps tca-infraforge-backend --replicas=2 2>/dev/null
            kubectl scale deployment -n apps tca-infraforge-frontend --replicas=2 2>/dev/null
            kubectl scale deployment -n apps personal-vault --replicas=1 2>/dev/null
            kubectl scale deployment -n apps ecommerce-app --replicas=2 2>/dev/null
            ;;
        3)
            echo "Scaling to Production profile..."
            kubectl scale deployment -n apps task-management --replicas=3 2>/dev/null
            kubectl scale deployment -n apps k8s-deploy-test --replicas=2 2>/dev/null
            kubectl scale deployment -n apps tca-infraforge-backend --replicas=3 2>/dev/null
            kubectl scale deployment -n apps tca-infraforge-frontend --replicas=3 2>/dev/null
            kubectl scale deployment -n apps personal-vault --replicas=2 2>/dev/null
            kubectl scale deployment -n apps ecommerce-app --replicas=3 2>/dev/null
            ;;
        4)
            read -p "Enter replica count for all apps: " REPLICAS
            echo "Scaling all apps to $REPLICAS replicas..."
            for app in task-management k8s-deploy-test tca-infraforge-backend tca-infraforge-frontend personal-vault ecommerce-app; do
                kubectl scale deployment -n apps $app --replicas=$REPLICAS 2>/dev/null
            done
            ;;
        *)
            echo -e "${RED}Invalid selection${NC}"
            return
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ Scaling complete${NC}"
    echo ""
    sleep 2
    kubectl get pods -n apps
}

# Update /etc/hosts
update_hosts() {
    echo ""
    echo -e "${BLUE}🌐 Update /etc/hosts${NC}"
    echo ""
    echo "This will add local DNS entries for application access."
    echo ""
    echo "Entries to add:"
    echo "  127.0.0.1  task-management.local"
    echo "  127.0.0.1  k8s-test.local"
    echo "  127.0.0.1  tca-infraforge.local"
    echo "  127.0.0.1  vault.local"
    echo "  127.0.0.1  ecommerce.local"
    echo ""
    read -p "Add these entries? (y/N): " CONFIRM
    
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo ""
        echo "127.0.0.1  task-management.local k8s-test.local tca-infraforge.local vault.local ecommerce.local" | sudo tee -a /etc/hosts > /dev/null
        echo -e "${GREEN}✅ /etc/hosts updated${NC}"
    else
        echo "Skipped."
    fi
}

# View URLs
view_urls() {
    echo ""
    echo -e "${BLUE}🌐 Application URLs${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Via Ingress (requires /etc/hosts):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Task Management:  http://task-management.local"
    echo "  K8s Deploy Test:  http://k8s-test.local"
    echo "  TCA InfraForge:   http://tca-infraforge.local"
    echo "  Personal Vault:   http://vault.local"
    echo "  Ecommerce:        http://ecommerce.local"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Via Port-Forward:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  kubectl port-forward -n apps svc/task-management 3000:3000"
    echo "  kubectl port-forward -n apps svc/k8s-deploy-test 8080:8080"
    echo "  kubectl port-forward -n apps svc/tca-infraforge-frontend 8081:80"
    echo "  kubectl port-forward -n apps svc/tca-infraforge-backend 3001:3000"
    echo "  kubectl port-forward -n apps svc/personal-vault 3002:3000"
    echo "  kubectl port-forward -n apps svc/ecommerce-app 3003:3000"
}

# Open ArgoCD
open_argocd() {
    echo ""
    echo -e "${BLUE}🔗 Opening ArgoCD UI${NC}"
    echo ""
    
    echo "Starting port-forward..."
    kubectl port-forward -n argocd svc/argocd-server 8080:80 &
    PF_PID=$!
    
    sleep 2
    
    echo ""
    echo "Getting admin password..."
    PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ArgoCD Access:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "URL:      http://localhost:8080"
    echo "Username: admin"
    echo "Password: $PASSWORD"
    echo ""
    
    read -p "Open in browser? (y/N): " OPEN
    if [[ "$OPEN" =~ ^[Yy]$ ]]; then
        open http://localhost:8080
    fi
    
    echo ""
    echo "Port-forward running (PID: $PF_PID)"
    echo "Press Enter to stop port-forward..."
    read
    kill $PF_PID 2>/dev/null
}

# Open Grafana
open_grafana() {
    echo ""
    echo -e "${BLUE}📊 Opening Grafana${NC}"
    echo ""
    
    echo "Starting port-forward..."
    kubectl port-forward -n monitoring svc/grafana 3000:3000 &
    PF_PID=$!
    
    sleep 2
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Grafana Access:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "URL:      http://localhost:3000"
    echo "Username: admin"
    echo "Dashboard: Kubernetes Cluster #315"
    echo ""
    
    read -p "Open in browser? (y/N): " OPEN
    if [[ "$OPEN" =~ ^[Yy]$ ]]; then
        open http://localhost:3000
    fi
    
    echo ""
    echo "Port-forward running (PID: $PF_PID)"
    echo "Press Enter to stop port-forward..."
    read
    kill $PF_PID 2>/dev/null
}

# View documentation
view_docs() {
    echo ""
    echo -e "${BLUE}📚 Documentation${NC}"
    echo ""
    echo "Available documentation:"
    echo "  1) README.md - Overview and quick start"
    echo "  2) DEPLOYMENT-GUIDE.md - Step-by-step deployment"
    echo "  3) ARGOCD-SETUP.md - ArgoCD integration"
    echo "  4) values.yaml - Configuration values"
    echo "  5) APPLICATION-MANIFESTS-COMPLETE.md - Summary"
    echo ""
    read -p "Select document (1-5): " DOC_NUM
    
    case $DOC_NUM in
        1) DOC="README.md" ;;
        2) DOC="DEPLOYMENT-GUIDE.md" ;;
        3) DOC="ARGOCD-SETUP.md" ;;
        4) DOC="values.yaml" ;;
        5) DOC="APPLICATION-MANIFESTS-COMPLETE.md" ;;
        *)
            echo -e "${RED}Invalid selection${NC}"
            return
            ;;
    esac
    
    echo ""
    if command -v bat &> /dev/null; then
        bat "$MANIFESTS_DIR/$DOC"
    elif command -v less &> /dev/null; then
        less "$MANIFESTS_DIR/$DOC"
    else
        cat "$MANIFESTS_DIR/$DOC"
    fi
}

# Main loop
while true; do
    show_menu
    read CHOICE
    
    case $CHOICE in
        1) update_git_urls ;;
        2) verify_structure ;;
        3) test_syntax ;;
        4) deploy_all ;;
        5) deploy_individual ;;
        6) check_status ;;
        7) scale_apps ;;
        8) update_hosts ;;
        9) view_urls ;;
        10) open_argocd ;;
        11) open_grafana ;;
        12) view_docs ;;
        0)
            echo ""
            echo -e "${GREEN}👋 Goodbye!${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
