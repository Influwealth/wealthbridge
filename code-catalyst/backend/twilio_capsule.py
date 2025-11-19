"""
Twilio Capsule - SMS & Voice Notifications
Ready for Influwealth WealthBridge Integration

This capsule handles all SMS and voice communication needs:
- Client notifications
- Campaign broadcasts
- Reminders and alerts
- Verification codes
"""

import os
from typing import Dict, Optional, List
from datetime import datetime
import logging
from enum import Enum

# Try to import Twilio, fallback gracefully
try:
    from twilio.rest import Client
    TWILIO_AVAILABLE = True
except ImportError:
    TWILIO_AVAILABLE = False
    logging.warning("⚠️ Twilio SDK not installed. Install: pip install twilio")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ============================================================================
# ENUMS & MODELS
# ============================================================================

class MessageType(Enum):
    """Message type classifications"""
    WELCOME = "welcome"
    VERIFICATION = "verification"
    NOTIFICATION = "notification"
    REMINDER = "reminder"
    CAMPAIGN = "campaign"
    ALERT = "alert"
    TRANSACTION = "transaction"

class DeliveryStatus(Enum):
    """Message delivery status"""
    QUEUED = "queued"
    SENT = "sent"
    DELIVERED = "delivered"
    FAILED = "failed"
    BOUNCED = "bounced"

# ============================================================================
# TWILIO CAPSULE
# ============================================================================

