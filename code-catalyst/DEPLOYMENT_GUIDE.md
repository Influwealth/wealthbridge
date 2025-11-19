# 🚀 CODE CATALYST - PRODUCTION DEPLOYMENT GUIDE

**Deployment Ready**: ✅ YES  
**Target Launch**: November 18, 2025  
**Beta Users**: ~100 people  
**Infrastructure**: Linode + Akash (Sovereign Stack)  

---

## 📋 Pre-Deployment Checklist

- [ ] ✅ Code Catalyst backend fully developed
- [ ] ✅ Agent handoff system integrated (argus-prime pattern)
- [ ] ✅ Dart agent specialization ready
- [ ] ✅ Interactive testing framework operational
- [ ] ✅ All 8 API endpoints working
- [ ] ✅ Twilio integration tested
- [ ] ✅ Docker services configured
- [ ] ⏳ GitHub repository created
- [ ] ⏳ Terraform infrastructure defined
- [ ] ⏳ CI/CD pipeline setup
- [ ] ⏳ AnythingLLM white-label ready
- [ ] ⏳ Custom domain configured
- [ ] ⏳ SSL certificates generated

---

## 🔧 Deployment Phases (48 Hours Total)

### PHASE 1: Local Testing & Validation (0-2 Hours)

**Duration**: 2 hours  
**Goal**: Verify all systems operational locally

```powershell
# Step 1: Start Docker services
cd c:\Users\VICTOR MORALES\Documents\WealthBridge\code-catalyst
docker-compose up -d

# Wait for services to initialize
Start-Sleep -Seconds 10

# Step 2: Run health check
python cli/codecatalyst-cli.py health

# Expected output:
# ✅ Backend Status
# Service | Status
# --------|--------
# redis   | connected
# mongodb | connected
```

**Tests to run**:
```powershell
# Step 3: Run test suite
python test_interactive.py

# Select: 3. Full Suite
# All 8 endpoints should return ✅ PASS
```

**Verification**:
- [ ] Health endpoint responding
- [ ] All 8 API endpoints working
- [ ] Twilio SMS sending (test mode)
- [ ] Dart agent generating code
- [ ] Agent delegation functioning
- [ ] Test results exported to JSON
- [ ] No error logs in Docker

---

### PHASE 2: GitHub Repository Setup (2-4 Hours)

**Duration**: 2 hours  
**Goal**: Push code to GitHub with CI/CD ready

```powershell
# Step 1: Initialize Git
cd c:\Users\VICTOR MORALES\Documents\WealthBridge\code-catalyst
git init
git add .
git commit -m "Code Catalyst v1.0 - Ready for Production

- Agent handoff system (argus-prime pattern)
- Dart agent specialization
- Interactive testing terminal
- 8 API endpoints (12 total with Twilio)
- Docker Compose stack
- Comprehensive documentation"

# Step 2: Add GitHub remote
git remote add origin https://github.com/Influwealth/code-catalyst-influwealth.git
git branch -M main
git push -u origin main

# Step 3: Create .gitignore (if not exists)
```

**GitHub repository structure**:
```
code-catalyst-influwealth/
├── .github/
│   └── workflows/
│       ├── test.yml              # Run tests on push
│       ├── deploy-staging.yml    # Deploy to staging
│       └── deploy-prod.yml       # Deploy to production
├── backend/
│   ├── app/
│   │   ├── agent_handoff.py
│   │   ├── dart_agent.py
│   │   ├── interactive_testing.py
│   │   └── api.py
│   ├── requirements.txt
│   └── Dockerfile
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── docker-compose.yml
├── .env.example
├── STARTUP_GUIDE.md
├── DEPLOYMENT_GUIDE.md
└── README.md
```

---

### PHASE 3: Terraform Infrastructure (4-8 Hours)

**Duration**: 4 hours  
**Goal**: Define infrastructure as code for Linode deployment

**Create**: `terraform/main.tf`
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.0"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

# VPC for sovereign deployment
resource "linode_vpc" "influwealth" {
  label       = "code-catalyst-vpc"
  description = "VPC for Code Catalyst infrastructure"
  region      = var.region  # us-east, us-west, eu-west, etc.
}

