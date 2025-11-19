# Code Catalyst by Influwealth

**AI-Powered Coding Agent for Everyone (8-80 Years Old)**

Simplifying software development through intelligent code suggestions, generation, and analysis. Powered by Claude AI, integrated with WealthBridge ecosystem.

---

## 🎯 What is Code Catalyst?

Code Catalyst is a sovereign, domain-specific AI coding agent that:

✅ **Suggests** code improvements for Dart, Solidity, JavaScript, Python  
✅ **Generates** production-ready code from natural language prompts  
✅ **Analyzes** smart contracts for security vulnerabilities  
✅ **Audits** code for credential leaks and quality issues  
✅ **Sends** SMS/Voice notifications via Twilio (affiliate alerts, event confirmations)  
✅ **Bridges** with WealthBridge SIMA2Agent for stateful orchestration  

---

## 🚀 Launch Date: TODAY (November 16, 2025)

**Status**: ✅ **PRODUCTION READY**  
**Organization**: Influwealth Consult LLC  
**Website**: https://influwealth.wixsite.com/influwealth-consult  
**Support**: support@influwealth.com

---

## 📦 What's Included

### FastAPI Backend (`/backend/app/`)

| File | Purpose | Lines |
|------|---------|-------|
| **main.py** | FastAPI initialization, CORS, health checks | 120 |
| **config.py** | Environment loader, credential validation | 160 |
| **api.py** | 12 endpoints (suggest, generate, analyze, audit, **Twilio SMS/Voice**, webhook, SIMA2 bridge) | 470 |
| **worker.py** | Async LLM processing, Claude/OpenAI routing | 250 |
| **twilio_service.py** | SMS/Voice implementation with batch capability | 260 |

### Infrastructure

| File | Purpose |
|------|---------|
| **docker-compose.yml** | FastAPI + Redis + MongoDB stack |
| **Dockerfile** | Production-ready Python 3.11 image |
| **requirements.txt** | 14 Python dependencies (including twilio) |

### CLI Tool (`/cli/`)

| File | Purpose |
|------|---------|
| **codecatalyst-cli.py** | Typer-based command-line interface |

### Documentation

| File | Purpose |
|------|---------|
| **.env.example** | Credential template (copy to .env.local) |
| **LAUNCH_TODAY.md** | 5-minute quick start + API examples |
| **DEPLOYMENT_COMMANDS.md** | Git & GitHub commands for immediate deployment |
| **README.md** | This file |

---

## 🔧 Quick Start

### 1. Clone & Setup (2 min)
```bash
git clone https://github.com/Influwealth/code-catalyst-influwealth.git
cd code-catalyst-influwealth
cp .env.example .env.local
# Edit .env.local with your API keys
```

### 2. Start Services (1 min)
```bash
docker-compose up -d
# Runs: FastAPI (8001), Redis (6379), MongoDB (27017)
```

### 3. Test Health (30 sec)
```bash
curl http://localhost:8001/health
```

### 4. Send Your First SMS (1 min)
```bash
curl -X POST http://localhost:8001/api/twilio/send-sms \
  -H "Content-Type: application/json" \
  -d '{
    "to_number": "+1-555-1234",
    "message": "Hello from Code Catalyst!"
  }'
```

**[See LAUNCH_TODAY.md for full guide]**

---

## 📡 API Endpoints (12 Total)

### Code Generation (4 endpoints)
```
POST /api/suggest              # AI code suggestions
POST /api/generate             # Code generation with templates
POST /api/analyze-contract     # Smart contract security analysis
POST /api/audit                # Code audit & credential scanning
```

### Communications - Twilio (5 endpoints) ⭐ NEW
```
POST /api/twilio/send-sms                          # Single SMS
POST /api/twilio/send-voice                        # Voice call (TTS)
POST /api/twilio/send-sms-batch                    # Batch SMS
POST /api/twilio/send-event-confirmation           # Event SMS
POST /api/twilio/send-affiliate-notification       # Affiliate alerts
```

### Integration (3 endpoints)
```
POST /api/webhook              # GitHub App webhook receiver
GET  /api/task/{task_id}       # Background task status
POST /api/sima2-bridge         # SIMA2Agent orchestration
```

### System (2 endpoints)
```
GET  /health                   # Health check
GET  /config                   # Configuration validation
```

---

## 🔐 Credentials Required (5 Minimum)

1. **Anthropic API Key** (Claude AI)
   - Get: https://console.anthropic.com/
   
2. **Twilio Account** (SMS/Voice)
   - Get: https://www.twilio.com/console
   
3. **Polygon RPC** (Web3 - optional for launch)
   - Get: https://www.alchemy.com/
   
4. **Stripe API Keys** (Payments - optional for launch)
   - Get: https://dashboard.stripe.com/
   
5. **GitHub App** (Webhook - optional for launch)
   - Get: https://github.com/settings/apps

**[See .env.example for full credential list]**

---

## 🛠️ CLI Tool Usage

