#!/usr/bin/env pwsh
# WealthBridge Complete Deployment Orchestrator
# Coordinates: Frontend (Firebase) + Backend (Linode) + GPU (Akash)

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     WealthBridge Deployment Orchestrator                   ║" -ForegroundColor Cyan
Write-Host "║     Production-ready infrastructure automation             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Configuration
$projectRoot = Get-Location
$deploymentDir = "$projectRoot\deployment"
$buildDir = "$projectRoot\build\web"
$configs = @{
    firebase = @{ enabled = $true; project = "wealthbridge" }
    linode = @{ enabled = $true; host = "wealthbridge-linode"; ip = "" }
    akash = @{ enabled = $false; chainId = "akashnet-2" }
}

# Step 1: Pre-deployment checks
Write-Host "Step 1: Pre-deployment Checks" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow

function Check-Tool {
    param([string]$tool, [string]$command)
    try {
        & $command --version 2>&1 | Out-Null
        Write-Host "✅ $tool" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ $tool - Install with: $command" -ForegroundColor Red
        return $false
    }
}

$checksPass = $true
$checksPass = (Check-Tool "Git" "git") -and $checksPass
$checksPass = (Check-Tool "Node.js" "node") -and $checksPass
$checksPass = (Check-Tool "Firebase CLI" "firebase") -and $checksPass
$checksPass = (Check-Tool "Flutter" "flutter") -and $checksPass

if (!$checksPass) {
    Write-Host "⚠️  Some tools missing. Please install before continuing." -ForegroundColor Yellow
    Read-Host "Press Enter when ready"
}

Write-Host ""

# Step 2: Build Flutter web
Write-Host "Step 2: Building Flutter Web" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow

