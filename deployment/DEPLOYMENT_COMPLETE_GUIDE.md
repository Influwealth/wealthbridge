# WealthBridge Complete Deployment & Integration Guide

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                    WEALTHBRIDGE ECOSYSTEM                    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  FRONTEND TIER (Global CDN)                          │  │
│  │  ├─ Firebase Hosting (Flutter Web)                   │  │
│  │  ├─ 38 Capsules: Admin, AP2, FACTIIV, Stablecoin    │  │
│  │  ├─ Key Agent: Stripe/Plaid key management          │  │
│  │  └─ Service Worker: Offline capability              │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ↓ HTTPS                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  API GATEWAY TIER (Nginx Reverse Proxy)              │  │
│  │  ├─ Route: /api/* → :8080 (Backend API)             │  │
│  │  ├─ Route: /webhooks/stripe → Stripe handler        │  │
│  │  ├─ Route: /webhooks/plaid → Plaid handler          │  │
│  │  └─ Health checks: /health (Linode monitoring)      │  │
│  └──────────────────────────────────────────────────────┘  │
│                      (Linode VPS)                           │
│                           ↓                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  BACKEND TIER (Business Logic)                       │  │
│  │  ├─ Node.js Express API (port 8080)                  │  │
│  │  ├─ MongoDB (local or Atlas)                         │  │
│  │  ├─ Stripe integration (payment processing)          │  │
│  │  ├─ Plaid integration (bank linking)                 │  │
│  │  └─ PM2 process manager (auto-restart)              │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ↓                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  BLOCKCHAIN & GPU TIER                               │  │
│  │  ├─ Polygon RPC (stablecoin smart contracts)        │  │
│  │  ├─ Akash GPU (NVQLink CUDA-Q compute)              │  │
│  │  ├─ MPC Wallet (multi-party computation)            │  │
│  │  └─ XMCP Orchestration (capsule workflows)          │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  SECURITY LAYER                                      │  │
│  │  ├─ VaultGemma encryption (quantum-resistant)        │  │
│  │  ├─ SSL/TLS (Firebase auto + Certbot Linode)        │  │
│  │  ├─ Rate limiting (Nginx + API middleware)          │  │
│  │  ├─ DDoS protection (CloudFlare optional)           │  │
│  │  └─ API keys in .env.local (never committed)        │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  MONITORING & OBSERVABILITY                          │  │
│  │  ├─ Linode monitoring (CPU, RAM, disk)              │  │
│  │  ├─ PM2 Plus (optional: process monitoring)          │  │
│  │  ├─ Nginx logs (access + error)                      │  │
│  │  ├─ Firebase Analytics (user behavior)              │  │
│  │  └─ Sentry (optional: error tracking)               │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Deployment Sequence

### Phase 1: Local Preparation (30 min)
```bash
# 1. Create .env file with secrets (NEVER commit this)
cat > .env.local << EOF
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
PLAID_CLIENT_ID=...
PLAID_SECRET=...
PLAID_ENV=sandbox
POLYGON_PRIVATE_KEY=0x...
POLYGON_WALLET_ADDRESS=0x...
EOF

# 2. Build Flutter web
flutter clean && flutter pub get && flutter build web --release

# 3. Verify build
Test-Path build/web/index.html  # Should be True
```

### Phase 2: Firebase Frontend Deployment (15 min)
```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login
firebase login

# 3. Initialize (if first time)
firebase init hosting

# 4. Deploy
firebase deploy --only hosting:wealthbridge

# 5. Verify
Start-Process "https://wealthbridge.web.app"
```

### Phase 3: Linode Backend Setup (45 min)
```bash
# 1. SSH into Linode
ssh wealthbridge-linode

# 2. Run server setup
# Follow LINODE_DEPLOYMENT_GUIDE.md

# 3. Upload Flutter build
scp -r build/web/* wealthbridge-linode:/var/www/wealthbridge/

# 4. Deploy API
ssh wealthbridge-linode "cd /var/www/wealthbridge/api && npm ci && pm2 start src/server.js"

# 5. Reload Nginx
ssh wealthbridge-linode "systemctl reload nginx"
```

### Phase 4: Polygon Smart Contracts (20 min)
```bash
# 1. Configure Polygon
powershell -ExecutionPolicy Bypass -File scripts/setup_polygon.ps1

# 2. Generate wallet
node config/deploy-polygon.js

# 3. Deploy contracts (testnet first)
# See config/POLYGON_DEPLOYMENT_CHECKLIST.md
```

### Phase 5: Akash GPU Setup (Optional, 30 min)
```bash
# 1. Install Akash CLI
curl https://raw.githubusercontent.com/ovrclk/akash/master/install.sh | bash

# 2. Deploy manifest
akash tx deployment create deployment/akash/deploy.yaml

# 3. Monitor GPU utilization
# GPU workloads for NVQLink quantum simulation
```

### Phase 6: Monitoring & Alerts (15 min)
```bash
# 1. Set up Linode monitoring alerts
# Via: https://cloud.linode.com/monitoring

# 2. Configure Stripe webhooks
stripe listen --forward-to https://wealthbridge.yourdomain.com/webhooks/stripe

# 3. Test end-to-end
# UI → API → Database → Stripe/Plaid
```

---

## File Structure After Deployment

```
WealthBridge/
├── deployment/
│   ├── nginx/
│   │   └── wealthbridge.conf          ← Nginx reverse proxy config
│   ├── LINODE_DEPLOYMENT_GUIDE.md     ← Backend setup instructions
│   ├── FIREBASE_SETUP_GUIDE.md        ← Frontend setup instructions
│   ├── deploy.ps1                     ← Orchestration script
│   ├── DEPLOYMENT_CHECKLIST.md        ← Verification steps
│   └── akash/
│       └── deploy.yaml                ← GPU deployment manifest
├── .env.local                         ← Secrets (GITIGNORED)
├── firebase.json                      ← Firebase config
├── .firebaserc                        ← Firebase project ID
├── build/
│   └── web/                           ← Flutter build artifacts
├── lib/
│   ├── widgets/
│   │   ├── key_agent_capsule.dart     ← Stripe/Plaid key management
│   │   ├── stablecoin_factory_capsule.dart
│   │   ├── nvqlink_capsule.dart
│   │   └── ... (35 other capsules)
│   └── capsules/
│       └── capsule_registry.dart      ← Dynamic routing for 38 capsules
└── ...
```

---

## Environment Variables Setup

### Create `.env.local` (NEVER commit)
```bash
# Stripe Payment Processing
STRIPE_SECRET_KEY=sk_test_51234567890abcdefghijklmnop
STRIPE_PUBLISHABLE_KEY=pk_test_51234567890abcdefghijklmnop
STRIPE_WEBHOOK_SECRET=whsec_1234567890abcdefghijklmnop

# Plaid Bank Linking
PLAID_CLIENT_ID=abc123def456ghi789
PLAID_SECRET=xyz789uvw012rst345
PLAID_ENV=sandbox  # Change to development/production

# Polygon Blockchain
POLYGON_RPC_URL=https://rpc-mumbai.maticvigil.com
POLYGON_CHAIN_ID=80001
POLYGON_PRIVATE_KEY=0x1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnop
POLYGON_WALLET_ADDRESS=0xabcdefghijklmnopqrstuvwxyz1234567890abcd

# MongoDB (if self-hosted)
MONGODB_URI=mongodb://localhost:27017/wealthbridge

# Firebase (auto-generated)
FIREBASE_PROJECT_ID=wealthbridge-abc123
FIREBASE_STORAGE_BUCKET=wealthbridge-abc123.appspot.com

# General
NODE_ENV=production
PORT=8080
FRONTEND_URL=https://wealthbridge.yourdomain.com
```

### Add to `.gitignore`
```
.env.local
.env.production.local
*.pem
*.key
config/polygon.config.json
config/.env.polygon
```

---

## Quick Deployment Commands

### One-Command Deploy (Complete Pipeline)
```powershell
# Run from WealthBridge root
powershell -ExecutionPolicy Bypass -File deployment/deploy.ps1
```

### Individual Component Deploy
```bash
# Frontend only
firebase deploy --only hosting:wealthbridge

# Backend only (Linode)
scp -r build/web/* wealthbridge-linode:/var/www/wealthbridge/
ssh wealthbridge-linode "systemctl reload nginx"

# API restart
ssh wealthbridge-linode "pm2 restart wealthbridge-api"

# View logs
ssh wealthbridge-linode "pm2 logs wealthbridge-api"

# Polygon contract deployment
node config/deploy-polygon.js

# Akash GPU deployment
akash tx deployment create deployment/akash/deploy.yaml
```

---

## Verification Checklist

### Frontend (Firebase)
- [ ] Site loads at https://wealthbridge.web.app
- [ ] All 38 capsules visible in navigation
- [ ] Key Agent Capsule loads Stripe keys
- [ ] Service worker installed (offline support)
- [ ] Analytics tracking active

### Backend (Linode)
- [ ] SSH access: `ssh wealthbridge-linode` works
- [ ] Nginx running: `systemctl status nginx`
- [ ] API responding: `curl http://localhost:8080/health`
- [ ] Database connected: MongoDB up
- [ ] Logs clean: `pm2 logs wealthbridge-api`

### Integrations
- [ ] Stripe test payment succeeds
- [ ] Plaid link flow completes
- [ ] Polygon contract deployed (testnet)
- [ ] Webhooks configured and receiving
- [ ] Email notifications working

### Security
- [ ] SSL certificate valid
- [ ] Rate limiting active
- [ ] Firewall rules configured (22, 80, 443)
- [ ] API keys in .env.local (not committed)
- [ ] Database backups scheduled

### Performance
- [ ] Frontend loads < 2 seconds
- [ ] API response time < 500ms
- [ ] Database queries optimized
- [ ] Nginx gzip compression enabled
- [ ] CDN cache headers set

---

## Troubleshooting Guide

### Issue: "Firebase not found"
```bash
npm install -g firebase-tools
firebase login
```

### Issue: "Cannot SSH to Linode"
```bash
# Check SSH key setup
ls -la ~/.ssh/wealthbridge_linode
ssh -v wealthbridge-linode  # Verbose output
```

### Issue: "API returns 502 Bad Gateway"
```bash
# On Linode
pm2 restart wealthbridge-api
pm2 logs wealthbridge-api
systemctl reload nginx
```

### Issue: "Stripe webhook not received"
```bash
# Verify webhook URL in Stripe Dashboard
# Check logs: tail -f /var/log/nginx/stripe-webhooks.log
# Test: stripe trigger payment_intent.succeeded
```

### Issue: "Flutter web doesn't load capsules"
```bash
# Rebuild and deploy
flutter clean && flutter pub get && flutter build web --release
firebase deploy --only hosting:wealthbridge
```

---

## Post-Launch Optimization

### 1. Database Indexing (MongoDB)
```javascript
db.transactions.createIndex({ userId: 1, createdAt: -1 });
db.wallets.createIndex({ address: 1 });
db.capsules.createIndex({ category: 1 });
```

### 2. Caching Strategy
- Static assets (JS/CSS/Wasm): 7 days
- Images/Fonts: 30 days
- Service Worker: Never cache
- API responses: Variable (5 min - 1 hour)

### 3. Error Tracking (Optional Sentry)
```bash
npm install @sentry/node
# Configure in API server.js
```

### 4. Analytics Dashboard
- Firebase Console: User activity
- Linode Cloud Manager: Server metrics
- PM2 Plus: Process monitoring (optional)
- Custom: Transaction dashboards

---

## Security Hardening Checklist

- [ ] Enable HTTPS/SSL everywhere
- [ ] Configure CORS for Stripe/Plaid
- [ ] Rate limit API (100 req/min per IP)
- [ ] Set security headers (HSTS, X-Frame-Options, etc.)
- [ ] Rotate API keys monthly
- [ ] Enable 2FA on all services
- [ ] Daily database backups to Linode Backups
- [ ] Monitor for unusual traffic patterns
- [ ] Regular security audits
- [ ] Keep dependencies updated

---

## Support & Escalation

### If frontend is down:
1. Check Firebase Console for errors
2. Verify build/web exists locally
3. Redeploy: `firebase deploy`
4. Check service worker cache

### If backend is down:
1. SSH to Linode: `ssh wealthbridge-linode`
2. Check PM2: `pm2 status`
3. Check Nginx: `systemctl status nginx`
4. Check logs: `pm2 logs wealthbridge-api`

### If payments are failing:
1. Verify Stripe API keys in .env
2. Check webhook delivery in Stripe Dashboard
3. Verify firewall allows inbound webhooks
4. Test with `stripe trigger charge.succeeded`

### If GPU compute is slow:
1. Monitor Akash deployment: `akash query deployment list`
2. Check GPU utilization on Linode
3. Optimize CUDA-Q queries
4. Consider scaling to more GPU nodes

---

## Next Phase: Scale & Optimize

After launch:
1. Monitor performance metrics (P95 latency, error rates)
2. Gather user feedback on capsule UX
3. Optimize database queries
4. Scale backend if needed (add more Linode nodes)
5. Expand GPU compute on Akash
6. Plan Phase 1.1 features (Analytics, Leaderboard, etc.)
7. Prepare for affiliate activation
8. Revenue processing automation

---

✅ **WealthBridge is production-ready!**

Questions? Check individual guide files:
- `LINODE_DEPLOYMENT_GUIDE.md` - Backend setup
- `FIREBASE_SETUP_GUIDE.md` - Frontend setup
- `POLYGON_DEPLOYMENT_CHECKLIST.md` - Blockchain
- `deployment/nginx/wealthbridge.conf` - Web server

🚀 **Ready to launch!**
