# 📚 CODE CATALYST - API REFERENCE

**Version**: 1.0  
**Status**: Production Ready  
**Base URL**: `http://localhost:8001` (local) | `https://api.code-catalyst.influwealth.com` (production)  
**Authentication**: API Key (via headers or environment variables)  

---

## Quick Reference

| Endpoint | Method | Purpose | Status |
|----------|--------|---------|--------|
| `/health` | GET | Health check | ✅ Ready |
| `/api/suggest` | POST | Code suggestions | ✅ Ready |
| `/api/generate` | POST | Generate code | ✅ Ready |
| `/api/analyze-contract` | POST | Smart contract analysis | ✅ Ready |
| `/api/audit` | POST | Security audit | ✅ Ready |
| `/api/webhook` | POST | GitHub webhook | ✅ Ready |
| `/api/twilio/send-sms` | POST | Send SMS | ✅ Ready |
| `/api/twilio/send-voice` | POST | Send voice call | ✅ Ready |
| `/api/twilio/send-sms-batch` | POST | Batch SMS | ✅ Ready |
| `/api/twilio/send-event-confirmation` | POST | Event SMS | ✅ Ready |
| `/api/delegate` | POST | Delegate to agent | ✅ NEW |
| `/api/agents` | GET | List agents | ✅ NEW |
| `/api/agents/dart/generate-capsule` | POST | Generate Dart | ✅ NEW |
| `/api/agents/dart/review-code` | POST | Review Dart code | ✅ NEW |
| `/api/agents/dart/test-template/{name}` | GET | Test template | ✅ NEW |

---

## 🏥 Health Check

### `GET /health`

Check API health and service connectivity.

**Request**:
```bash
curl http://localhost:8001/health
```

**Response** (200 OK):
```json
{
  "status": "healthy",
  "timestamp": "2025-11-17T10:30:00Z",
  "version": "1.0.0",
  "services": {
    "redis": "connected",
    "mongodb": "connected",
    "config": "loaded"
  }
}
```

**Error Response** (503 Service Unavailable):
```json
{
  "status": "unhealthy",
  "error": "MongoDB connection failed",
  "services": {
    "redis": "connected",
    "mongodb": "disconnected",
    "config": "loaded"
  }
}
```

---

## 💡 Code Generation

### `POST /api/generate`

Generate code from natural language description.

**Request**:
```bash
curl -X POST http://localhost:8001/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Create a stateful widget for user profile display",
    "language": "dart",
    "context": {
      "framework": "Flutter",
      "package": "wealthbridge"
    }
  }'
```

**Request Body**:
```typescript
{
  prompt: string;           // What to generate (required)
  language: string;         // "dart", "solidity", "python", "javascript", "typescript"
  context?: {              // Additional context (optional)
    framework?: string;
    package?: string;
    style?: string;
  }
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "task_id": "uuid-here",
  "code": "class UserProfileWidget extends StatefulWidget { ... }",
  "language": "dart",
  "lines": 125,
  "quality_score": 92,
  "estimated_token_usage": 450,
  "metadata": {
    "generated_at": "2025-11-17T10:30:00Z",
    "model": "claude-3",
    "execution_time_ms": 2450
  }
}
```

---

## 🔍 Code Review & Suggestions

### `POST /api/suggest`

Get AI suggestions for code improvements.

**Request**:
```bash
curl -X POST http://localhost:8001/api/suggest \
  -H "Content-Type: application/json" \
  -d '{
    "code": "class MyWidget extends StatelessWidget { ... }",
    "language": "dart",
    "prompt": "Add error handling and loading states"
  }'
```

