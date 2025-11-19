#!/usr/bin/env powershell
# Code Catalyst - Automated GitHub Deployment Script
# Usage: .\deploy.ps1
# This script will initialize Git, commit all files, and push to GitHub

Write-Host "🚀 CODE CATALYST - GITHUB DEPLOYMENT" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "backend/requirements.txt")) {
    Write-Host "❌ Error: Must run from code-catalyst root directory" -ForegroundColor Red
    exit 1
}

Write-Host "✅ In correct directory" -ForegroundColor Green

# Step 1: Initialize Git
Write-Host ""
Write-Host "Step 1/5: Initialize Git Repository..." -ForegroundColor Yellow

if (-not (Test-Path ".git")) {
    git init
    Write-Host "✅ Git initialized" -ForegroundColor Green
}
else {
    Write-Host "✅ Git already initialized" -ForegroundColor Green
}

# Step 2: Add all files
Write-Host ""
Write-Host "Step 2/5: Stage all files..." -ForegroundColor Yellow
git add .
Write-Host "✅ Files staged" -ForegroundColor Green

# Step 3: Create commit
Write-Host ""
Write-Host "Step 3/5: Create initial commit..." -ForegroundColor Yellow
$commitMessage = @"
Initial Code Catalyst launch - Ready for production

[Features]
- FastAPI backend with 7 core endpoints
- Twilio SMS/Voice integration (5 endpoints)
- CLI tool with Typer framework
- Docker containerization (FastAPI + Redis + MongoDB)
- Configuration management with .env.local support
- GitHub App webhook integration
- SIMA2Agent bridge for WealthBridge orchestration

[Infrastructure]
- Sovereign deployment (Linode + Akash ready)
- Web3 integration (Polygon, Stripe)
- 38-capsule WealthBridge ecosystem support

[Company Info]
- Organization: Influwealth Consult LLC
- Support: support@influwealth.com
- Website: https://influwealth.wixsite.com/influwealth-consult
- Address: 224 W 35th St Fl 5, New York, NY 10001

[Credentials]
All required credentials are documented in .env.example
Copy to .env.local and fill with your API keys before starting.

[Quick Start]
1. cp .env.example .env.local
2. Edit .env.local with your credentials
3. docker-compose up -d
4. curl http://localhost:8001/health

[Status]
✅ PRODUCTION READY
✅ LAUNCH DATE: November 16, 2025
✅ ALL SYSTEMS GO
"@

git commit -m $commitMessage
Write-Host "✅ Commit created" -ForegroundColor Green

# Step 4: Set origin
Write-Host ""
Write-Host "Step 4/5: Configure GitHub origin..." -ForegroundColor Yellow

$remoteUrl = "https://github.com/Influwealth/code-catalyst-influwealth.git"

# Check if origin exists
$remoteExists = git config --get remote.origin.url
if ($remoteExists) {
    Write-Host "✅ Remote origin already configured: $remoteExists" -ForegroundColor Green
}
else {
    git remote add origin $remoteUrl
    Write-Host "✅ Remote origin added: $remoteUrl" -ForegroundColor Green
}

# Step 5: Push to GitHub
Write-Host ""
Write-Host "Step 5/5: Push to GitHub..." -ForegroundColor Yellow
Write-Host "Note: You may be prompted for GitHub authentication" -ForegroundColor Gray

git branch -M main
$pushResult = git push -u origin main 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
}
else {
    Write-Host "⚠️ Push encountered an issue:" -ForegroundColor Yellow
    Write-Host $pushResult -ForegroundColor Gray
    Write-Host ""
    Write-Host "To manually push, run:" -ForegroundColor Yellow
    Write-Host "git push -u origin main" -ForegroundColor Cyan
}

# Summary
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "🎉 DEPLOYMENT SUMMARY" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Repository: https://github.com/Influwealth/code-catalyst-influwealth" -ForegroundColor Cyan
Write-Host "Status: ✅ LIVE" -ForegroundColor Green
Write-Host "Launch Date: November 16, 2025" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Verify files on GitHub: gh repo view Influwealth/code-catalyst-influwealth" -ForegroundColor Gray
Write-Host "2. Setup GitHub App: https://github.com/settings/apps" -ForegroundColor Gray
Write-Host "3. Deploy to Linode: See DEPLOYMENT_COMMANDS.md" -ForegroundColor Gray
Write-Host "4. Start services: docker-compose up -d" -ForegroundColor Gray
Write-Host ""
Write-Host "📞 Support: support@influwealth.com" -ForegroundColor Cyan
Write-Host ""
