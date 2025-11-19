# 🚀 CODE CATALYST - GITHUB DEPLOYMENT COMMANDS

## Step 1: Initialize Git Repository

```powershell
# Navigate to code-catalyst directory
cd c:\Users\VICTOR MORALES\Documents\WealthBridge\code-catalyst

# Initialize git
git init

# Add all files
git add .

# Initial commit
git commit -m "Initial Code Catalyst launch - Ready for production

- FastAPI backend with 7 core endpoints
- Twilio SMS/Voice integration (5 endpoints)
- CLI tool with Typer framework
- Docker containerization (FastAPI + Redis + MongoDB)
- Configuration management with .env.local support
- GitHub App webhook integration
- SIMA2Agent bridge for WealthBridge orchestration
- Company info configured: Influwealth Consult LLC
- Support email: support@influwealth.com"
```

## Step 2: Create GitHub Repository (OPTION A - via GitHub CLI)

```powershell
# Prerequisites: GitHub CLI installed (https://cli.github.com/)
# Ensure you're logged in: gh auth login

# Create public repository in Influwealth organization
gh repo create code-catalyst-influwealth `
  --public `
  --source=. `
  --remote=origin `
  --push `
  --description "Code Catalyst: AI-powered coding agent for Influwealth. Supports Dart, Solidity, JavaScript. Integrated with WealthBridge ecosystem." `
  --homepage "https://influwealth.wixsite.com/influwealth-consult" `
  --org Influwealth
```

## Step 3: Create GitHub Repository (OPTION B - Manual)

```powershell
# If GitHub CLI not available:

# 1. Go to https://github.com/organizations/Influwealth/repositories
# 2. Click "New repository"
# 3. Set name: code-catalyst-influwealth
# 4. Set public visibility
# 5. Add description:
#    "Code Catalyst: AI-powered coding agent for Influwealth"
# 6. Click "Create repository"
# 7. Then run:

git remote add origin https://github.com/Influwealth/code-catalyst-influwealth.git
git branch -M main
git push -u origin main
```

## Step 4: Add GitHub App Configuration

After repository is created:

1. Go to https://github.com/settings/apps
2. Click "New GitHub App"
3. Fill in:
   - **App name**: code-catalyst-influwealth
   - **Homepage URL**: https://influwealth.wixsite.com/influwealth-consult
   - **Webhook URL**: https://YOUR_LINODE_IP:8001/api/webhook
   - **Webhook secret**: Generate random string, add to .env.local as GITHUB_WEBHOOK_SECRET

4. Under "Permissions":
   - Contents: Read
   - Issues: Read & write
   - Pull requests: Read & write
   - Commit statuses: Read & write

5. Under "Subscribe to events":
   - Push
   - Pull request
   - Issues

6. Click "Create GitHub App"

7. Copy:
   - App ID → GITHUB_APP_ID in .env.local
   - Private key (PEM) → GITHUB_PRIVATE_KEY in .env.local

## Step 5: Verify Deployment

```powershell
# Confirm repository created
gh repo view Influwealth/code-catalyst-influwealth

# Confirm files pushed
gh repo clone Influwealth/code-catalyst-influwealth code-catalyst-test
cd code-catalyst-test
git log --oneline
```

## Step 6: Docker Build & Push (Optional - for Container Registry)

```powershell
# Build image
docker build -t influwealth/code-catalyst:v1.0 -f backend/Dockerfile ./backend

# If using Docker Hub registry:
# docker login
# docker tag influwealth/code-catalyst:v1.0 YOUR_REGISTRY/code-catalyst:v1.0
# docker push YOUR_REGISTRY/code-catalyst:v1.0
```

---

## 🎯 Summary of Deployed Artifacts

✅ **GitHub Repository**: https://github.com/Influwealth/code-catalyst-influwealth  
✅ **FastAPI Backend**: 7 core endpoints + 5 Twilio endpoints  
✅ **CLI Tool**: codecatalyst-cli.py (ready to use)  
✅ **Docker Stack**: FastAPI + Redis + MongoDB (docker-compose.yml)  
✅ **Configuration**: .env.example template with all credentials  
✅ **Documentation**: LAUNCH_TODAY.md with examples  
✅ **GitHub App**: Ready to create (guide above)  
✅ **Credentials**: All mapped in config.py  

---

## 🔗 Related Resources

- **WealthBridge**: 38 Dart capsules, SIMA2Agent orchestration
- **Polygon**: Smart contract deployment (Mumbai testnet)
- **Stripe Treasury**: AP2 affiliate payout system
- **Influwealth Website**: https://influwealth.wixsite.com/influwealth-consult
- **Support**: support@influwealth.com

---

**Deployment Status**: ✅ READY  
**Launch Date**: November 16, 2025  
**Contact**: Victor Morales (User)

---

Run these commands now to go LIVE! 🚀