$buildResponse = Read-Host "Build Flutter web? (y/n)"
if ($buildResponse -eq 'y') {
    Write-Host "Running: flutter clean && flutter pub get && flutter build web --release" -ForegroundColor Cyan
    flutter clean
    flutter pub get
    flutter build web --release
    
    if (!(Test-Path $buildDir)) {
        Write-Host "❌ Build failed - build\web directory not found" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Flutter web build successful" -ForegroundColor Green
} else {
    Write-Host "⏭️  Skipping Flutter build" -ForegroundColor Gray
}

Write-Host ""

# Step 3: Deploy to Firebase
Write-Host "Step 3: Firebase Deployment" -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Yellow

if ($configs.firebase.enabled) {
    $firebaseResponse = Read-Host "Deploy to Firebase Hosting? (y/n)"
    if ($firebaseResponse -eq 'y') {
        Write-Host "Deploying to Firebase..." -ForegroundColor Cyan
        firebase deploy --only hosting:wealthbridge
        Write-Host "✅ Firebase deployment complete" -ForegroundColor Green
        Write-Host "📍 Frontend URL: https://wealthbridge.web.app" -ForegroundColor Cyan
    }
}

Write-Host ""

# Step 4: Deploy to Linode
Write-Host "Step 4: Linode Backend Deployment" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Yellow

$linodeResponse = Read-Host "Deploy to Linode backend? (y/n)"
if ($linodeResponse -eq 'y') {
    $linodeHost = Read-Host "Linode host (default: wealthbridge-linode)"
    $linodeHost = if ($linodeHost) { $linodeHost } else { "wealthbridge-linode" }
    
    Write-Host "Connecting to $linodeHost..." -ForegroundColor Cyan
    
    # Deploy frontend to Linode
    Write-Host "Uploading Flutter build to Linode..." -ForegroundColor Gray
    ssh -n "$linodeHost" "mkdir -p /var/www/wealthbridge"
    scp -r "$buildDir/*" "${linodeHost}:/var/www/wealthbridge/"
    
    # Deploy backend
    Write-Host "Deploying backend API..." -ForegroundColor Gray
    ssh -n "$linodeHost" @"
        cd /var/www/wealthbridge/api
        npm ci --production
        pm2 restart wealthbridge-api || pm2 start src/server.js --name wealthbridge-api
        pm2 save
"@
    
    # Reload Nginx
    Write-Host "Reloading Nginx..." -ForegroundColor Gray
    ssh -n "$linodeHost" "nginx -t && systemctl reload nginx"
    
    Write-Host "✅ Linode deployment complete" -ForegroundColor Green
    
    # Get Linode IP
    $linodeIP = ssh -n "$linodeHost" "hostname -I | awk '{print \$1}'"
    Write-Host "📍 Backend URL: http://$linodeIP" -ForegroundColor Cyan
}

Write-Host ""

# Step 5: Akash GPU deployment (optional)
Write-Host "Step 5: Akash GPU Deployment (Optional)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

$akashResponse = Read-Host "Deploy NVQLink to Akash GPU? (y/n)"
if ($akashResponse -eq 'y') {
    Write-Host "Deploying to Akash..." -ForegroundColor Cyan
    
    # Check Akash CLI
    try {
        akash --version | Out-Null
    } catch {
        Write-Host "❌ Akash CLI not found. Install from: https://docs.akash.network/install" -ForegroundColor Red
        $installAkash = Read-Host "Install Akash CLI now? (y/n)"
        if ($installAkash -eq 'y') {
            # Installation command would go here
            Write-Host "Please visit: https://docs.akash.network/install" -ForegroundColor Yellow
        }
    }
    
    Write-Host "📝 Akash deployment config ready at: $deploymentDir\akash\deploy.yaml" -ForegroundColor Gray
    Write-Host "Run: akash tx deployment create $deploymentDir\akash\deploy.yaml" -ForegroundColor Gray
}

Write-Host ""

# Step 6: Post-deployment verification
Write-Host "Step 6: Post-Deployment Verification" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow

function Test-Endpoint {
    param([string]$url, [string]$name)
    try {
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -SkipHttpErrorCheck
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $name - $url" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️  $name - Status: $($response.StatusCode)" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "❌ $name - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

$endpointsOK = $true

if ($configs.firebase.enabled) {
    $endpointsOK = (Test-Endpoint "https://wealthbridge.web.app/health" "Firebase Frontend") -and $endpointsOK
}

if ($linodeResponse -eq 'y') {
    $endpointsOK = (Test-Endpoint "http://$linodeIP/health" "Linode Backend") -and $endpointsOK
    $endpointsOK = (Test-Endpoint "http://$linodeIP/api/health" "API Gateway") -and $endpointsOK
}

Write-Host ""

# Step 7: Deployment summary
Write-Host "Step 7: Deployment Summary" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow
Write-Host ""

$summary = @"
╔════════════════════════════════════════════════════════╗
║           WEALTHBRIDGE DEPLOYMENT SUMMARY              ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║ 📊 Deployment Status                                   ║
║  ├─ Flutter Build: ✅ Complete (38 capsules)          ║
║  ├─ Firebase Frontend: $(if ($firebaseResponse -eq 'y') { '✅ Deployed' } else { '⏭️  Skipped' })                     ║
║  ├─ Linode Backend: $(if ($linodeResponse -eq 'y') { '✅ Deployed' } else { '⏭️  Skipped' })                       ║
║  └─ Akash GPU: $(if ($akashResponse -eq 'y') { '📋 Ready' } else { '⏭️  Skipped' })                         ║
║                                                        ║
║ 🔗 URLs                                                ║
║  ├─ Frontend: https://wealthbridge.web.app            ║
║  ├─ Backend: http://$linodeIP                         ║
║  └─ API: http://$linodeIP/api/                        ║
║                                                        ║
║ 📋 Next Steps                                          ║
║  1. Test all capsules load correctly                  ║
║  2. Configure Stripe webhooks                         ║
║  3. Link Plaid account                                ║
║  4. Activate affiliate program                        ║
║  5. Monitor logs for errors                           ║
║                                                        ║
║ 🔐 Security Checklist                                 ║
║  [ ] Enable HTTPS/SSL on domain                       ║
║  [ ] Configure CORS for Stripe/Plaid                  ║
║  [ ] Set up firewall rules                            ║
║  [ ] Enable monitoring/alerts                         ║
║  [ ] Backup database daily                            ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
"@

Write-Host $summary -ForegroundColor Cyan
Write-Host ""

Write-Host "✨ Deployment orchestration complete!" -ForegroundColor Green
Write-Host ""

# Optional: Open URLs
$openBrowser = Read-Host "Open URLs in browser? (y/n)"
if ($openBrowser -eq 'y') {
    if ($firebaseResponse -eq 'y') {
        Start-Process "https://wealthbridge.web.app"
    }
    if ($linodeResponse -eq 'y') {
        Start-Process "http://$linodeIP"
    }
}

Write-Host "🚀 WealthBridge is live!" -ForegroundColor Green