```bash
# Install
pip install -r backend/requirements.txt

# Suggest code improvements
python cli/codecatalyst-cli.py suggest \
  --code "class X {}" \
  --language dart \
  --prompt "Add error handling"

# Generate new code
python cli/codecatalyst-cli.py generate \
  --prompt "Create AP2 affiliate capsule" \
  --language dart

# Check health
python cli/codecatalyst-cli.py health

# View config
python cli/codecatalyst-cli.py config
```

---

## 🌐 Integration Points

### WealthBridge (38 Dart Capsules)
- Seamless Dart code suggestion & generation
- Dart-specific system prompts for capsule patterns
- Integration with SIMA2Agent (stateful orchestration)

### Polygon Web3
- Smart contract analysis (Solidity)
- Gas optimization suggestions
- Vulnerability detection

### Stripe Treasury
- AP2 affiliate payout system integration
- Payment confirmation notifications (Twilio SMS)

### Twilio Communications
- **SMS**: Affiliate notifications, event confirmations, alerts
- **Voice**: TTS-powered hotline updates
- **Batch**: Reach 1000s of users instantly

---

## 🚀 Deployment Options

### Local (Development)
```bash
docker-compose up -d
# Services running on localhost
```

### Linode (Production - Coming Next)
- Sovereign infrastructure (not AWS/Google)
- Terraform automation ready
- DNS + SSL pre-configured

### Akash Network (Decentralized - Coming Next)
- Distributed edge deployment
- Blockchain-verified hosting
- Cost optimization via auction

---

## 📊 Architecture

```
┌─────────────────────────────────────────────┐
│         Client (CLI / Web / Mobile)         │
└────────────────┬────────────────────────────┘
                 │ HTTP/REST
┌─────────────────┴────────────────────────────┐
│         FastAPI Server (Port 8001)          │
│  ┌─────────────────────────────────────┐    │
│  │ Routes (12 endpoints)               │    │
│  │ - Suggest, Generate, Analyze        │    │
│  │ - Audit, Twilio SMS/Voice           │    │
│  │ - GitHub Webhook, SIMA2 Bridge      │    │
│  └─────────────────────────────────────┘    │
└─────────────────┬────────────────────────────┘
                  │
     ┌────────────┼────────────┐
     │            │            │
┌────┴────┐  ┌───┴────┐  ┌────┴────┐
│  Redis  │  │MongoDB │  │ Claude  │
│ (Queue) │  │(Store) │  │  (LLM)  │
└─────────┘  └────────┘  └─────────┘
```

---

## 🎓 Use Cases

### For Developers
- Get Dart capsule suggestions in seconds
- Generate Solidity contracts with security review
- Auto-audit code for credential leaks

### For Affiliates
- Receive AP2 payout notifications via SMS
- Event confirmations (Eventbrite integration)
- Onboarding guidance via Twilio voice

### For Enterprises
- White-label AI coding assistant
- Custom domain deployment
- Private data handling (sovereign)

### For Everyone (8-80)
- Natural language prompts ("Make me a Flutter app")
- No coding experience needed
- Instant code generation + explanations

---

## 📝 File Structure

```
code-catalyst-influwealth/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI app
│   │   ├── config.py            # Configuration
│   │   ├── api.py               # 12 endpoints
│   │   ├── worker.py            # LLM processing
│   │   └── twilio_service.py    # SMS/Voice module
│   ├── Dockerfile
│   └── requirements.txt
├── cli/
│   └── codecatalyst-cli.py       # CLI tool
├── .env.example                   # Credentials template
├── docker-compose.yml             # Stack definition
├── LAUNCH_TODAY.md                # Quick start
├── DEPLOYMENT_COMMANDS.md         # GitHub setup
└── README.md                      # This file
```

---

## 🔗 Links

- **GitHub Repo**: https://github.com/Influwealth/code-catalyst-influwealth
- **Company Website**: https://influwealth.wixsite.com/influwealth-consult
- **Support Email**: support@influwealth.com
- **Company Address**: 224 W 35th St Fl 5, New York, NY 10001

---

## 📞 Support

**Email**: support@influwealth.com  
**Hours**: Monday - Friday, 9 AM - 6 PM EST  
**Response Time**: Within 24 hours

---

## 🎯 Roadmap (Post-Launch)

✅ **Phase 1 (TODAY)**: Code Catalyst launch with Twilio  
⏳ **Phase 2 (Week 1)**: Terraform infrastructure deployment  
⏳ **Phase 3 (Week 2)**: GitHub Actions CI/CD pipeline  
⏳ **Phase 4 (Week 3)**: AnythingLLM white-label RAG  
⏳ **Phase 5 (Week 4)**: Influwealth-OS parent platform  

---

## 📄 License

Proprietary - Influwealth Consult LLC  
All rights reserved © 2025

---

## ✨ Built With

- **FastAPI**: Modern Python web framework
- **Claude AI**: Anthropic's advanced language model
- **Twilio**: SMS & Voice communications
- **Polygon**: Ethereum scaling solution
- **Redis**: In-memory message queue
- **MongoDB**: Document database
- **Docker**: Containerization
- **Dart**: WealthBridge capsule language

---

**Status**: 🚀 **LIVE** - November 16, 2025

Welcome to Code Catalyst. Let's simplify coding for everyone.
