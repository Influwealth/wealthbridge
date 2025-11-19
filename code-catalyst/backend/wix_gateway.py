"""
Argus-Prime Gateway - Wix Webhook Handler
Central hub for intake processing, credential management, and service orchestration

This module handles:
1. Wix lead form submissions
2. Twilio SMS notification triggers
3. AnythingLLM workspace creation
4. Intake ticket generation
5. Affiliate key generation
"""

from fastapi import APIRouter, Depends, HTTPException, Header, BackgroundTasks
from fastapi.responses import JSONResponse
from typing import Dict, Optional, List
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime, timedelta
import uuid
import logging
import json
from enum import Enum

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize router
router = APIRouter(prefix="/wix", tags=["wix-integration"])

# ============================================================================
# DATA MODELS
# ============================================================================

class GoalType(str, Enum):
    """Client goal types"""
    STARTUP = "startup"
    SMALL_BUSINESS = "small-business"
    REAL_ESTATE = "real-estate"
    EXECUTIVE = "executive"
    STUDENT = "student"
    GENERAL = "general"

class LeadSourceType(str, Enum):
    """Lead source tracking"""
    WIX_FORM = "wix-form"
    AFFILIATE = "affiliate"
    PARTNER = "partner"
    REFERRAL = "referral"
    ORGANIC = "organic"

class IntakeTicket(BaseModel):
    """Intake ticket model"""
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    state: str
    goal: GoalType = GoalType.GENERAL
    campaign: str = "organic"
    referral: str = "direct"
    source: LeadSourceType = LeadSourceType.WIX_FORM
    created_at: str = Field(default_factory=lambda: datetime.now().isoformat())
    status: str = "intake_received"
    affiliate_key: str = Field(default_factory=lambda: str(uuid.uuid4())[:20])
    portal_url: str = ""
    workspace_id: Optional[str] = None
    workspace_slug: Optional[str] = None

class WixWebhookPayload(BaseModel):
    """Wix webhook payload"""
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    state: str
    goal: str = "general"
    campaign: str = "organic"
    referral: str = "direct"
    source: str = "wix-form"
    timestamp: str = Field(default_factory=lambda: datetime.now().isoformat())

class WixWebhookResponse(BaseModel):
    """Wix webhook response"""
    status: str
    id: str
    affiliateKey: str
    portalUrl: str
    templateWorkspaceId: Optional[str] = None
    message: str

# ============================================================================
# IN-MEMORY STORAGE (Replace with real DB)
# ============================================================================

class IntakeStore:
    """Simple in-memory intake storage"""
    
    def __init__(self):
        self.intakes: Dict[str, IntakeTicket] = {}
        self.affiliates: Dict[str, IntakeTicket] = {}
    
    def create(self, ticket: IntakeTicket) -> IntakeTicket:
        """Store intake ticket"""
        self.intakes[ticket.id] = ticket
        self.affiliates[ticket.affiliate_key] = ticket
        logger.info(f"✅ Intake created: {ticket.id}")
        return ticket
    
    def get_by_id(self, intake_id: str) -> Optional[IntakeTicket]:
        """Retrieve by intake ID"""
        return self.intakes.get(intake_id)
    
    def get_by_affiliate_key(self, key: str) -> Optional[IntakeTicket]:
        """Retrieve by affiliate key"""
        return self.affiliates.get(key)
    
    def list_recent(self, limit: int = 10) -> List[IntakeTicket]:
        """List recent intakes"""
        return sorted(
            self.intakes.values(),
            key=lambda x: x.created_at,
            reverse=True
        )[:limit]

# Initialize store
intake_store = IntakeStore()

# ============================================================================
# INTEGRATION FUNCTIONS
# ============================================================================

def send_welcome_sms(
    phone: str,
    client_name: str,
    affiliate_key: str,
    portal_url: str
) -> Dict:
    """Send welcome SMS via Twilio capsule"""
    
    message = f"Welcome to Influwealth, {client_name}! 🌟\n\n" \
             f"Your personal wealth dashboard is ready.\n\n" \
             f"👉 {portal_url}\n\n" \
             f"Questions? Reply HELP or contact support."
    
    logger.info(f"📱 Sending welcome SMS to {phone}")
    
    # TODO: Call Twilio capsule
    # For now, just log
    
    return {
        "status": "sent",
        "phone": phone,
        "message_type": "welcome"
    }

