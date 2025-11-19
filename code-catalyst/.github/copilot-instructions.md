# Code Catalyst - AI Coding Agent Instructions

## 🎯 Project Overview
**Code Catalyst** is a sovereign AI coding agent that suggests, generates, and audits code across Dart, Solidity, JavaScript, and Python. It integrates with the WealthBridge ecosystem (SIMA2Agent), uses Twilio for SMS/Voice communications, and connects to Polygon Web3, Stripe Treasury, and GitHub.

**Core Stack**: FastAPI + Redis + MongoDB + Claude/OpenAI LLM + Twilio

---

## 🏗️ Architecture Principles

### Backend Structure (FastAPI)
- **`main.py`**: Lifespan management (Redis/config init), CORS setup, health endpoints
- **`config.py`**: Environment loading with `.env.local`, validation of 5 critical credentials (Anthropic/OpenAI, Twilio, Polygon, Stripe, GitHub)
- **`api.py`**: 12+ REST endpoints grouped by domain (suggest, generate, analyze, audit, Twilio, delegation, SIMA2 bridge)
- **`worker.py`**: Async LLM processing with language-specific system prompts; routes to Claude (default) or OpenAI
- **`twilio_service.py`**: Wrapper for SMS/Voice; gracefully handles disabled state
- **`agent_handoff.py`**: Task delegation router matching tasks to specialized agents (DartAgent, SolidityAuditor, etc.)
- **`dart_agent.py`**: Expert Dart specialization with WealthBridge capsule patterns (StatelessWidget, StatefulWidget)

### Key Data Flows
1. **Suggestion/Generation Flow**: Request → `process_suggestion/process_generation` → LLMProcessor → Claude/OpenAI → Redis queue → Response
2. **Agent Delegation**: Client → `/api/delegate` → `agent_handoff.predict_agent()` → Specialized agent → Result
3. **Twilio Integration**: Request → `twilio_service` → Twilio API → SMS/Voice delivery
4. **SIMA2 Bridge**: Code Catalyst request → `/api/sima2-bridge` → WealthBridge orchestration context

---

## 🔧 Critical Developer Workflows

### Local Development
```bash
# Setup
cp .env.example .env.local  # Edit with real credentials
pip install -r backend/requirements.txt

# Run FastAPI locally
python -m uvicorn backend.app.main:app --reload --port 8001

# Or use Docker
docker-compose up -d  # Services: FastAPI(8001), Redis(6379), MongoDB(27017)
```

### Testing & Debugging
- **Health Check**: `curl http://localhost:8001/health` — validates Redis, MongoDB, config
- **Config Check**: `curl http://localhost:8001/config` — shows LLM provider, Twilio status
- **CLI Testing**: `python backend/app/interactive_testing.py` — manual endpoint testing
- **Background Tasks**: Check Redis for queued tasks; use `/api/task/{task_id}` to poll status

### Deployment
- See `DEPLOYMENT_COMMANDS.md` for GitHub/Git workflow
- Use `deploy.ps1` for PowerShell-based deployments (Windows environment)
- Docker image: Python 3.11 with all dependencies in `requirements.txt`

---

## 📋 Project-Specific Patterns & Conventions

### LLM Routing Pattern
Code Catalyst uses configurable LLM provider selection (Claude or OpenAI). System prompts are language-specific:
```python
# In worker.py, SYSTEM_PROMPTS dict defines language-specific instructions
# - "dart": Flutter/WealthBridge capsule patterns
# - "solidity": Gas optimization, security, ERC standards
# - "javascript": RESTful APIs, middleware
# - "python": FastAPI, CLI, async patterns
```
**Pattern**: Always use `LLMProcessor.call_claude()` or `.call_openai()` based on `Config.LLM_PROVIDER`.

### Pydantic Request Models
All endpoints use Pydantic `BaseModel` for validation:
```python
# Example: CodeSuggestionRequest
code: str
language: str  # dart, solidity, javascript, python
context: str = "wealthbridge"
prompt: str
file_path: Optional[str] = None
```
**Pattern**: Validate early, return HTTP 400 for invalid inputs; use Optional fields for config overrides.

### Agent Delegation Pattern
`agent_handoff.py` implements intelligent task routing via keyword matching:
```python
# Pattern: predict_agent() reads task_description + code_language → matches keywords → returns AgentType
# Specialized agents: DART_CAPSULE, SOLIDITY_AUDITOR, TWILIO_INTEGRATOR, GITHUB_APP_AGENT, etc.
# Fallback: DEEPAGENT for unknown tasks
```
**New Feature Implementation**: Add new AgentType enum, define keywords/capabilities, update `predict_agent()`.

### WealthBridge Capsule Conventions (Dart)
From `dart_agent.py`:
- Capsule types: `StatelessWidget`, `StatefulWidget`, `DataProvider`, `Service`, `Model`, `Utility`
- Naming: `{CapsuleName}Capsule` class (e.g., `AP2AffiliateCapule`)
- State class: `_{CapsuleName}CapsuleState` (underscore prefix for private)
- Singletons use factory pattern with `_instance` field
- Always use `const` constructors for performance

### Twilio Integration Pattern
Graceful degradation when Twilio is unconfigured:
```python
# In twilio_service.py
if not self.enabled or not self.client:
    return {"status": "skipped", "reason": "twilio_not_configured"}
# Otherwise: send SMS/voice via Twilio client
```
**Pattern**: Check `Config.TWILIO_ACCOUNT_SID` in init; log warnings, not errors, if disabled.

