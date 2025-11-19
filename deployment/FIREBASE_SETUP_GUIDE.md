# Firebase CLI Setup for WealthBridge
# Configure Firebase for frontend hosting and optional backend functions

## 1. Install Firebase CLI

### Windows (via npm)
```powershell
npm install -g firebase-tools
firebase --version  # Verify installation
```

### Verify Installation
```bash
firebase --version
which firebase  # Should show: C:\Users\...\AppData\Roaming\npm\firebase
```

---

## 2. Create Firebase Project

### Login to Firebase
```bash
firebase login  # Opens browser to authenticate
```

### Initialize Firebase Project
```bash
# From WealthBridge root directory
firebase init

# Select during init:
# - Hosting: YES (deploy Flutter web)
# - Emulators: YES (optional, for local testing)
# - Functions: YES (optional, for serverless API layer)
```

### Interactive Setup
```
? Which Firebase features do you want to set up for this directory?
  ✔ Hosting: Configure and deploy Firebase Hosting sites
  ✔ Emulators: Set up local emulators for Firebase features
  ✔ Functions: Configure a Cloud Functions directory with sample code

? What do you want to use as your public directory?
  build/web  (Flutter web build output)

? Configure as a single-page app (rewrite all urls to /index.html)?
  Yes

? Enable GitHub Workflows?
  Yes (for CI/CD)

? Set up automatic deploys on every push to main?
  Yes
```

---

## 3. Configure firebase.json

```json
{
  "hosting": [
    {
      "target": "wealthbridge",
      "public": "build/web",
      "ignore": [
        "firebase.json",
        "**/.*",
        "**/node_modules/**"
      ],
      "rewrites": [
        {
          "source": "**",
          "destination": "/index.html"
        }
      ],
      "headers": [
        {
          "source": "/flutter_service_worker.js",
          "headers": [
            {
              "key": "Cache-Control",
              "value": "max-age=0"
            }
          ]
        },
        {
          "source": "**/*.@(js|css|png|gif|jpg|jpeg|svg|wasm)",
          "headers": [
            {
              "key": "Cache-Control",
              "value": "max-age=31536000"
            }
          ]
        }
      ],
      "redirects": [
        {
          "source": "/health",
          "destination": "/",
          "type": 200
        }
      ]
    }
  ],
  "functions": {
    "source": "functions",
    "runtime": "nodejs20"
  }
}
```

---

## 4. Deploy to Firebase Hosting

### Build Flutter web (if not already done)
```bash
flutter clean
flutter pub get
flutter build web --release
```

### Deploy
```bash
firebase deploy --only hosting:wealthbridge
```

### Verify Deployment
```bash
firebase open hosting:wealthbridge
# Opens: https://wealthbridge-abc123.web.app
```

---

## 5. Optional: Firebase Cloud Functions (API Layer)

### Create Cloud Function for Stripe webhooks

File: `functions/src/index.ts`

```typescript
import * as functions from "firebase-functions";
import * as express from "express";
import Stripe from "stripe";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || "");
const app = express();

// Middleware
app.use(express.json());

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "OK" });
});

// Stripe webhook handler
app.post("/webhooks/stripe", express.raw({ type: "application/json" }), (req, res) => {
  const sig = req.headers["stripe-signature"] as string;
  try {
    const event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET || ""
    );

    switch (event.type) {
      case "charge.succeeded":
        console.log("Payment succeeded:", event.data.object);
        break;
      case "charge.failed":
        console.log("Payment failed:", event.data.object);
        break;
    }

    res.json({ received: true });
  } catch (err) {
    res.status(400).send(`Webhook error: ${err}`);
  }
});

// Stablecoin minting endpoint
app.post("/mint-stablecoin", async (req, res) => {
  const { userId, amount, walletAddress } = req.body;

  // TODO: Integrate with Stripe Treasury API
  // TODO: Integrate with Polygon smart contract

  res.json({
    success: true,
    txHash: null,
    amount: amount,
    wallet: walletAddress,
  });
});

export const api = functions.https.onRequest(app);
```

### Set environment variables
```bash
firebase functions:config:set stripe.secret_key="sk_test_..."
firebase functions:config:set stripe.webhook_secret="whsec_..."
```

### Deploy functions
```bash
firebase deploy --only functions
```

---

## 6. Connect Domain (Optional)

### Add custom domain in Firebase Console
1. Go to Firebase Console → Hosting
2. Click "Connect domain"
3. Enter: `wealthbridge.yourdomain.com`
4. Add DNS records (Firebase provides)
5. Wait for SSL certificate (usually 24 hours)

---

## 7. Deployment Strategies

### Strategy A: Firebase Hosting + Linode Backend
```
┌─ Firebase Hosting ─────────────────┐
│ Flutter web build (static assets)  │
│ Global CDN delivery               │
│ Auto SSL/TLS                      │
└──────────────┬──────────────────────┘
               │ API calls
               ↓
┌─ Linode Backend ──────────────────┐
│ Nginx reverse proxy               │
│ Node.js API (port 8080)           │
│ MongoDB/Database                  │
│ GPU compute (NVQLink)             │
└────────────────────────────────────┘
```

### Strategy B: Pure Firebase (Recommended for MVP)
```
┌─ Firebase ────────────────────────────┐
│ Hosting: Flutter web (global CDN)     │
│ Functions: API layer (serverless)     │
│ Firestore: Real-time database         │
│ Auth: User management                 │
└──────────────────────────────────────┘
```

---

## 8. CI/CD with GitHub Actions

Firebase init creates `.github/workflows/firebase-hosting-*`.

File: `.github/workflows/deploy.yml`

```yaml
name: Deploy to Firebase

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.7'

      - name: Build Flutter Web
        run: |
          flutter clean
          flutter pub get
          flutter build web --release

      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
          projectId: wealthbridge
```

---

## 9. Monitoring & Analytics

### Enable Google Analytics
```bash
firebase analytics:enabled
```

### Check deployment logs
```bash
firebase hosting:channel:list
firebase hosting:channel:open <channel-id>
```

### View real-time logs
```bash
firebase functions:log
```

---

## 10. Quick Reference Commands

```bash
# Login
firebase login

# Initialize project
firebase init

# Build and deploy
flutter build web --release && firebase deploy

# Deploy only hosting
firebase deploy --only hosting:wealthbridge

# Deploy only functions
firebase deploy --only functions

# View live site
firebase open hosting:wealthbridge

# Check deployment history
firebase hosting:channel:list

# Remove old channel
firebase hosting:channel:delete <channel-id>

# Local emulation
firebase emulators:start
```

---

## 11. Troubleshooting

### Issue: "Cannot find firebase.json"
```bash
cd /path/to/WealthBridge
firebase init
```

### Issue: "Authentication failed"
```bash
firebase logout
firebase login
```

### Issue: "Build directory not found"
```bash
flutter build web --release  # Create build/web first
firebase deploy
```

### Issue: "Hosting target not configured"
```bash
firebase target:apply hosting wealthbridge build/web
firebase deploy --only hosting:wealthbridge
```

---

## Next Steps

1. ✅ Install Firebase CLI
2. ✅ `firebase login` and authenticate
3. ✅ `firebase init` and configure for WealthBridge
4. ✅ Update `.firebaserc` with your project ID
5. ✅ Deploy: `flutter build web --release && firebase deploy`
6. ✅ Test at https://wealthbridge-abc123.web.app
7. ✅ Add custom domain for production
8. ✅ Monitor deployment health

**Ready to deploy to Firebase!** 🚀
