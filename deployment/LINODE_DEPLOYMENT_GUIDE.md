# Linode Backend Deployment Guide
# Complete setup for WealthBridge capsule infrastructure

## 1. SSH Configuration (Local Machine)

### Create SSH key (if not already done)
```bash
ssh-keygen -t ed25519 -f ~/.ssh/wealthbridge_linode -C "wealthbridge@linode"
```

### Add to Linode server
```bash
# Copy public key content and add to Linode /root/.ssh/authorized_keys
cat ~/.ssh/wealthbridge_linode.pub
```

### Configure SSH config (~/.ssh/config)
```
Host wealthbridge-linode
    HostName <YOUR_LINODE_IP>
    User root
    IdentityFile ~/.ssh/wealthbridge_linode
    Port 22
    StrictHostKeyChecking accept-new
    
Host wealthbridge-gpu
    HostName <YOUR_LINODE_GPU_IP>
    User root
    IdentityFile ~/.ssh/wealthbridge_linode
    Port 22
```

### Test connection
```bash
ssh wealthbridge-linode "echo 'Connected to Linode!'"
```

---

## 2. Linode Server Setup (Run on Linode)

### Update system
```bash
apt update && apt upgrade -y
apt install -y curl wget git build-essential
```

### Install Node.js (for backend API)
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt install -y nodejs npm
npm install -g pm2 yarn
```

### Install Nginx (reverse proxy)
```bash
apt install -y nginx
systemctl enable nginx
systemctl start nginx
```

### Install MongoDB (if using Linode instead of Firebase)
```bash
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor | tee /etc/apt/keyrings/mongodb-archive-keyring.gpg > /dev/null
echo "deb [ arch=amd64,arm64 signed-by=/etc/apt/keyrings/mongodb-archive-keyring.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
apt update && apt install -y mongodb-org
systemctl enable mongod && systemctl start mongod
```

### Create deployment directory
```bash
mkdir -p /var/www/wealthbridge/{api,frontend,logs}
cd /var/www/wealthbridge
```

### Clone WealthBridge repo
```bash
git clone https://github.com/Influwealth/wealthbridge.git .
```

### Copy Nginx config
```bash
cp deployment/nginx/wealthbridge.conf /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/wealthbridge.conf /etc/nginx/sites-enabled/
nginx -t  # Test config
systemctl reload nginx
```

---

## 3. Backend API Setup (Linode Node.js)

### Create API application structure
```bash
mkdir -p /var/www/wealthbridge/api/{src,config,routes,middleware}

# Initialize Node project
cd /var/www/wealthbridge/api
npm init -y
npm install express cors dotenv stripe plaid axios mongoose pm2
```

### Create backend entry point (api/src/server.js)
```javascript
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const app = express();

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL,
  credentials: true
}));
app.use(express.json());

// Health check
app.get('/health', (req, res) => res.json({ status: 'OK' }));