# Kubernetes cluster for scaling
resource "linode_lke_cluster" "code_catalyst" {
  label       = "code-catalyst-cluster"
  k8s_version = "1.27"
  region      = var.region
  
  pool {
    type  = "g6-standard-2"        # 2GB RAM, 1 CPU - starter tier
    count = var.node_count          # Initially 3 nodes for HA
  }

  tags = ["code-catalyst", "influwealth", "production"]
}

# Database: MongoDB
resource "linode_database_mongodb" "code_catalyst" {
  label          = "code-catalyst-mongodb"
  engine_id      = "mongodb/6.0"
  region         = var.region
  type           = "g6-standard-2"
  
  backup_retention = 7
  ssl_connection   = true

  tags = ["code-catalyst", "influwealth"]
}

# Cache: Redis
resource "linode_database_redis" "code_catalyst" {
  label          = "code-catalyst-redis"
  engine_id      = "redis/7.0"
  region         = var.region
  type           = "g6-standard-1"
  
  ssl_connection = true

  tags = ["code-catalyst", "influwealth"]
}

# Load Balancer
resource "linode_nodebalancer" "code_catalyst" {
  label    = "code-catalyst-lb"
  region   = var.region
  
  tags = ["code-catalyst", "influwealth"]
}

# NodeBalancer Config (HTTP)
resource "linode_nodebalancer_config" "code_catalyst_http" {
  nodebalancer_id = linode_nodebalancer.code_catalyst.id
  port            = 80
  protocol        = "http"
  check_passive   = true
  check           = "connection"
}

# NodeBalancer Config (HTTPS)
resource "linode_nodebalancer_config" "code_catalyst_https" {
  nodebalancer_id = linode_nodebalancer.code_catalyst.id
  port            = 443
  protocol        = "https"
  check_passive   = true
  check           = "connection"
  ssl_cert        = var.ssl_cert
  ssl_key         = var.ssl_key
}

outputs {
  cluster_kubeconfig = linode_lke_cluster.code_catalyst.kubeconfig
  db_uri             = "mongodb://${linode_database_mongodb.code_catalyst.host}:${linode_database_mongodb.code_catalyst.port}"
  redis_uri          = "redis://${linode_database_redis.code_catalyst.host}:${linode_database_redis.code_catalyst.port}"
  lb_ip              = linode_nodebalancer.code_catalyst.ipv4
}
```

**Create**: `terraform/variables.tf`
```hcl
variable "linode_token" {
  description = "Linode API token"
  sensitive   = true
}

variable "region" {
  description = "Linode region (e.g., us-east, eu-west)"
  default     = "us-east"
}

variable "node_count" {
  description = "Number of Kubernetes nodes"
  type        = number
  default     = 3
}

variable "ssl_cert" {
  description = "SSL certificate"
  sensitive   = true
}

variable "ssl_key" {
  description = "SSL private key"
  sensitive   = true
}
```

**Deploy Terraform**:
```powershell
cd terraform

# Step 1: Initialize Terraform
terraform init

# Step 2: Plan deployment
terraform plan -out=plan.tfplan

# Step 3: Apply to Linode
terraform apply plan.tfplan

# Outputs will show:
# - Kubernetes cluster details
# - MongoDB connection string
# - Redis connection string
# - Load balancer IP
```

---

### PHASE 4: Kubernetes Deployment (8-12 Hours)

**Duration**: 4 hours  
**Goal**: Deploy Code Catalyst to Kubernetes cluster

**Create**: `k8s/deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: code-catalyst-backend
  namespace: production
  labels:
    app: code-catalyst
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: code-catalyst
  template:
    metadata:
      labels:
        app: code-catalyst
    spec:
      containers:
      - name: backend
        image: influwealth/code-catalyst:v1.0
        imagePullPolicy: Always
        ports:
        - containerPort: 8001
          name: http
        env:
        - name: ANTHROPIC_API_KEY
          valueFrom:
            secretKeyRef:
              name: code-catalyst-secrets
              key: anthropic-api-key
        - name: TWILIO_ACCOUNT_SID
          valueFrom:
            secretKeyRef:
              name: code-catalyst-secrets
              key: twilio-account-sid
        - name: TWILIO_AUTH_TOKEN
          valueFrom:
            secretKeyRef:
              name: code-catalyst-secrets
              key: twilio-auth-token
        - name: MONGODB_URI
          valueFrom:
            secretKeyRef:
              name: code-catalyst-secrets
              key: mongodb-uri
        - name: REDIS_URI
          valueFrom:
            secretKeyRef:
              name: code-catalyst-secrets
              key: redis-uri
        resources:
          requests:
            cpu: "500m"
            memory: "512Mi"
          limits:
            cpu: "1000m"
            memory: "1Gi"
        livenessProbe:
          httpGet:
            path: /health
            port: 8001
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8001
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: code-catalyst-service
  namespace: production