**Request Body**:
```typescript
{
  code: string;             // Code to analyze (required)
  language: string;         // Programming language
  prompt: string;          // What to improve
  file_path?: string;      // Optional file path for context
  context?: string;        // Additional context
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "suggestions": [
    {
      "type": "performance",
      "severity": "high",
      "line": 45,
      "message": "Use const constructor for performance",
      "suggestion": "const MyWidget()"
    },
    {
      "type": "best_practice",
      "severity": "medium",
      "line": 78,
      "message": "Add error handling for async operations",
      "suggestion": "try { ... } catch (e) { ... }"
    }
  ],
  "quality_score": 78,
  "summary": "Good code structure. Add error handling and const constructors."
}
```

---

## 🔐 Security Audit

### `POST /api/audit`

Run comprehensive security audit on code.

**Request**:
```bash
curl -X POST http://localhost:8001/api/audit \
  -H "Content-Type: application/json" \
  -d '{
    "code": "var secret = \"sk-1234567890\"; ...",
    "language": "python",
    "scan_secrets": true,
    "scan_vulnerabilities": true
  }'
```

**Request Body**:
```typescript
{
  code: string;                      // Code to audit
  language: string;                  // Programming language
  scan_secrets?: boolean;            // Scan for hardcoded secrets
  scan_vulnerabilities?: boolean;    // Scan for vulns
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "safe": false,
  "findings": {
    "secrets_found": 1,
    "vulnerabilities_found": 2,
    "quality_issues": 5
  },
  "secrets": [
    {
      "type": "API_KEY",
      "line": 12,
      "content": "sk-1234567890",
      "severity": "critical"
    }
  ],
  "vulnerabilities": [
    {
      "type": "SQL_INJECTION",
      "line": 45,
      "description": "User input not sanitized in SQL query",
      "fix": "Use parameterized queries"
    }
  ]
}
```

---

## 🔗 Agent Delegation (NEW)

### `POST /api/delegate`

Delegate task to specialized agent.

**Request**:
```bash
curl -X POST http://localhost:8001/api/delegate \
  -H "Content-Type: application/json" \
  -d '{
    "task_description": "Create AP2 affiliate tracking capsule with signup and payouts",
    "code_language": "dart",
    "context": {
      "affiliate_type": "premium",
      "features": ["signup", "tracking", "payouts"]
    }
  }'
```

**Request Body**:
```typescript
{
  task_description: string;    // What to do (required)
  code_language: string;       // "dart", "solidity", "python", etc.
  context?: {                  // Task context
    affiliate_type?: string;
    features?: string[];
    [key: string]: any;
  }
  timeout_seconds?: number;    // Default: 60
}
```

**Response** (200 OK):
```json
{
  "status": "delegated",
  "task_id": "task-uuid-1234",
  "assigned_agent": "DART_CAPSULE",
  "agent_description": "Expert Dart/Flutter code generation for WealthBridge capsules",
  "poll_url": "/api/tasks/task-uuid-1234",
  "estimated_completion_ms": 3000,
  "queue_position": 1
}
```

**Poll for Results**:
```bash
curl http://localhost:8001/api/tasks/task-uuid-1234
```

**Result Response**:
```json
{
  "status": "completed",
  "task_id": "task-uuid-1234",
  "agent": "DART_CAPSULE",
  "result": {
    "code": "class AP2AffiliateWidget extends StatefulWidget { ... }",
    "quality_score": 95,
    "capsule_type": "stateful",
    "best_practices_applied": 9,
    "execution_time_ms": 2850
  }
}
```

---

## 📋 List Agents

### `GET /api/agents`

List all available agents and their capabilities.

**Request**:
```bash
curl http://localhost:8001/api/agents
```

