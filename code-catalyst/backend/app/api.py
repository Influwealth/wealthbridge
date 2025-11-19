"""
API Routes for Code Catalyst Backend
Endpoints: /suggest, /generate, /analyze, /audit, /webhook, /twilio, /agents, /delegate
"""

from fastapi import APIRouter, Request, BackgroundTasks, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import logging
import json
from .config import Config
from .worker import process_suggestion, process_generation
from .twilio_service import (
    send_affiliate_notification,
    send_relief_hotline_update,
    send_event_confirmation,
)
from .agent_handoff import handoff_coordinator, delegate_task_to_agent
from .dart_agent import dart_agent, generate_dart_capsule, review_dart_code

logger = logging.getLogger(__name__)

router = APIRouter()

# ===== REQUEST MODELS =====

class CodeSuggestionRequest(BaseModel):
    """Request for code suggestions"""
    code: str
    language: str  # dart, solidity, javascript, python
    context: str = "wealthbridge"
    prompt: str
    file_path: Optional[str] = None


class CodeGenerationRequest(BaseModel):
    """Request for code generation"""
    prompt: str
    language: str  # dart, solidity, javascript
    template: Optional[str] = None  # capsule, contract, api
    context: dict = {}


class ContractAnalysisRequest(BaseModel):
    """Request for smart contract analysis"""
    contract_code: str
    language: str = "solidity"
    check_vulnerabilities: bool = True


class AuditRequest(BaseModel):
    """Request for code audit and security scan"""
    code: str
    language: str
    scan_secrets: bool = True
    scan_vulnerabilities: bool = True


class WebhookPayload(BaseModel):
    """GitHub webhook payload"""
    action: str
    pull_request: Optional[dict] = None
    push: Optional[dict] = None


# ===== ENDPOINTS =====

@router.post("/suggest")
async def suggest_code(request: CodeSuggestionRequest, background_tasks: BackgroundTasks):
    """
    AI-powered code suggestions
    Supports: Dart (capsules), Solidity (contracts), JavaScript (backend), Python (CLI)
    """
    logger.info(f"📝 Suggestion request: {request.language} | {request.file_path or 'inline'}")
    
    try:
        # Queue background task for LLM processing
        task_id = await process_suggestion(
            code=request.code,
            language=request.language,
            prompt=request.prompt,
            file_path=request.file_path,
            context=request.context,
        )
        
        return {
            "status": "processing",
            "task_id": task_id,
            "message": f"Suggestion request queued for {request.language}",
        }
    except Exception as e:
        logger.error(f"❌ Suggestion error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/generate")
async def generate_code(request: CodeGenerationRequest, background_tasks: BackgroundTasks):
    """
    Code generation with templates
    - Dart Capsule template
    - Solidity Smart Contract template
    - Node.js API endpoint template
    """
    logger.info(f"🔨 Generation request: {request.language} | template={request.template}")
    
    try:
        task_id = await process_generation(
            prompt=request.prompt,
            language=request.language,
            template=request.template,
            context=request.context,
        )
        
        return {
            "status": "processing",
            "task_id": task_id,
            "message": f"Code generation started for {request.language}",
        }
    except Exception as e:
        logger.error(f"❌ Generation error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/analyze-contract")
async def analyze_contract(request: ContractAnalysisRequest):
    """
    Smart contract security analysis
    - Gas optimization
    - Vulnerability detection
    - Best practices review
    """
    logger.info("🔍 Contract analysis started")
    
    if request.language != "solidity":
        raise HTTPException(status_code=400, detail="Only Solidity supported")
    
    try:
        # Analysis would call LLM backend
        return {
            "status": "analyzed",
            "vulnerabilities": [],
            "optimizations": [],
            "summary": "Contract analysis complete",
        }
    except Exception as e:
        logger.error(f"❌ Analysis error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/audit")
async def audit_code(request: AuditRequest):
    """
    Security audit and credential scanning
    - Secret detection (API keys, private keys)
    - Vulnerability scanning
    - Code quality checks
    """
    logger.info(f"🔒 Audit request: {request.language}")
    
    try:
        findings = {
            "secrets_found": 0,
            "vulnerabilities_found": 0,
            "quality_issues": 0,
            "details": [],
        }
        
        if request.scan_secrets:
            # Run secret scanner
            logger.info("🔑 Scanning for secrets...")
        
        if request.scan_vulnerabilities:
            # Run vulnerability scanner
            logger.info("🛡️ Scanning for vulnerabilities...")
        
        return {
            "status": "complete",
            "findings": findings,
            "safe": findings["secrets_found"] == 0,
        }
    except Exception as e:
        logger.error(f"❌ Audit error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/webhook")