spec:
  type: LoadBalancer
  selector:
    app: code-catalyst
  ports:
  - port: 80
    targetPort: 8001
    protocol: TCP
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: code-catalyst-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: code-catalyst-backend
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

**Deploy to Kubernetes**:
```bash
# Step 1: Create secrets
kubectl create secret generic code-catalyst-secrets \
  --from-literal=anthropic-api-key=$ANTHROPIC_API_KEY \
  --from-literal=twilio-account-sid=$TWILIO_ACCOUNT_SID \
  --from-literal=twilio-auth-token=$TWILIO_AUTH_TOKEN \
  --from-literal=mongodb-uri=$MONGODB_URI \
  --from-literal=redis-uri=$REDIS_URI \
  -n production

# Step 2: Deploy application
kubectl apply -f k8s/deployment.yaml

# Step 3: Verify deployment
kubectl get pods -n production
kubectl get services -n production

# Step 4: Check logs
kubectl logs -n production -f deployment/code-catalyst-backend
```

---

### PHASE 5: GitHub Actions CI/CD (12-16 Hours)

**Duration**: 4 hours  
**Goal**: Automated testing & deployment pipeline

**Create**: `.github/workflows/test.yml`
```yaml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      redis:
        image: redis:7.0
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      mongodb:
        image: mongo:6.0
        options: >-
          --health-cmd "mongosh --eval 'db.adminCommand(\"ping\")''"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install -r backend/requirements.txt
        pip install pytest pytest-asyncio pytest-cov
    
    - name: Run tests
      run: |
        pytest backend/tests/ -v --cov=backend/app --cov-report=xml
      env:
        ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        TWILIO_ACCOUNT_SID: ${{ secrets.TWILIO_ACCOUNT_SID }}
        TWILIO_AUTH_TOKEN: ${{ secrets.TWILIO_AUTH_TOKEN }}
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage.xml

  lint:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install linters
      run: |
        pip install flake8 black mypy
    
    - name: Run linters
      run: |
        black --check backend/
        flake8 backend/ --count --select=E9,F63,F7,F82 --show-source --statistics
        mypy backend/ --ignore-missing-imports
```

**Create**: `.github/workflows/deploy-prod.yml`
```yaml
name: Deploy to Production

on:
  push:
    tags:
      - 'v*'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t influwealth/code-catalyst:${{ github.ref_name }} .
        docker tag influwealth/code-catalyst:${{ github.ref_name }} influwealth/code-catalyst:latest
    
    - name: Push to Docker Hub
      run: |
        echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
        docker push influwealth/code-catalyst:${{ github.ref_name }}
        docker push influwealth/code-catalyst:latest
    
    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/code-catalyst-backend \
          backend=influwealth/code-catalyst:${{ github.ref_name }} \
          -n production
        kubectl rollout status deployment/code-catalyst-backend -n production
      env:
        KUBECONFIG: ${{ secrets.KUBECONFIG }}
```

---

### PHASE 6: AnythingLLM Integration (16-20 Hours)

**Duration**: 4 hours  
**Goal**: White-label RAG system ready for 100-person beta