**Response** (200 OK):
```json
{
  "agents": [
    {
      "type": "DART_CAPSULE",
      "name": "Dart Capsule Agent",
      "description": "Expert Dart/Flutter code generation for WealthBridge",
      "capabilities": [
        "Generate stateful widgets",
        "Generate stateless widgets",
        "Code review against best practices",
        "Test template generation"
      ],
      "supported_languages": ["dart"],
      "specializations": [
        "Flutter widgets",
        "State management",
        "WealthBridge patterns"
      ],
      "success_rate": "98%",
      "avg_execution_time_ms": 2500
    },
    {
      "type": "SOLIDITY_AUDITOR",
      "name": "Solidity Auditor Agent",
      "description": "Smart contract security analysis",
      "capabilities": [
        "Vulnerability detection",
        "Gas optimization",
        "Security audit"
      ],
      "supported_languages": ["solidity"],
      "specializations": [
        "Security vulnerabilities",
        "Gas optimization",
        "Best practices"
      ],
      "success_rate": "99%",
      "avg_execution_time_ms": 3500
    },
    {
      "type": "TWILIO_INTEGRATOR",
      "name": "Twilio Integrator Agent",
      "description": "SMS and voice workflow generation",
      "capabilities": [
        "SMS templates",
        "Voice call scripts",
        "Batch messaging"
      ],
      "supported_languages": ["python", "javascript", "dart"],
      "specializations": [
        "Message generation",
        "Delivery tracking",
        "Error handling"
      ],
      "success_rate": "96%",
      "avg_execution_time_ms": 1500
    }
    // ... more agents
  ],
  "total_agents": 6,
  "system_status": "healthy"
}
```

---

## 🎯 Dart Agent - Generate Capsule (NEW)

### `POST /api/agents/dart/generate-capsule`

Generate specialized Dart capsule for WealthBridge.

**Request**:
```bash
curl -X POST http://localhost:8001/api/agents/dart/generate-capsule \
  -H "Content-Type: application/json" \
  -d '{
    "capsule_name": "AP2Affiliate",
    "capsule_type": "stateful",
    "description": "Affiliate signup and tracking interface",
    "functionality": ["signup", "profile", "tracking", "payouts"]
  }'
```

**Request Body**:
```typescript
{
  capsule_name: string;        // Name of capsule (required)
  capsule_type: string;        // "stateless_widget", "stateful_widget", "service", "model", "utility", "data_provider"
  description: string;         // What the capsule does
  functionality?: string[];    // Features to include
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "capsule_name": "AP2Affiliate",
  "capsule_type": "stateful",
  "code": "class AP2AffiliateWidget extends StatefulWidget {\n  @override\n  State<AP2AffiliateWidget> createState() => _AP2AffiliateWidgetState();\n}\n\nclass _AP2AffiliateWidgetState extends State<AP2AffiliateWidget> {\n  // Your implementation here\n}\n",
  "test_template": "void main() {\n  testWidgets('AP2Affiliate widget test', (WidgetTester tester) async {\n    // Test implementation\n  });\n}\n",
  "quality_score": 95,
  "best_practices": [
    "Uses StatefulWidget properly",
    "Implements state management",
    "Has error handling",
    "Proper dispose pattern",
    "Const constructors"
  ],
  "metadata": {
    "lines_of_code": 120,
    "generated_at": "2025-11-17T10:30:00Z",
    "template_used": "stateful_widget_v1"
  }
}
```

---

## 🎯 Dart Agent - Review Code (NEW)

### `POST /api/agents/dart/review-code`

Review Dart code against best practices.

**Request**:
```bash
curl -X POST http://localhost:8001/api/agents/dart/review-code \
  -H "Content-Type: application/json" \
  -d '{
    "code": "class MyWidget extends StatelessWidget { ... }",
    "capsule_name": "TestWidget"
  }'
```

**Request Body**:
```typescript
{
  code: string;              // Dart code to review (required)
  capsule_name?: string;     // Name for context
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "capsule_name": "TestWidget",
  "quality_score": 82,
  "issues": [
    {
      "severity": "high",
      "type": "performance",
      "line": 15,
      "message": "Missing const constructor",
      "suggestion": "Add 'const' to constructor"
    },
    {
      "severity": "medium",
      "type": "best_practice",
      "line": 42,
      "message": "No error handling in async operation",
      "suggestion": "Wrap in try-catch"
    }
  ],
  "best_practices_followed": 8,
  "best_practices_violated": 2,
  "recommendations": [
    "Add const constructors for performance",
    "Implement proper error handling",
    "Use proper dispose patterns"
  ]
}
```