class TwilioCapsule:
    """
    Twilio integration capsule for Influwealth
    
    Handles SMS and voice communications
    Integrates with VaultGemma for credential management
    """
    
    def __init__(self):
        """Initialize Twilio client"""
        self.client = None
        self.account_sid = None
        self.auth_token = None
        self.phone_number = None
        self.initialized = False
        
        self._initialize_client()
    
    def _initialize_client(self):
        """Initialize Twilio client from VaultGemma credentials"""
        if not TWILIO_AVAILABLE:
            logger.warning("Twilio SDK not available - SMS disabled")
            return
        
        try:
            # Get credentials from environment (injected from VaultGemma)
            self.account_sid = os.getenv("TWILIO_ACCOUNT_SID")
            self.auth_token = os.getenv("TWILIO_AUTH_TOKEN")
            self.phone_number = os.getenv("TWILIO_PHONE_NUMBER")
            
            if all([self.account_sid, self.auth_token, self.phone_number]):
                self.client = Client(self.account_sid, self.auth_token)
                self.initialized = True
                logger.info("✅ Twilio capsule initialized")
            else:
                logger.error("❌ Missing Twilio credentials in environment")
        
        except Exception as e:
            logger.error(f"❌ Twilio initialization failed: {e}")
    
    def send_sms(
        self,
        to: str,
        message: str,
        message_type: MessageType = MessageType.NOTIFICATION,
        campaign_id: Optional[str] = None,
        metadata: Optional[Dict] = None
    ) -> Dict:
        """
        Send SMS message
        
        Args:
            to: Recipient phone number (E.164 format: +1234567890)
            message: Message body (max 160 chars, or SMS will be split)
            message_type: Type of message for logging/analytics
            campaign_id: Optional campaign reference
            metadata: Optional metadata for tracking
        
        Returns:
            Dict with status, SID, and delivery info
        """
        
        if not self.initialized:
            logger.error("❌ Twilio not initialized - SMS not sent")
            return {
                "status": "failed",
                "error": "twilio_not_initialized",
                "message_type": message_type.value
            }
        
        try:
            logger.info(f"📤 Sending SMS to {to}")
            logger.info(f"   Type: {message_type.value}")
            logger.info(f"   Length: {len(message)} chars")
            
            # Send SMS via Twilio
            msg = self.client.messages.create(
                from_=self.phone_number,
                to=to,
                body=message,
                # Optional: Add tags for analytics
                tags={
                    "campaign_id": campaign_id or "none",
                    "message_type": message_type.value,
                    "platform": "influwealth"
                }
            )
            
            logger.info(f"✅ SMS sent: {msg.sid}")
            
            return {
                "status": "sent",
                "sid": msg.sid,
                "to": to,
                "message_type": message_type.value,
                "campaign_id": campaign_id,
                "sent_at": datetime.now().isoformat(),
                "delivery_status": DeliveryStatus.SENT.value,
                "metadata": metadata or {}
            }
        
        except Exception as e:
            logger.error(f"❌ SMS send failed: {e}")
            return {
                "status": "failed",
                "error": str(e),
                "to": to,
                "message_type": message_type.value,
                "campaign_id": campaign_id
            }
    
    def send_voice_call(
        self,
        to: str,
        message: str,
        message_type: MessageType = MessageType.NOTIFICATION,
        campaign_id: Optional[str] = None
    ) -> Dict:
        """
        Send voice call notification (TwiML required)
        
        Args:
            to: Recipient phone number
            message: Message to speak
            message_type: Type of call
            campaign_id: Optional campaign reference
        
        Returns:
            Dict with call status
        """
        
        if not self.initialized:
            logger.error("❌ Twilio not initialized - call not made")
            return {
                "status": "failed",
                "error": "twilio_not_initialized"
            }
        
        try:
            logger.info(f"📞 Making voice call to {to}")
            
            # Create TwiML for message
            twiml = f'''<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say>{message}</Say>
    <Pause length="1"/>
    <Say>Press 1 to confirm, or hang up.</Say>
</Response>'''
            
            # Initiate call
            call = self.client.calls.create(
                from_=self.phone_number,
                to=to,
                twiml=twiml
            )
            
            logger.info(f"✅ Voice call initiated: {call.sid}")
            
            return {
                "status": "initiated",
                "sid": call.sid,
                "to": to,
                "message_type": message_type.value,
                "campaign_id": campaign_id,
                "created_at": datetime.now().isoformat()
            }
        
        except Exception as e:
            logger.error(f"❌ Voice call failed: {e}")
            return {
                "status": "failed",
                "error": str(e),
                "to": to
            }
    
    def send_bulk_sms(
        self,
        recipients: List[str],
        message: str,
        message_type: MessageType = MessageType.CAMPAIGN,
        campaign_id: Optional[str] = None
    ) -> Dict:
        """
        Send SMS to multiple recipients
        
        Args:
            recipients: List of phone numbers
            message: Message to send to all
            message_type: Type of message
            campaign_id: Campaign reference
        
        Returns:
            Dict with results and statistics
        """
        
        results = {
            "campaign_id": campaign_id,
            "message_type": message_type.value,
            "total": len(recipients),
            "sent": 0,
            "failed": 0,
            "messages": [],
            "started_at": datetime.now().isoformat()
        }
        
        for phone in recipients:
            result = self.send_sms(
                to=phone,
                message=message,
                message_type=message_type,
                campaign_id=campaign_id
            )
            
            results["messages"].append(result)
            
            if result["status"] == "sent":
                results["sent"] += 1
            else:
                results["failed"] += 1
        
        results["completed_at"] = datetime.now().isoformat()
        results["success_rate"] = (results["sent"] / results["total"] * 100) if results["total"] > 0 else 0
        
        logger.info(f"📊 Bulk SMS campaign complete: {results['sent']}/{results['total']} sent")
        
        return results
    
    def get_message_status(self, message_sid: str) -> Dict:
        """
        Get delivery status of a specific message
        
        Args:
            message_sid: Twilio message SID
        
        Returns:
            Dict with delivery status
        """
        
        if not self.initialized:
            return {"status": "unknown", "error": "twilio_not_initialized"}
        
        try:
            msg = self.client.messages(message_sid).fetch()
            
            return {
                "sid": msg.sid,
                "status": msg.status,
                "from": msg.from_,
                "to": msg.to,
                "body": msg.body[:50] + "..." if len(msg.body) > 50 else msg.body,
                "sent": msg.date_sent.isoformat() if msg.date_sent else None,
                "error_code": msg.error_code,
                "error_message": msg.error_message
            }
        
        except Exception as e:
            logger.error(f"❌ Status check failed: {e}")
            return {
                "sid": message_sid,
                "status": "unknown",
                "error": str(e)
            }
    
    def send_verification_code(
        self,
        to: str,
        code: str,
        expires_in_minutes: int = 10
    ) -> Dict:
        """
        Send verification code (specialized SMS)
        
        Args:
            to: Recipient phone number
            code: Verification code
            expires_in_minutes: Code expiration time
        
        Returns:
            Dict with delivery status
        """
        
        message = f"Your Influwealth verification code is: {code}\n\n" \
                 f"This code expires in {expires_in_minutes} minutes.\n" \
                 f"Do not share this code with anyone."
        
        return self.send_sms(
            to=to,
            message=message,
            message_type=MessageType.VERIFICATION
        )
    
    def send_welcome_message(
        self,
        to: str,
        client_name: str,
        affiliate_key: str,
        portal_url: str
    ) -> Dict:
        """
        Send welcome message to new client
        
        Args:
            to: Recipient phone number
            client_name: Client's name
            affiliate_key: Affiliate key for portal
            portal_url: Portal URL
        
        Returns:
            Dict with delivery status
        """
        
        message = f"Welcome to Influwealth, {client_name}! 🌟\n\n" \
                 f"Your personal wealth dashboard is ready.\n\n" \
                 f"👉 {portal_url}\n\n" \
                 f"Questions? Reply HELP or contact support."
        
        return self.send_sms(
            to=to,
            message=message,
            message_type=MessageType.WELCOME
        )
    
    def send_reminder(
        self,
        to: str,
        reminder_text: str,
        action_url: Optional[str] = None
    ) -> Dict:
        """
        Send reminder message
        
        Args:
            to: Recipient phone number
            reminder_text: Reminder message
            action_url: Optional URL for action
        
        Returns:
            Dict with delivery status
        """
        
        message = f"📝 Reminder: {reminder_text}"
        if action_url:
            message += f"\n\n👉 {action_url}"
        
        return self.send_sms(
            to=to,
            message=message,
            message_type=MessageType.REMINDER
        )
    
    def health_check(self) -> Dict:
        """
        Health check for Twilio connection
        
        Returns:
            Dict with status
        """
        
        if not self.initialized:
            return {
                "status": "offline",
                "reason": "Not initialized",
                "credentials": "missing"
            }
        
        try:
            # Try to fetch account info
            account = self.client.api.accounts(self.account_sid).fetch()
            
            return {
                "status": "healthy",
                "account_sid": self.account_sid[:20] + "...",
                "account_status": account.status,
                "phone_number": self.phone_number,
                "timestamp": datetime.now().isoformat()
            }
        
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }


# ============================================================================
# CAPSULE ENDPOINTS
# ============================================================================

# These would be registered in the FastAPI backend:
"""
from twilio_capsule import TwilioCapsule

capsule = TwilioCapsule()

@router.post("/twilio/send-sms")
def send_sms(to: str, message: str, campaign_id: str = None):
    return capsule.send_sms(to, message, campaign_id=campaign_id)

@router.post("/twilio/send-voice")
def send_voice(to: str, message: str):
    return capsule.send_voice_call(to, message)

@router.post("/twilio/bulk-sms")
def bulk_sms(recipients: List[str], message: str, campaign_id: str = None):
    return capsule.send_bulk_sms(recipients, message, campaign_id=campaign_id)

@router.get("/twilio/status/{sid}")
def message_status(sid: str):
    return capsule.get_message_status(sid)

@router.get("/twilio/health")
def health():
    return capsule.health_check()
"""

# ============================================================================
# USAGE EXAMPLES
# ============================================================================

if __name__ == "__main__":
    # Initialize
    twilio = TwilioCapsule()
    
    # Send welcome SMS
    result = twilio.send_welcome_message(
        to="+12025551234",
        client_name="John Doe",
        affiliate_key="abc123def456",
        portal_url="https://portal.influwealth.io?key=abc123def456"
    )
    print("Welcome SMS:", result)
    
    # Send bulk campaign
    campaign_result = twilio.send_bulk_sms(
        recipients=["+12025551234", "+12025555678"],
        message="New wealth strategies available in your dashboard!",
        message_type=MessageType.CAMPAIGN,
        campaign_id="camp_nov2025_1"
    )
    print("Campaign results:", campaign_result)
    
    # Health check
    health = twilio.health_check()
    print("Capsule health:", health)

