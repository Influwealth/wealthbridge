"""
Twilio Communications Service
SMS and voice capabilities for affiliate notifications, events, and alerts
"""

import logging
from typing import Optional, List, Dict
from datetime import datetime

logger = logging.getLogger(__name__)


class TwilioService:
    """Twilio SMS and Voice service wrapper"""
    
    def __init__(self):
        """Initialize Twilio service with credentials from config"""
        try:
            from twilio.rest import Client
            from .config import Config
            
            self.client = Client(Config.TWILIO_ACCOUNT_SID, Config.TWILIO_AUTH_TOKEN)
            self.default_number = Config.TWILIO_PHONE_NUMBER
            self.enabled = bool(Config.TWILIO_ACCOUNT_SID)
            
            if self.enabled:
                logger.info("✅ Twilio service initialized")
            else:
                logger.warning("⚠️ Twilio not configured (SMS/Voice disabled)")
        
        except ImportError:
            logger.error("❌ Twilio package not installed: pip install twilio")
            self.enabled = False
            self.client = None
        
        except Exception as e:
            logger.error(f"❌ Twilio initialization failed: {str(e)}")
            self.enabled = False
            self.client = None
    
    async def send_sms(
        self,
        to_number: str,
        message: str,
        from_number: Optional[str] = None,
    ) -> Dict:
        """
        Send SMS via Twilio
        
        Args:
            to_number: Recipient phone number (e.g., "+1-555-1234")
            message: SMS message body (max 160 chars)
            from_number: Override sender number (uses config default if None)
        
        Returns:
            Dict with: {status, sid, timestamp}
        """
        if not self.enabled or not self.client:
            logger.warning(f"⚠️ Twilio disabled, SMS not sent to {to_number}")
            return {
                "status": "skipped",
                "reason": "twilio_not_configured",
                "timestamp": datetime.utcnow().isoformat(),
            }
        
        try:
            from_num = from_number or self.default_number
            
            message_obj = self.client.messages.create(
                body=message,
                from_=from_num,
                to=to_number,
            )
            
            logger.info(f"✅ SMS sent to {to_number} | SID: {message_obj.sid}")
            
            return {
                "status": "sent",
                "sid": message_obj.sid,
                "to": to_number,
                "timestamp": datetime.utcnow().isoformat(),
            }
        
        except Exception as e:
            logger.error(f"❌ SMS send failed: {str(e)}")
            return {
                "status": "failed",
                "error": str(e),
                "to": to_number,
                "timestamp": datetime.utcnow().isoformat(),
            }
    
    async def send_voice(
        self,
        to_number: str,
        message: str,
        from_number: Optional[str] = None,
    ) -> Dict:
        """
        Send voice call via Twilio with text-to-speech
        
        Args:
            to_number: Recipient phone number
            message: Message to read via TTS
            from_number: Override caller number
        
        Returns:
            Dict with: {status, call_sid, timestamp}
        """
        if not self.enabled or not self.client:
            logger.warning(f"⚠️ Twilio disabled, voice call not sent to {to_number}")
            return {
                "status": "skipped",
                "reason": "twilio_not_configured",
                "timestamp": datetime.utcnow().isoformat(),
            }
        
        try:
            from_num = from_number or self.default_number
            
            # Create TwiML (Twilio Markup Language) for voice
            twiml_message = f'<Response><Say>{message}</Say></Response>'
            
            call = self.client.calls.create(
                to=to_number,
                from_=from_num,
                twiml=twiml_message,
            )
            
            logger.info(f"✅ Voice call initiated to {to_number} | Call SID: {call.sid}")
            
            return {
                "status": "queued",
                "call_sid": call.sid,
                "to": to_number,
                "timestamp": datetime.utcnow().isoformat(),
            }
        
        except Exception as e:
            logger.error(f"❌ Voice call failed: {str(e)}")
            return {
                "status": "failed",
                "error": str(e),
                "to": to_number,
                "timestamp": datetime.utcnow().isoformat(),
            }
    
    async def send_sms_batch(
        self,
        recipients: List[str],
        message: str,
        from_number: Optional[str] = None,
    ) -> Dict:
        """
        Send batch SMS to multiple recipients
        
        Args:
            recipients: List of phone numbers
            message: SMS message body
            from_number: Override sender number
        
        Returns:
            Dict with: {status, sent_count, failed_count, timestamp}
        """
        sent_count = 0
        failed_count = 0
        
        logger.info(f"📱 Sending batch SMS to {len(recipients)} recipients")
        
        for to_number in recipients:
            result = await self.send_sms(to_number, message, from_number)
            if result["status"] == "sent":
                sent_count += 1
            else:
                failed_count += 1
        
        logger.info(f"✅ Batch complete: {sent_count} sent, {failed_count} failed")
        
        return {
            "status": "batch_sent",
            "sent_count": sent_count,
            "failed_count": failed_count,
            "total": len(recipients),
            "timestamp": datetime.utcnow().isoformat(),
        }


# Singleton instance
_twilio_service = None


def get_twilio_service() -> TwilioService:
    """Get or create Twilio service singleton"""
    global _twilio_service
    if _twilio_service is None:
        _twilio_service = TwilioService()
    return _twilio_service


# Integration functions for specific use cases

async def send_affiliate_notification(
    phone: str,
    affiliate_name: str,
    notification_type: str,
) -> Dict:
    """
    Send affiliate notification (onboarding, payout, alert)
    
    Types:
    - "onboarding": Welcome new affiliate
    - "payout": Notify of AP2 payout
    - "alert": Send urgent alert
    """
    service = get_twilio_service()
    
    messages = {
        "onboarding": f"Welcome to Influwealth, {affiliate_name}! Your AP2 affiliate account is ready. Visit https://influwealth.wixsite.com/influwealth-consult to get started.",
        "payout": f"Hi {affiliate_name}, your AP2 payout is processing! Check your dashboard for details. Support: support@influwealth.com",
        "alert": f"Alert for {affiliate_name}: Your affiliate account requires attention. Please contact support@influwealth.com",
    }
    
    message_text = messages.get(notification_type, "Message from Influwealth")
    
    return await service.send_sms(
        to_number=phone,
        message=message_text[:160],  # SMS limit
    )


async def send_relief_hotline_update(
    phone: str,
    update_message: str,
) -> Dict:
    """
    Send Relief hotline update via voice call
    """
    service = get_twilio_service()
    
    return await service.send_voice(
        to_number=phone,
        message=update_message,
    )


async def send_event_confirmation(
    phone: str,
    event_name: str,
    event_date: str,
) -> Dict:
    """
    Send Eventbrite event confirmation SMS
    """
    service = get_twilio_service()
    
    message = f"Confirmed! You're registered for {event_name} on {event_date}. Details: https://influwealth.wixsite.com/influwealth-consult"
    
    return await service.send_sms(
        to_number=phone,
        message=message[:160],
    )