---

## 📱 Twilio - Send SMS

### `POST /api/twilio/send-sms`

Send SMS via Twilio.

**Request**:
```bash
curl -X POST http://localhost:8001/api/twilio/send-sms \
  -H "Content-Type: application/json" \
  -d '{
    "to_number": "+1-555-1234",
    "message": "Welcome to Influwealth! Your account is ready.",
    "tags": ["welcome", "new_user"]
  }'
```

**Request Body**:
```typescript
{
  to_number: string;        // Recipient number (required)
  message: string;          // SMS message (required)
  tags?: string[];         // Message tags for tracking
  callback_url?: string;   // Webhook for delivery status
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "message_sid": "SMf1d0c12d9d7e4a5b9c8f7e6d5c4b3a2",
  "to_number": "+1-555-1234",
  "message": "Welcome to Influwealth! Your account is ready.",
  "status": "queued",
  "timestamp": "2025-11-17T10:30:00Z",
  "estimated_delivery_ms": 2000
}
```

---

## 🎙️ Twilio - Send Voice

### `POST /api/twilio/send-voice`

Send voice call via Twilio TTS.

**Request**:
```bash
curl -X POST http://localhost:8001/api/twilio/send-voice \
  -H "Content-Type: application/json" \
  -d '{
    "to_number": "+1-555-1234",
    "message": "Your payment has been processed. Thank you for using Influwealth.",
    "voice": "alice"
  }'
```

**Request Body**:
```typescript
{
  to_number: string;      // Recipient number (required)
  message: string;        // Message to read (required)
  voice?: string;         // "alice", "man", "woman"
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "call_sid": "CAf1d0c12d9d7e4a5b9c8f7e6d5c4b3a2",
  "to_number": "+1-555-1234",
  "message": "Your payment has been processed. Thank you for using Influwealth.",
  "voice": "alice",
  "status": "initiated",
  "timestamp": "2025-11-17T10:30:00Z"
}
```

---

## 📨 Twilio - Batch SMS

### `POST /api/twilio/send-sms-batch`

Send SMS to multiple recipients.

**Request**:
```bash
curl -X POST http://localhost:8001/api/twilio/send-sms-batch \
  -H "Content-Type: application/json" \
  -d '{
    "recipients": ["+1-555-1234", "+1-555-5678", "+1-555-9012"],
    "message": "New affiliate opportunity available! Learn more at influwealth.com",
    "message_type": "affiliate_notification"
  }'
```

**Request Body**:
```typescript
{
  recipients: string[];      // Array of phone numbers (required)
  message: string;          // Message to send (required)
  message_type?: string;    // Type for tracking
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "batch_id": "batch-uuid-1234",
  "total_recipients": 3,
  "successful": 3,
  "failed": 0,
  "messages": [
    {
      "to_number": "+1-555-1234",
      "message_sid": "SMf1d0c...",
      "status": "queued"
    },
    {
      "to_number": "+1-555-5678",
      "message_sid": "SMg2e1d...",
      "status": "queued"
    },
    {
      "to_number": "+1-555-9012",
      "message_sid": "SMh3f2e...",
      "status": "queued"
    }
  ]
}
```

---

## 🔒 Smart Contract Analysis

### `POST /api/analyze-contract`

Analyze Solidity smart contract.

**Request**:
```bash
curl -X POST http://localhost:8001/api/analyze-contract \
  -H "Content-Type: application/json" \
  -d '{
    "contract_code": "pragma solidity ^0.8.0; contract MyToken { ... }",
    "check_vulnerabilities": true
  }'
```