// Stripe webhook
app.post('/webhooks/stripe', express.raw({type: 'application/json'}), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  try {
    const event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
    console.log('Stripe webhook:', event.type);
    res.json({ received: true });
  } catch (err) {
    res.status(400).send(\`Webhook error: \${err.message}\`);
  }
});

// Stablecoin minting endpoint
app.post('/api/mint-stablecoin', async (req, res) => {
  const { userId, amount, tokenAddress } = req.body;
  // TODO: Implement Stripe Treasury minting
  res.json({ success: true, txHash: null });
});

// Start server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(\`API running on port \${PORT}\`));
```

### Create .env file
```bash
cat > /var/www/wealthbridge/api/.env << EOF
PORT=8080
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
PLAID_CLIENT_ID=...
PLAID_SECRET=...
MONGODB_URI=mongodb://localhost:27017/wealthbridge
FRONTEND_URL=https://wealthbridge.yourdomain.com
POLYGON_RPC=https://rpc-mumbai.maticvigil.com
EOF
chmod 600 .env
```

### Start backend with PM2
```bash
cd /var/www/wealthbridge/api
npm start &

# Or use PM2 for persistence
pm2 start src/server.js --name "wealthbridge-api" --instances max
pm2 save
pm2 startup
```

---

## 4. Deploy Flutter Frontend

### Build Flutter web
```bash
# On local machine
flutter build web --release
```

### Copy to Linode
```bash
scp -r build/web/* wealthbridge-linode:/var/www/wealthbridge/
```

### Set permissions
```bash
ssh wealthbridge-linode "chown -R www-data:www-data /var/www/wealthbridge"
```

---

## 5. SSL Certificate (Let's Encrypt)

### Install Certbot
```bash
apt install -y certbot python3-certbot-nginx
```

### Generate certificate
```bash
certbot certonly --nginx -d wealthbridge.yourdomain.com
```

### Auto-renewal
```bash
systemctl enable certbot.timer
systemctl start certbot.timer
```

---

## 6. Firewall & Security

### UFW firewall
```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw enable
```

### Fail2ban (prevent brute force)
```bash
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban
```

---

## 7. Monitoring & Logging

### Check logs
```bash
# Nginx
tail -f /var/log/nginx/wealthbridge_access.log
tail -f /var/log/nginx/wealthbridge_error.log

# API
pm2 logs wealthbridge-api

# System
dmesg | tail -20
```

### Monitor resources
```bash
watch -n 1 'free -h && df -h && ps aux | grep node'
```

---

## 8. Akash Deployment (Decentralized GPU Compute)

### Install Akash CLI
```bash
curl https://raw.githubusercontent.com/ovrclk/akash/master/install.sh | bash
```

### Create deployment manifest (deploy.yaml)
```yaml
version: "2.0"

services:
  nvqlink-gpu:
    image: nvidia/cuda:12.0-runtime-ubuntu22.04
    expose:
      - port: 5000
        as: 8080
        proto: tcp
    env:
      - NVIDIA_VISIBLE_DEVICES=all
    resources:
      gpu:
        units: 1
      cpu:
        units: 4
      memory:
        size: 16Gi
      storage:
        size: 50Gi

profiles:
  compute:
    nvqlink-gpu:
      resources:
        gpu:
          units: 1
        cpu:
          units: 4
        memory:
          size: 16Gi

placement:
  westcoast:
    pricing:
      nvqlink-gpu: 50

deployment:
  westcoast:
    westcoast:
      count: 1
```

### Deploy to Akash
```bash
akash tx deployment create deploy.yaml --from=<account> --keyring-backend=os
```

---

## 9. Deployment Verification Checklist

- [ ] SSH access works
- [ ] Nginx running and config valid
- [ ] Backend API responding at http://localhost:8080
- [ ] MongoDB connected and healthy
- [ ] Flutter frontend deployed to /var/www/wealthbridge
- [ ] SSL certificate installed and auto-renewal enabled
- [ ] Firewall allows 22, 80, 443
- [ ] Stripe webhooks configured and receiving events
- [ ] Monitoring logs visible and clean
- [ ] Akash GPU ready for NVQLink workloads

---

## 10. SSH from VS Code

Add to VS Code SSH config:

```
Host wealthbridge-linode
    HostName <YOUR_LINODE_IP>
    User root
    IdentityFile ~/.ssh/wealthbridge_linode
```

Then in VS Code: `Remote-SSH: Connect to Host` → select `wealthbridge-linode`

---

## Quick Reference Commands

```bash
# SSH in
ssh wealthbridge-linode

# Deploy new frontend build
scp -r build/web/* wealthbridge-linode:/var/www/wealthbridge/

# Restart API
ssh wealthbridge-linode "pm2 restart wealthbridge-api"

# View logs
ssh wealthbridge-linode "pm2 logs wealthbridge-api"

# Check Nginx
ssh wealthbridge-linode "nginx -t && systemctl reload nginx"

# Monitor
ssh wealthbridge-linode "watch -n 1 'free -h && df -h'"
```

---

✅ **Ready to deploy!** Replace placeholders and follow each section in order.
