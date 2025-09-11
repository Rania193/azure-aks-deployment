# Azure AKS Microservice (Terraform + GitHub OIDC + Helm Monitoring)

Deploy a Flask API (two endpoints: `/products`, `/users`) to **Azure Kubernetes Service (AKS)**.  
Infra is provisioned with **Terraform**, CI/CD is via **GitHub Actions** using **OIDC** (no client secrets).  
Monitoring is installed with Helm (Prometheus + Grafana), then a `ServiceMonitor` is applied.

----
## Tech Stack

- **Terraform**
    
- **Azure AKS + ACR**
    
- **GitHub Actions**
    
- **Docker**
    
- **Kubernetes**

- **Prometheus & Grafana** 

----
## Prereqs

- **Azure** CLI logged in to the right subscription:
    
    ```bash
    az login
    az account set --subscription "<SUBSCRIPTION_ID>"
    ```
    
- **Terraform** ≥ 1.6
    
- **kubectl** & **Helm**

----
## 1) Provision Azure (Terraform)

From `terraform/`:

```bash
terraform init
terraform apply
```

What it does:

- Creates RG, ACR, AKS
    
- Grants:
    
    - `AcrPull` → AKS kubelet identity
        
    - `AcrPush` + `AKS RBAC Cluster Admin` + `AKS Cluster User` → GitHub OIDC identity
        
- Mints an Entra App/SP + Federated Identity Credential (via `modules/github_oidc`)

----
## 2) Configure GitHub repo secrets/vars

In **GitHub → Settings → Secrets and variables → Actions**:

- `AZURE_CLIENT_ID` – the App ID output by Terraform (from the OIDC module)
    
- `AZURE_TENANT_ID`
    
- `AZURE_SUBSCRIPTION_ID`
    
- `AKS_RESOURCE_GROUP` – e.g., `rg-microservices`
    
- `AKS_CLUSTER_NAME` – e.g., `aks-microservices`
    
- `ACR_NAME` – e.g., `acrmsvc012345`
    
- `ACR_LOGIN_SERVER` – e.g., `acrmsvc012345.azurecr.io`
    
----
## 3) Deploy the app (GitHub Actions)

Push to `main` (or run the workflow manually). The pipeline will:

1. OIDC login to Azure
    
2. `az acr login` to ACR
    
3. Build image and push
        
4. Set AKS context using **Azure RBAC**
    
5. `kubectl apply -f k8s/`
    
6. Update the Deployment to the new SHA image
    
7. Wait for rollout & print the Service external IP

----
## 4) Install Monitoring

We install **kube-prometheus-stack**, then apply a `ServiceMonitor` to scrape the app.

```bash
kubectl apply -f monitoring/namespace.yaml

# Install/upgrade the chart
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace --wait \
  -f monitoring/values-monitoring.yaml
```

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
# Grafana → http://localhost:3000
# Default user: admin ; password: 
kubectl -n monitoring get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo
```

```bash
kubectl apply -f monitoring/servicemonitor.yaml
```

----
## 5) Clean up

```bash
# Destroy Azure resources
cd terraform
terraform destroy -auto-approve
```

----
## Results
![Image Name](assets/Screenshot%202025-09-06%20at%205.56.55 PM.png)

![Image Name](assets/Screenshot%202025-09-06%20at%205.57.18 PM.png)

![Image Name](assets/Screenshot%202025-09-06%20at%206.00.58 PM.png)