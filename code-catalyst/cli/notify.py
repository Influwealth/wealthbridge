#!/usr/bin/env python3
"""
Code Catalyst Notify Command
Broadcast notifications via SMS, email, and other channels

Usage:
    codecatalyst notify --channel sms --message "Hello from CodeCatalyst"
    codecatalyst notify --channel email --to support@team.com --subject "Deployment complete"
    codecatalyst notify --channel slack --webhook-url https://hooks.slack.com/... --text "Build succeeded"
"""

import argparse
import sys
import os
import json
import requests
from typing import Dict, Optional
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger(__name__)

# ============================================================================
# NOTIFICATION CHANNELS
# ============================================================================

class NotificationChannel:
    """Base class for notification channels"""
    
    def __init__(self):
        self.name = "base"
        self.required_fields = []
    
    def send(self, **kwargs) -> Dict:
        raise NotImplementedError

class SMSChannel(NotificationChannel):
    """SMS notifications via Twilio"""
    
    def __init__(self):
        super().__init__()
        self.name = "sms"
        self.required_fields = ["message"]
        self.api_endpoint = "http://localhost:8000/twilio/send-sms"
    
    def send(self, message: str, to: Optional[str] = None, **kwargs) -> Dict:
        """Send SMS notification"""
        
        phone = to or self._get_broadcast_phone()
        
        if not phone:
            return {"status": "error", "message": "No phone number provided"}
        
        try:
            logger.info(f"📱 Sending SMS to {phone}...")
            
            response = requests.post(
                self.api_endpoint,
                json={"to": phone, "message": message},
                timeout=10
            )
            
            if response.ok:
                data = response.json()
                logger.info(f"✅ SMS sent: {data.get('sid', 'N/A')}")
                return {"status": "sent", "channel": "sms", "data": data}
            else:
                logger.error(f"❌ SMS failed: {response.status_code}")
                return {"status": "error", "channel": "sms", "error": response.text}
        
        except Exception as e:
            logger.error(f"❌ SMS error: {e}")
            return {"status": "error", "channel": "sms", "error": str(e)}
    
    def _get_broadcast_phone(self) -> Optional[str]:
        """Get default broadcast phone from environment"""
        return os.getenv("BROADCAST_PHONE_NUMBER")

class EmailChannel(NotificationChannel):
    """Email notifications"""
    
    def __init__(self):
        super().__init__()
        self.name = "email"
        self.required_fields = ["subject", "body"]
        self.api_endpoint = "http://localhost:8000/email/send"
    
    def send(self, to: str, subject: str, body: str, **kwargs) -> Dict:
        """Send email notification"""
        
        logger.info(f"📧 Sending email to {to}...")
        
        try:
            response = requests.post(
                self.api_endpoint,
                json={
                    "to": to,
                    "subject": subject,
                    "body": body,
                    "html": True
                },
                timeout=10
            )
            
            if response.ok:
                logger.info("✅ Email sent")
                return {"status": "sent", "channel": "email"}
            else:
                logger.error(f"❌ Email failed: {response.status_code}")
                return {"status": "error", "channel": "email", "error": response.text}
        
        except Exception as e:
            logger.error(f"❌ Email error: {e}")
            return {"status": "error", "channel": "email", "error": str(e)}

class SlackChannel(NotificationChannel):
    """Slack notifications via webhook"""
    
    def __init__(self):
        super().__init__()
        self.name = "slack"
        self.required_fields = ["text"]
    
    def send(self, text: str, webhook_url: Optional[str] = None, 
             color: str = "#36a64f", title: str = "Code Catalyst", **kwargs) -> Dict:
        """Send Slack notification"""
        
        url = webhook_url or os.getenv("SLACK_WEBHOOK_URL")
        
        if not url:
            logger.error("❌ No Slack webhook URL provided")
            return {"status": "error", "channel": "slack", "error": "No webhook URL"}
        
        logger.info("🔔 Sending Slack notification...")
        
        try:
            payload = {
                "attachments": [{
                    "color": color,
                    "title": title,
                    "text": text,
                    "footer": "Code Catalyst",
                    "ts": int(datetime.now().timestamp())
                }]
            }
            
            response = requests.post(url, json=payload, timeout=10)
            
            if response.ok:
                logger.info("✅ Slack notification sent")
                return {"status": "sent", "channel": "slack"}
            else:
                logger.error(f"❌ Slack failed: {response.status_code}")
                return {"status": "error", "channel": "slack"}
        
        except Exception as e:
            logger.error(f"❌ Slack error: {e}")
            return {"status": "error", "channel": "slack", "error": str(e)}