### Error Handling
- LLM errors: Log with `logger.error()`, raise HTTPException(500)
- Config errors: Raise ValueError in `Config.validate()` to fail fast on startup
- Twilio errors: Log and return failed status in response (don't block requests)
- GitHub webhook: Log event type, handle gracefully if verification fails

---

## 🔌 Integration Points & External Dependencies

### LLM Providers
- **Anthropic Claude**: `from anthropic import Anthropic` → `models.create()` with `claude-3-5-sonnet-20241022`
- **OpenAI GPT-4**: `from openai import OpenAI` → `chat.completions.create()`
- **Routing**: Config.LLM_PROVIDER env var (default: "claude")

### Redis (Message Queue & Caching)
- Initialized in `main.py` lifespan via `redis.from_url(Config.REDIS_URL)`
- Used for: Background task tracking, caching LLM responses, queue management
- Connection: async, with retry/timeout (5s socket connect timeout)

### MongoDB (Data Store)
- Connection string: `Config.MONGODB_URI` (default: `mongodb://localhost:27017/code-catalyst`)
- Currently configured but not actively used in current version; reserve for future state persistence

### Twilio (SMS/Voice)
- `from twilio.rest import Client` → `client.messages.create()` for SMS, `client.calls.create()` for voice
- Credentials: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER`
- TwiML for voice: Generated dynamically for text-to-speech responses

### GitHub App (Webhook)
- Payload verification via `X-Hub-Signature-256` header (in `/api/webhook`)
- Event types: `push`, `pull_request`, `issues`
- Private key: `Config.GITHUB_PRIVATE_KEY` (PEM format)

### Polygon Web3 (Smart Contracts)
- RPC URL: `Config.POLYGON_RPC_URL` (default: mumbai testnet)
- Used for: Smart contract analysis system prompts, potential future integration with Solidity auditor

### Stripe Treasury (Payments)
- Credentials: `STRIPE_API_KEY`, `STRIPE_SECRET_KEY` (optional for MVP)
- Future use: AP2 affiliate payout notifications + confirmations

---

## 🚀 Adding New Features

### New Code Generation Language
1. Add system prompt to `worker.py::SYSTEM_PROMPTS` dict
2. Add to `api.py::CodeSuggestionRequest.language` validation
3. Create specialized agent (e.g., `<language>_agent.py`) if complex patterns needed

### New Communication Channel (e.g., Email, Slack)
1. Create `<channel>_service.py` following Twilio pattern
2. Add graceful degradation (check config, skip if disabled)
3. Add endpoints to `/api/<channel>/*` in `api.py`

### New Specialized Agent
1. Add `AgentType` enum in `agent_handoff.py`
2. Define keywords, capabilities, supported models in `agent_specializations` dict
3. Update `predict_agent()` matching logic
4. Create `<agent>_agent.py` with implementation

### Environment Variables
- Add to `.env.example` with comment explaining purpose
- Add to `config.py::Config` class as class variable with default
- Add validation check to `config.py::Config.validate()` if critical

---

## ⚠️ Common Pitfalls & Best Practices

### Do
- ✅ Use `Config` class for all environment access (centralized, validated)
- ✅ Check `if self.enabled` before using external service (Twilio, etc.)
- ✅ Log context (file_path, language, agent_type) for debugging
- ✅ Use async/await consistently in worker.py and twilio_service.py
- ✅ Return task_id for long-running operations (suggestions, generations)

### Don't
- ❌ Import credentials directly (use `Config` class)
- ❌ Hardcode Twilio phone numbers (use `Config.TWILIO_PHONE_NUMBER`)
- ❌ Assume external services are available (always check enabled status)
- ❌ Block on LLM calls (use background tasks + Redis)
- ❌ Log sensitive data (API keys, private keys)

---

## 📚 Key File Reference

| File | Purpose | Key Functions |
|------|---------|---|
| `backend/app/main.py` | FastAPI app, lifespan | `lifespan()`, health checks |
| `backend/app/config.py` | Env config, validation | `Config.validate()`, `to_dict()` |
| `backend/app/api.py` | REST endpoints (12+) | `suggest`, `generate`, `delegate`, `twilio/*` |
| `backend/app/worker.py` | LLM processing | `LLMProcessor.call_claude/openai()` |
| `backend/app/twilio_service.py` | SMS/Voice | `send_sms()`, `send_voice()`, batch ops |
| `backend/app/agent_handoff.py` | Task delegation | `predict_agent()`, `delegate_task_to_agent()` |
| `backend/app/dart_agent.py` | Dart specialization | `generate_dart_capsule()`, `review_dart_code()` |
| `backend/requirements.txt` | Dependencies | FastAPI, Anthropic, Twilio, etc. |
| `.env.example` | Credential template | 14 environment variables |
| `README.md` | Architecture, use cases | 12 API endpoint overview |

---

## 🎓 Useful References
- **WealthBridge Capsule Patterns**: See `backend/app/dart_agent.py` for StatelessWidget/StatefulWidget templates
- **System Prompts by Language**: `backend/app/worker.py::LLMProcessor.SYSTEM_PROMPTS`
- **Agent Specializations**: `backend/app/agent_handoff.py::AgentType` enum + `agent_specializations` dict
- **API Examples**: `LAUNCH_TODAY.md` and `API_REFERENCE.md` have curl examples for all endpoints
- **Deployment**: `DEPLOYMENT_COMMANDS.md`, `DEPLOYMENT_GUIDE.md`, `deploy.ps1`

---

**Last Updated**: November 18, 2025  
**Status**: Production Ready (v1.0.0)