**Request Body**:
```typescript
{
  contract_code: string;         // Solidity code (required)
  check_vulnerabilities?: boolean; // Check for security issues
  language?: string;             // Default: "solidity"
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "vulnerabilities": [
    {
      "type": "REENTRANCY",
      "severity": "critical",
      "line": 42,
      "description": "Potential reentrancy vulnerability",
      "recommendation": "Use checks-effects-interactions pattern"
    }
  ],
  "gas_optimizations": [
    {
      "line": 15,
      "current_gas": "25000",
      "optimized_gas": "15000",
      "suggestion": "Cache state variable reads"
    }
  ],
  "overall_safety_score": 72
}
```

---

## Error Handling

### Standard Error Response

All errors return with appropriate HTTP status codes:

```json
{
  "status": "error",
  "error": "Invalid request format",
  "error_code": "INVALID_INPUT",
  "details": {
    "field": "language",
    "message": "Must be one of: dart, solidity, python, javascript, typescript"
  }
}
```

### Common Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | Success | Request processed |
| 400 | Bad Request | Invalid parameters |
| 401 | Unauthorized | Missing API key |
| 403 | Forbidden | Insufficient permissions |
| 429 | Rate Limited | Too many requests |
| 500 | Server Error | Internal error |
| 503 | Service Unavailable | Services down |

---

## Rate Limiting

All endpoints are rate limited:

```
- Health: Unlimited
- Code Generation: 10 requests/minute
- Code Review: 20 requests/minute
- SMS/Voice: 100 requests/minute
- Delegation: 5 requests/minute
```

**Rate Limit Headers**:
```
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 7
X-RateLimit-Reset: 1700221800
```

---

## Authentication

### API Key (Production)

Include in header:
```bash
curl -H "Authorization: Bearer sk_live_1234567890"
```

Or in query param:
```bash
curl "http://localhost:8001/api/suggest?api_key=sk_live_1234567890"
```

### Local Development

No auth required for local development on localhost:8001

---

## CLI Usage

Use the Typer-based CLI for easier testing:

```bash
# Check health
python cli/codecatalyst-cli.py health

# List agents
python cli/codecatalyst-cli.py agents

# Generate Dart capsule
python cli/codecatalyst-cli.py generate-dart MyWidget stateful

# Review Dart code
python cli/codecatalyst-cli.py review-dart my_code.dart

# Send SMS
python cli/codecatalyst-cli.py send-sms "+1-555-1234" "Test message"

# Run security audit
python cli/codecatalyst-cli.py audit --code "your_code" --language python
```

---

## Examples

### Example 1: Generate AP2 Affiliate Widget
```bash
curl -X POST http://localhost:8001/api/agents/dart/generate-capsule \
  -H "Content-Type: application/json" \
  -d '{
    "capsule_name": "AP2Affiliate",
    "capsule_type": "stateful",
    "description": "Affiliate signup and management",
    "functionality": ["signup", "profile", "tracking", "commission"]
  }'
```

### Example 2: Delegate Complex Task
```bash
curl -X POST http://localhost:8001/api/delegate \
  -H "Content-Type: application/json" \
  -d '{
    "task_description": "Analyze smart contract for security vulnerabilities and suggest optimizations",
    "code_language": "solidity",
    "context": {
      "contract_type": "token",
      "standards": ["ERC20", "upgradeable"]
    }
  }'
```

### Example 3: Send Batch SMS to Affiliates
```bash
curl -X POST http://localhost:8001/api/twilio/send-sms-batch \
  -H "Content-Type: application/json" \
  -d '{
    "recipients": ["+1-555-1000", "+1-555-2000", "+1-555-3000"],
    "message": "New commission tier reached! 🎉 Earn 25% on all referrals. Learn more: influwealth.com/affiliates",
    "message_type": "affiliate_notification"
  }'
```

---

## Support

**Issues or questions?**
- Email: support@influwealth.com
- Discord: [Influwealth Dev Community]
- Docs: https://code-catalyst.influwealth.com/docs
- Status: https://status.code-catalyst.influwealth.com

---

**Last Updated**: November 17, 2025  
**API Version**: 1.0  
**Document Status**: ✅ Production Ready