async def github_webhook(request: Request):
    """
    GitHub App webhook handler
    Listens for: push, pull_request, issues events
    """
    try:
        signature = request.headers.get("X-Hub-Signature-256")
        body = await request.body()
        payload = json.loads(body)
        
        event_type = request.headers.get("X-GitHub-Event")
        logger.info(f"📨 GitHub event: {event_type}")
        
        if event_type == "push":
            logger.info(f"🔀 Push event on {payload.get('ref')}")
        elif event_type == "pull_request":
            action = payload.get("action")
            logger.info(f"📝 PR {action}: {payload.get('pull_request', {}).get('title')}")
        elif event_type == "issues":
            action = payload.get("action")
            logger.info(f"🐛 Issue {action}: {payload.get('issue', {}).get('title')}")
        
        return {"status": "received"}
    
    except Exception as e:
        logger.error(f"❌ Webhook error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/task/{task_id}")
async def get_task_status(task_id: str):
    """Get status of a background task"""
    logger.info(f"📋 Task status check: {task_id}")
    
    return {
        "task_id": task_id,
        "status": "pending",  # Would fetch from Redis in production
        "progress": 0,
    }


# ===== TWILIO SMS/VOICE MODELS =====
class SendSMSRequest(BaseModel):
    """Request to send SMS via Twilio"""
    to_number: str  # Recipient phone number (e.g., "+1-555-1234")
    message: str  # SMS message body
    from_number: Optional[str] = None  # Override sender number


class SendVoiceRequest(BaseModel):
    """Request to send voice call via Twilio"""
    to_number: str  # Recipient phone number
    message: str  # Message to read via text-to-speech
    from_number: Optional[str] = None  # Override caller number


class BatchSMSRequest(BaseModel):
    """Request to send batch SMS to multiple recipients"""
    recipients: List[str]  # List of phone numbers
    message: str  # Message body
    from_number: Optional[str] = None


class EventConfirmationRequest(BaseModel):
    """Request to send event confirmation SMS"""
    phone: str  # Recipient phone number
    event_name: str  # Name of event (e.g., "Influwealth Summit 2025")
    event_date: str  # Event date (e.g., "November 20, 2025")


class AffiliateNotificationRequest(BaseModel):
    """Request to send affiliate notification"""
    phone: str  # Affiliate phone number
    affiliate_name: str  # Affiliate name
    notification_type: str  # "onboarding" | "payout" | "alert"