def create_anythingllm_workspace(
    intake: IntakeTicket
) -> Dict:
    """Create AnythingLLM workspace for client"""
    
    workspace_slug = f"wealth-{intake.affiliate_key[:8]}".lower()
    
    logger.info(f"🤖 Creating AnythingLLM workspace: {workspace_slug}")
    
    # TODO: Call AnythingLLM API to create workspace
    # Would include:
    # - Workspace name: "{client_name}'s Wealth Coach"
    # - Seed documents with onboarding content
    # - Configure models (Anthropic preferred)
    # - Set up system prompt for wealth guidance
    
    return {
        "status": "created",
        "workspace_slug": workspace_slug,
        "workspace_id": f"ws_{intake.id[:8]}",
        "template_id": "influwealth_client_template"
    }

def create_affiliate_key(intake: IntakeTicket) -> str:
    """Generate unique affiliate key for portal access"""
    
    # Format: 'aff_' + timestamp + random
    key = f"aff_{datetime.now().strftime('%Y%m%d')}_{intake.id[:8]}"
    logger.info(f"🔑 Generated affiliate key: {key}")
    return key

def store_intake_to_database(intake: IntakeTicket) -> bool:
    """Persist intake to database"""
    
    logger.info(f"💾 Storing intake to database: {intake.id}")
    intake_store.create(intake)
    return True

def send_internal_notification(intake: IntakeTicket) -> bool:
    """Send notification to admin team"""
    
    message = f"""
    📋 NEW INTAKE RECEIVED
    
    Name: {intake.name}
    Email: {intake.email}
    Phone: {intake.phone}
    State: {intake.state}
    Goal: {intake.goal.value}
    Campaign: {intake.campaign}
    Affiliate Key: {intake.affiliate_key}
    Created: {intake.created_at}
    """
    
    logger.info(f"📢 Internal notification: {intake.name}")
    
    # TODO: Send to Slack/Discord/Email
    # For now, just log
    
    return True

# ============================================================================
# WIX WEBHOOK HANDLER
# ============================================================================

@router.post("/webhook", response_model=WixWebhookResponse)
async def wix_webhook(
    payload: WixWebhookPayload,
    background_tasks: BackgroundTasks,
    authorization: Optional[str] = Header(None)
) -> WixWebhookResponse:
    """
    Main Wix webhook handler
    
    Process incoming leads from Wix form submission
    Create intake, generate affiliate key, send SMS, create workspace
    
    Expected payload:
    {
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+12025551234",
        "state": "NY",
        "goal": "startup",
        "campaign": "organic",
        "referral": "google"
    }
    """
    
    try:
        # ================================================================
        # 1. CREATE INTAKE TICKET
        # ================================================================
        
        logger.info(f"📥 Processing Wix webhook: {payload.name}")
        
        intake = IntakeTicket(
            name=payload.name,
            email=payload.email,
            phone=payload.phone,
            state=payload.state,
            goal=GoalType(payload.goal) if payload.goal in [g.value for g in GoalType] else GoalType.GENERAL,
            campaign=payload.campaign,
            referral=payload.referral,
            source=LeadSourceType.WIX_FORM
        )
        
        logger.info(f"✅ Intake created: {intake.id}")
        
        # ================================================================
        # 2. GENERATE AFFILIATE KEY
        # ================================================================
        
        intake.affiliate_key = create_affiliate_key(intake)
        intake.portal_url = f"https://portal.influwealth.io?key={intake.affiliate_key}"
        
        logger.info(f"✅ Portal URL: {intake.portal_url}")
        
        # ================================================================
        # 3. CREATE ANYTHINGLLM WORKSPACE (background task)
        # ================================================================
        
        ws_result = create_anythingllm_workspace(intake)
        intake.workspace_id = ws_result.get("workspace_id")
        intake.workspace_slug = ws_result.get("workspace_slug")
        
        logger.info(f"✅ Workspace created: {intake.workspace_slug}")
        
        # ================================================================
        # 4. STORE INTAKE
        # ================================================================
        
        store_intake_to_database(intake)
        
        # ================================================================
        # 5. SEND WELCOME SMS (background task)
        # ================================================================
        
        if intake.phone:
            background_tasks.add_task(
                send_welcome_sms,
                phone=intake.phone,
                client_name=intake.name,
                affiliate_key=intake.affiliate_key,
                portal_url=intake.portal_url
            )
            logger.info(f"📱 SMS queued for: {intake.phone}")
        
        # ================================================================
        # 6. SEND INTERNAL NOTIFICATION (background task)
        # ================================================================
        
        background_tasks.add_task(send_internal_notification, intake)
        
        # ================================================================
        # 7. RETURN SUCCESS RESPONSE
        # ================================================================
        
        response = WixWebhookResponse(
            status="success",
            id=intake.id,
            affiliateKey=intake.affiliate_key,
            portalUrl=intake.portal_url,
            templateWorkspaceId=intake.workspace_id,
            message=f"✅ Welcome {intake.name}! Your Influwealth portal is ready."
        )
        
        logger.info(f"✅ Webhook complete: {intake.id}")
        return response
    
    except Exception as e:
        logger.error(f"❌ Webhook error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Webhook processing failed: {str(e)}"
        )