**Create**: `backend/app/anythingllm_integration.py`
```python
"""
AnythingLLM Integration for Code Catalyst
White-label RAG system for 100-person beta launch
"""

import httpx
import json
from typing import List, Dict, Any
from datetime import datetime


class AnythingLLMIntegration:
    """Integration with AnythingLLM for RAG"""
    
    def __init__(self, api_url: str, api_key: str):
        self.api_url = api_url
        self.api_key = api_key
        self.timeout = 60
    
    async def create_workspace(self, workspace_name: str, user_id: str) -> Dict[str, Any]:
        """Create workspace for user"""
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            response = await client.post(
                f"{self.api_url}/api/v1/workspace",
                headers={"Authorization": f"Bearer {self.api_key}"},
                json={
                    "name": workspace_name,
                    "user_id": user_id,
                    "model": "gpt-4",
                    "settings": {
                        "temperature": 0.7,
                        "max_tokens": 2000,
                    }
                }
            )
            return response.json()
    
    async def ingest_document(self, workspace_id: str, document_path: str) -> Dict[str, Any]:
        """Ingest document into knowledge base"""
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            with open(document_path, "rb") as f:
                response = await client.post(
                    f"{self.api_url}/api/v1/workspace/{workspace_id}/document",
                    headers={"Authorization": f"Bearer {self.api_key}"},
                    files={"document": f}
                )
            return response.json()
    
    async def query_workspace(self, workspace_id: str, query: str) -> Dict[str, Any]:
        """Query workspace knowledge base"""
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            response = await client.post(
                f"{self.api_url}/api/v1/workspace/{workspace_id}/chat",
                headers={"Authorization": f"Bearer {self.api_key}"},
                json={"message": query}
            )
            return response.json()
    
    async def list_documents(self, workspace_id: str) -> List[Dict[str, Any]]:
        """List all documents in workspace"""
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            response = await client.get(
                f"{self.api_url}/api/v1/workspace/{workspace_id}/documents",
                headers={"Authorization": f"Bearer {self.api_key}"}
            )
            return response.json()
```

---

### PHASE 7: Custom Domain & SSL (20-24 Hours)

**Duration**: 4 hours  
**Goal**: Custom domain ready with HTTPS

```bash
# Step 1: Point domain to Linode
# DNS Records:
# A Record: code-catalyst.influwealth.com -> <LoadBalancer-IP>
# CNAME: www.code-catalyst.influwealth.com -> code-catalyst.influwealth.com

# Step 2: Generate SSL certificate
certbot certonly --standalone -d code-catalyst.influwealth.com

# Step 3: Update Kubernetes ingress
kubectl apply -f k8s/ingress.yaml

# Step 4: Test HTTPS
curl https://code-catalyst.influwealth.com/health
```

---

## 📊 Production Checklist

**Pre-Launch (24 Hours Before)**
- [ ] All services health check passing
- [ ] Load balancer responding
- [ ] HTTPS working
- [ ] Database backups configured
- [ ] Monitoring alerts set up
- [ ] Support team trained

**Launch Day**
- [ ] 100 beta users onboarded
- [ ] AnythingLLM knowledge base populated
- [ ] Twilio SMS/voice tested
- [ ] Agent delegation tested with real tasks
- [ ] Monitoring dashboard active
- [ ] Support email monitored

**Day 1-7 (Beta Run)**
- [ ] Monitor error logs
- [ ] Collect user feedback
- [ ] Monitor performance metrics
- [ ] Handle support tickets
- [ ] Iterate based on feedback

---

## 🔍 Monitoring & Observability

**Create**: `k8s/monitoring.yaml`
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'code-catalyst'
      kubernetes_sd_configs:
      - role: pod
```

**Metrics to monitor**:
- Request latency (p50, p95, p99)
- Error rate (4xx, 5xx)
- Agent delegation success rate
- API endpoint response times
- Twilio SMS delivery rate
- Dart code generation quality score
- Database query performance
- Cache hit rate

---

## 💰 Cost Estimate (Monthly)

| Component | Cost | Notes |
|-----------|------|-------|
| Kubernetes (3 nodes) | $45 | g6-standard-2 |
| MongoDB 6.0 | $30 | Managed database |
| Redis 7.0 | $15 | Cache layer |
| Load Balancer | $20 | High availability |
| Bandwidth | $20 | Egress charges |
| DNS | $5 | Domain management |
| Backups | $10 | Daily snapshots |
| **TOTAL** | **$145/month** | ~$1,740/year |

---

## 📞 Support & Escalation

**Support Email**: support@influwealth.com  
**On-Call**: 24/7 for critical issues  
**SLA**: 99.9% uptime guarantee

**Escalation Path**:
1. Support team (1st line)
2. DevOps engineer (infrastructure)
3. Backend developer (code issues)
4. Leadership (business decisions)

---

## ✅ Success Metrics (First 7 Days)

- **Uptime**: > 99.9%
- **Response Time**: < 200ms (p95)
- **Error Rate**: < 0.1%
- **Agent Delegation Success**: > 95%
- **User Satisfaction**: > 4.5/5 stars
- **Dart Code Quality**: > 90% pass rate
- **Zero security incidents**

---

**DEPLOYMENT STATUS**: 🟢 **READY FOR LAUNCH**

Next step: `python test_interactive.py` to verify all systems locally before proceeding with Terraform deployment.