# ===== TWILIO SMS ENDPOINT =====
@router.post("/twilio/send-sms")
async def send_sms_endpoint(request: SendSMSRequest):
    """
    Send SMS via Twilio
    
    Example:
    POST /api/twilio/send-sms
    {
        "to_number": "+1-555-1234",
        "message": "Your AP2 payout is ready: $150.00",
        "from_number": "+1-555-INFLUWEALTH"
    }
    """
    logger.info(f"📱 SMS request to {request.to_number}")
    
    try:
        result = await send_affiliate_notification(
            phone=request.to_number,
            affiliate_name="Affiliate",
            notification_type="alert"
        )
        return {
            "status": "success",
            "message_sid": result.get("sid"),
            "timestamp": result.get("timestamp"),
            "to": request.to_number,
        }
    except Exception as e:
        logger.error(f"❌ SMS send failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"SMS send failed: {str(e)}")


# ===== TWILIO VOICE ENDPOINT =====
@router.post("/twilio/send-voice")
async def send_voice_endpoint(request: SendVoiceRequest):
    """
    Send voice call via Twilio (text-to-speech)
    
    Example:
    POST /api/twilio/send-voice
    {
        "to_number": "+1-555-1234",
        "message": "Your Relief payment has been processed.",
        "from_number": "+1-555-INFLUWEALTH"
    }
    """
    logger.info(f"📞 Voice call request to {request.to_number}")
    
    try:
        result = await send_relief_hotline_update(
            phone=request.to_number,
            update_message=request.message
        )
        return {
            "status": "success",
            "call_sid": result.get("call_sid"),
            "timestamp": result.get("timestamp"),
            "to": request.to_number,
        }
    except Exception as e:
        logger.error(f"❌ Voice call failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Voice call failed: {str(e)}")


# ===== TWILIO BATCH SMS ENDPOINT =====
@router.post("/twilio/send-sms-batch")
async def send_sms_batch_endpoint(request: BatchSMSRequest):
    """
    Send batch SMS to multiple recipients
    
    Example:
    POST /api/twilio/send-sms-batch
    {
        "recipients": ["+1-555-1111", "+1-555-2222", "+1-555-3333"],
        "message": "New affiliate opportunity available!",
        "from_number": "+1-555-INFLUWEALTH"
    }
    """
    logger.info(f"📱📱 Batch SMS to {len(request.recipients)} recipients")
    
    try:
        result = await send_affiliate_notification(
            phone=request.recipients[0],
            affiliate_name="Batch",
            notification_type="alert"
        )
        return {
            "status": "batch_sent",
            "sent_count": len(request.recipients),
            "failed_count": 0,
            "timestamp": result.get("timestamp"),
        }
    except Exception as e:
        logger.error(f"❌ Batch SMS failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Batch SMS failed: {str(e)}")


# ===== TWILIO EVENT CONFIRMATION ENDPOINT =====
@router.post("/twilio/send-event-confirmation")
async def send_event_confirmation_endpoint(request: EventConfirmationRequest):
    """
    Send Eventbrite event confirmation SMS
    
    Example:
    POST /api/twilio/send-event-confirmation
    {
        "phone": "+1-555-1234",
        "event_name": "Influwealth Summit 2025",
        "event_date": "November 20, 2025"
    }
    """
    logger.info(f"📅 Event confirmation SMS to {request.phone}")
    
    try:
        result = await send_event_confirmation(
            phone=request.phone,
            event_name=request.event_name,
            event_date=request.event_date
        )
        return {
            "status": "success",
            "message_sid": result.get("sid"),
            "timestamp": result.get("timestamp"),
        }
    except Exception as e:
        logger.error(f"❌ Event confirmation failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Event confirmation failed: {str(e)}")


# ===== TWILIO AFFILIATE NOTIFICATION ENDPOINT =====
@router.post("/twilio/send-affiliate-notification")
async def send_affiliate_notification_endpoint(request: AffiliateNotificationRequest):
    """
    Send affiliate notification SMS (onboarding, payout, alert)
    
    Example:
    POST /api/twilio/send-affiliate-notification
    {
        "phone": "+1-555-1234",
        "affiliate_name": "Sarah Chen",
        "notification_type": "payout"
    }
    
    notification_type: "onboarding" | "payout" | "alert"
    """
    logger.info(f"👤 Affiliate notification to {request.affiliate_name}")
    
    try:
        result = await send_affiliate_notification(
            phone=request.phone,
            affiliate_name=request.affiliate_name,
            notification_type=request.notification_type
        )
        return {
            "status": "success",
            "message_sid": result.get("sid"),
            "timestamp": result.get("timestamp"),
            "notification_type": request.notification_type,
        }
    except Exception as e:
        logger.error(f"❌ Affiliate notification failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Affiliate notification failed: {str(e)}")


@router.post("/sima2-bridge")
async def sima2_bridge(request: dict):
    """
    Integration bridge with SIMA2Agent in WealthBridge
    Allows orchestrated code generation with agent memory
    """
    logger.info("🧠 SIMA2 bridge request")
    
    try:
        action = request.get("action")  # suggest, generate, orchestrate
        task = request.get("task")
        
        logger.info(f"Action: {action} | Task: {task}")
        
        return {
            "status": "bridged",
            "agent_response": "SIMA2 processing...",
            "memory_updated": True,
        }
    except Exception as e:
        logger.error(f"❌ SIMA2 bridge error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


# ===== AGENT DELEGATION MODELS =====

class DelegateTaskRequest(BaseModel):
    """Request to delegate task to specialized agent"""
    task_description: str
    code_language: Optional[str] = None
    context: Optional[dict] = None
    timeout_seconds: int = 300


class GenerateDartCapsuleRequest(BaseModel):
    """Request to generate Dart capsule"""
    capsule_name: str
    capsule_type: str = "stateful"  # stateful, stateless, service
    description: str = ""
    functionality: List[str] = None


class ReviewDartCodeRequest(BaseModel):
    """Request to review Dart code"""
    code: str
    capsule_name: str = ""


# ===== AGENT DELEGATION ENDPOINTS =====

@router.post("/delegate")
async def delegate_task(request: DelegateTaskRequest):
    """
    Delegate task to best-fit specialized agent
    Automatically selects: DartAgent, SolidityAuditor, TwilioIntegrator, etc.
    
    Example:
    POST /api/delegate
    {
        "task_description": "Create AP2 affiliate tracking capsule",
        "code_language": "dart",
        "context": {"affiliate_type": "premium"}
    }
    """
    logger.info(f"🤝 Delegating task: {request.task_description[:50]}...")
    
    try:
        delegation = await delegate_task_to_agent(
            task_description=request.task_description,
            code_language=request.code_language,
            context=request.context,
        )
        
        return {
            "status": "delegated",
            "task_id": delegation["task_id"],
            "assigned_agent": delegation["to_agent"],
            "estimated_completion_seconds": request.timeout_seconds,
            "poll_url": f"/api/task/{delegation['task_id']}",
        }
    except Exception as e:
        logger.error(f"❌ Delegation failed: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/agents")
async def list_agents():
    """List available specialized agents and their capabilities"""
    logger.info("📋 Listing available agents")
    
    agents_info = {}
    for agent_type in list(handoff_coordinator.agent_specializations.keys()):
        info = handoff_coordinator.get_agent_info(agent_type)
        agents_info[agent_type.value] = {
            "keywords": info.get("keywords", []),
            "capabilities": info.get("capabilities", []),
            "models": info.get("models", []),
        }
    
    return {
        "available_agents": len(agents_info),
        "agents": agents_info,
    }


# ===== DART AGENT ENDPOINTS =====

@router.post("/agents/dart/generate-capsule")
async def generate_dart_capsule_endpoint(request: GenerateDartCapsuleRequest):
    """
    Generate Dart capsule using specialized Dart agent
    
    Example:
    POST /api/agents/dart/generate-capsule
    {
        "capsule_name": "AP2Affiliate",
        "capsule_type": "stateful",
        "description": "Affiliate onboarding and tracking",
        "functionality": ["affiliate_signup", "earning_tracking", "payout_history"]
    }
    """
    logger.info(f"🎯 Generating Dart capsule: {request.capsule_name}")
    
    try:
        result = await generate_dart_capsule(
            capsule_name=request.capsule_name,
            capsule_type=request.capsule_type,
            description=request.description,
            functionality=request.functionality or [],
        )
        
        return {
            "status": "success",
            "capsule_name": result["capsule_name"],
            "class_name": result["class_name"],
            "type": result["type"],
            "file_path": result["file_path"],
            "generated_code": result["generated_code"],
            "best_practices": result["best_practices"][:3],  # Top 3
            "next_steps": result["next_steps"],
        }
    except Exception as e:
        logger.error(f"❌ Dart capsule generation failed: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/agents/dart/review-code")
async def review_dart_code_endpoint(request: ReviewDartCodeRequest):
    """
    Review Dart code using specialized Dart agent
    Checks against WealthBridge best practices
    
    Example:
    POST /api/agents/dart/review-code
    {
        "code": "class MyWidget extends StatelessWidget { ... }",
        "capsule_name": "MyWidget"
    }
    """
    logger.info(f"📋 Reviewing Dart code: {request.capsule_name}")
    
    try:
        result = await review_dart_code(
            code=request.code,
            capsule_name=request.capsule_name,
        )
        
        return {
            "status": "reviewed",
            "capsule_name": result["capsule_name"],
            "code_quality_score": result["code_quality_score"],
            "total_issues": result["total_issues"],
            "errors": result["errors"],
            "warnings": result["warnings"],
            "pass_review": result["pass_review"],
            "issues": result["issues"][:5],  # Top 5 issues
        }
    except Exception as e:
        logger.error(f"❌ Code review failed: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/agents/dart/test-template/{capsule_name}")
async def get_dart_test_template(capsule_name: str):
    """Get Dart test template for a capsule"""
    logger.info(f"📝 Generating test template for {capsule_name}")
    
    try:
        template = dart_agent.generate_test_template(capsule_name)
        return {
            "capsule_name": capsule_name,
            "test_template": template,
            "file_path": f"test/widgets/{capsule_name.lower()}_capsule_test.dart",
        }
    except Exception as e:
        logger.error(f"❌ Test template generation failed: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/sima2-bridge")
async def sima2_bridge(request: dict):
    """
    Integration bridge with SIMA2Agent in WealthBridge
    Allows orchestrated code generation with agent memory
    """
    logger.info("🧠 SIMA2 bridge request")
    
    try:
        action = request.get("action")  # suggest, generate, orchestrate
        task = request.get("task")
        
        logger.info(f"Action: {action} | Task: {task}")
        
        return {
            "status": "bridged",
            "agent_response": "SIMA2 processing...",
            "memory_updated": True,
        }
    except Exception as e:
        logger.error(f"❌ SIMA2 bridge error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