# ============================================================================
# SUPPORT ENDPOINTS
# ============================================================================

@router.get("/intake/{intake_id}")
async def get_intake(intake_id: str) -> Dict:
    """Retrieve intake details by ID"""
    
    intake = intake_store.get_by_id(intake_id)
    
    if not intake:
        raise HTTPException(status_code=404, detail="Intake not found")
    
    return {
        "status": "found",
        "intake": intake.dict(),
        "timestamp": datetime.now().isoformat()
    }

@router.get("/affiliate/{affiliate_key}")
async def get_affiliate_info(affiliate_key: str) -> Dict:
    """Retrieve client info by affiliate key"""
    
    intake = intake_store.get_by_affiliate_key(affiliate_key)
    
    if not intake:
        raise HTTPException(status_code=404, detail="Invalid affiliate key")
    
    # Don't expose sensitive info
    return {
        "status": "valid",
        "name": intake.name,
        "state": intake.state,
        "goal": intake.goal.value,
        "workspace_id": intake.workspace_id,
        "portal_url": intake.portal_url,
        "created_at": intake.created_at
    }

@router.get("/intakes/recent")
async def get_recent_intakes(limit: int = 10) -> Dict:
    """Get recently created intakes"""
    
    intakes = intake_store.list_recent(limit)
    
    return {
        "status": "success",
        "count": len(intakes),
        "intakes": [i.dict() for i in intakes],
        "timestamp": datetime.now().isoformat()
    }

@router.post("/intake/{intake_id}/update-status")
async def update_intake_status(
    intake_id: str,
    status: str
) -> Dict:
    """Update intake status"""
    
    intake = intake_store.get_by_id(intake_id)
    
    if not intake:
        raise HTTPException(status_code=404, detail="Intake not found")
    
    intake.status = status
    
    logger.info(f"✅ Intake status updated: {intake_id} → {status}")
    
    return {
        "status": "updated",
        "intake_id": intake_id,
        "new_status": status,
        "timestamp": datetime.now().isoformat()
    }

@router.get("/health")
async def health() -> Dict:
    """Health check endpoint"""
    
    return {
        "status": "healthy",
        "service": "wix-gateway",
        "timestamp": datetime.now().isoformat(),
        "intakes_processed": len(intake_store.intakes)
    }

# ============================================================================
# STATISTICS & ANALYTICS
# ============================================================================

@router.get("/stats/summary")
async def get_stats() -> Dict:
    """Get intake statistics"""
    
    intakes = intake_store.intakes.values()
    
    # Calculate stats
    total = len(intakes)
    by_goal = {}
    by_state = {}
    
    for intake in intakes:
        goal = intake.goal.value
        state = intake.state
        
        by_goal[goal] = by_goal.get(goal, 0) + 1
        by_state[state] = by_state.get(state, 0) + 1
    
    return {
        "status": "success",
        "total_intakes": total,
        "by_goal": by_goal,
        "by_state": by_state,
        "timestamp": datetime.now().isoformat()
    }

# ============================================================================
# INTEGRATION INSTRUCTIONS
# ============================================================================

"""
Integration with main Argus-Prime FastAPI app:

```python
from fastapi import FastAPI
from wix_gateway import router as wix_router

app = FastAPI()
app.include_router(wix_router)
```

The handler will then be available at:
- POST /wix/webhook - Main intake processing
- GET /wix/intake/{intake_id} - Retrieve intake
- GET /wix/affiliate/{key} - Retrieve by affiliate key
- GET /wix/intakes/recent - List recent intakes
- GET /wix/health - Health check
- GET /wix/stats/summary - Statistics

Environment variables needed:
- ADMIN_JWT_TOKEN: JWT for admin operations
- ANYTHINGLLM_API_URL: AnythingLLM API endpoint
- ANYTHINGLLM_API_KEY: AnythingLLM admin key
- TWILIO_API_ENDPOINT: Twilio capsule endpoint
"""