class DiscordChannel(NotificationChannel):
    """Discord notifications"""
    
    def __init__(self):
        super().__init__()
        self.name = "discord"
        self.required_fields = ["text"]
    
    def send(self, text: str, webhook_url: Optional[str] = None, **kwargs) -> Dict:
        """Send Discord notification"""
        
        url = webhook_url or os.getenv("DISCORD_WEBHOOK_URL")
        
        if not url:
            logger.error("❌ No Discord webhook URL provided")
            return {"status": "error", "channel": "discord", "error": "No webhook URL"}
        
        logger.info("🎮 Sending Discord notification...")
        
        try:
            payload = {
                "content": text,
                "username": "Code Catalyst",
                "avatar_url": "https://platform.slack-edge.com/img/default_application_icon.png"
            }
            
            response = requests.post(url, json=payload, timeout=10)
            
            if response.ok:
                logger.info("✅ Discord notification sent")
                return {"status": "sent", "channel": "discord"}
            else:
                logger.error(f"❌ Discord failed: {response.status_code}")
                return {"status": "error", "channel": "discord"}
        
        except Exception as e:
            logger.error(f"❌ Discord error: {e}")
            return {"status": "error", "channel": "discord", "error": str(e)}

class ConsoleChannel(NotificationChannel):
    """Local console output"""
    
    def __init__(self):
        super().__init__()
        self.name = "console"
        self.required_fields = ["message"]
    
    def send(self, message: str, **kwargs) -> Dict:
        """Print to console"""
        
        print("\n" + "="*60)
        print(f"📢 {message}")
        print("="*60 + "\n")
        
        return {"status": "printed", "channel": "console"}

# ============================================================================
# NOTIFICATION BUILDER
# ============================================================================

class NotificationBuilder:
    """Build and send notifications to multiple channels"""
    
    def __init__(self):
        self.channels = {
            "sms": SMSChannel(),
            "email": EmailChannel(),
            "slack": SlackChannel(),
            "discord": DiscordChannel(),
            "console": ConsoleChannel()
        }
    
    def send(self, channel: str, **kwargs) -> Dict:
        """Send notification to specified channel"""
        
        if channel not in self.channels:
            logger.error(f"❌ Unknown channel: {channel}")
            return {"status": "error", "error": f"Unknown channel: {channel}"}
        
        ch = self.channels[channel]
        
        # Validate required fields
        for field in ch.required_fields:
            if field not in kwargs:
                logger.error(f"❌ Missing required field: {field}")
                return {"status": "error", "error": f"Missing: {field}"}
        
        return ch.send(**kwargs)
    
    def send_all(self, channels: list, **kwargs) -> Dict:
        """Send to multiple channels"""
        
        results = {
            "timestamp": datetime.now().isoformat(),
            "channels": []
        }
        
        for ch in channels:
            result = self.send(ch, **kwargs)
            results["channels"].append({ch: result})
        
        return results

# ============================================================================
# CLI INTERFACE
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Code Catalyst Notify - Send notifications to multiple channels",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  codecatalyst notify --channel sms --message "Build succeeded!"
  codecatalyst notify --channel slack --text "Deployment complete"
  codecatalyst notify --channel email --to admin@team.com --subject "Alert" --body "Check logs"
  codecatalyst notify --channel console --message "Local message"
  codecatalyst notify --channel all --message "Multi-channel notification"
        """
    )
    
    parser.add_argument(
        "--channel",
        default="console",
        choices=["sms", "email", "slack", "discord", "console", "all"],
        help="Notification channel (default: console)"
    )
    
    parser.add_argument(
        "--message",
        help="Message to send (SMS/Console)"
    )
    
    parser.add_argument(
        "--text",
        help="Text to send (Slack/Discord)"
    )
    
    parser.add_argument(
        "--subject",
        help="Email subject"
    )
    
    parser.add_argument(
        "--body",
        help="Email body"
    )
    
    parser.add_argument(
        "--to",
        help="Recipient email/phone"
    )
    
    parser.add_argument(
        "--webhook-url",
        help="Webhook URL for Slack/Discord"
    )
    
    parser.add_argument(
        "--color",
        default="#36a64f",
        help="Slack message color"
    )
    
    parser.add_argument(
        "--title",
        default="Code Catalyst",
        help="Message title"
    )
    
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output as JSON"
    )
    
    args = parser.parse_args()
    
    # Build notification parameters
    kwargs = {}
    
    if args.message:
        kwargs["message"] = args.message
    if args.text:
        kwargs["text"] = args.text
    if args.subject:
        kwargs["subject"] = args.subject
    if args.body:
        kwargs["body"] = args.body
    if args.to:
        kwargs["to"] = args.to
    if args.webhook_url:
        kwargs["webhook_url"] = args.webhook_url
    if args.color:
        kwargs["color"] = args.color
    if args.title:
        kwargs["title"] = args.title
    
    # Send notification
    builder = NotificationBuilder()
    
    if args.channel == "all":
        result = builder.send_all(
            ["sms", "email", "slack", "discord", "console"],
            **kwargs
        )
    else:
        result = builder.send(args.channel, **kwargs)
    
    # Output result
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        if result.get("status") == "error":
            logger.error(f"Error: {result.get('error', 'Unknown')}")
            sys.exit(1)
    
    sys.exit(0)

if __name__ == "__main__":
    main()

