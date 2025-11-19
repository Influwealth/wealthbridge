"""
Interactive Testing Terminal for Code Catalyst
Real-time API testing with examples and helpers
"""

import asyncio
import httpx
import json
import logging
from typing import Optional, Dict, Any
from datetime import datetime

logger = logging.getLogger(__name__)


class InteractiveTestTerminal:
    """
    Interactive testing terminal for Code Catalyst
    Execute API calls, view results, test Twilio, etc.
    """

    def __init__(self, base_url: str = "http://localhost:8001"):
        self.base_url = base_url
        self.client = httpx.AsyncClient(base_url=base_url, timeout=30.0)
        self.test_history: list = []

    async def close(self):
        """Close HTTP client"""
        await self.client.aclose()

    async def test_health(self) -> Dict:
        """Test health endpoint"""
        logger.info("🏥 Testing health endpoint...")
        try:
            response = await self.client.get("/health")
            result = {
                "endpoint": "/health",
                "status_code": response.status_code,
                "response": response.json(),
                "timestamp": datetime.now().isoformat(),
            }
            self._log_result(result)
            return result
        except Exception as e:
            logger.error(f"❌ Health check failed: {e}")
            return {"error": str(e)}

    async def test_suggest_code(
        self,
        code: str = 'class MyWidget extends StatelessWidget {}',
        language: str = "dart",
        prompt: str = "Add error handling",
    ) -> Dict:
        """Test code suggestion endpoint"""
        logger.info(f"📝 Testing /suggest for {language}...")
        
        payload = {
            "code": code,
            "language": language,
            "prompt": prompt,
            "context": "wealthbridge",
        }

        try:
            response = await self.client.post("/api/suggest", json=payload)
            result = {
                "endpoint": "/api/suggest",
                "status_code": response.status_code,
                "request": payload,
                "response": response.json(),
                "timestamp": datetime.now().isoformat(),
            }
            self._log_result(result)
            return result
        except Exception as e:
            logger.error(f"❌ Suggest failed: {e}")
            return {"error": str(e)}

    async def test_generate_code(
        self,
        prompt: str = "Create AP2 affiliate tracking capsule",
        language: str = "dart",
        template: str = "capsule",
    ) -> Dict:
        """Test code generation endpoint"""
        logger.info(f"🔨 Testing /generate for {language}...")
        
        payload = {
            "prompt": prompt,
            "language": language,
            "template": template,
            "context": {},
        }

        try:
            response = await self.client.post("/api/generate", json=payload)
            result = {
                "endpoint": "/api/generate",
                "status_code": response.status_code,
                "request": payload,
                "response": response.json(),
                "timestamp": datetime.now().isoformat(),
            }
            self._log_result(result)
            return result
        except Exception as e:
            logger.error(f"❌ Generate failed: {e}")
            return {"error": str(e)}

    async def test_send_sms(
        self,
        to_number: str = "+1-555-1234",
        message: str = "Hello from Code Catalyst!",
    ) -> Dict:
        """Test Twilio SMS endpoint"""
        logger.info(f"📱 Testing /twilio/send-sms to {to_number}...")
        
        payload = {
            "to_number": to_number,
            "message": message,
        }

        try:
            response = await self.client.post("/api/twilio/send-sms", json=payload)
            result = {
                "endpoint": "/api/twilio/send-sms",
                "status_code": response.status_code,
                "request": payload,
                "response": response.json(),
                "timestamp": datetime.now().isoformat(),
            }
            self._log_result(result)
            return result
        except Exception as e:
            logger.error(f"❌ SMS failed: {e}")
            return {"error": str(e)}

    async def test_send_voice(
        self,
        to_number: str = "+1-555-1234",
        message: str = "Your payment has been processed",
    ) -> Dict:
        """Test Twilio voice endpoint"""
        logger.info(f"📞 Testing /twilio/send-voice to {to_number}...")
        
        payload = {
            "to_number": to_number,
            "message": message,
        }

        try:
            response = await self.client.post("/api/twilio/send-voice", json=payload)
            result = {
                "endpoint": "/api/twilio/send-voice",
                "status_code": response.status_code,
                "request": payload,
                "response": response.json(),
                "timestamp": datetime.now().isoformat(),
            }
            self._log_result(result)
            return result
        except Exception as e:
            logger.error(f"❌ Voice failed: {e}")
            return {"error": str(e)}

    async def test_batch_sms(
        self,
        recipients: list = ["+1-555-1111", "+1-555-2222", "+1-555-3333"],
        message: str = "New affiliate opportunity!",
    ) -> Dict:
        """Test batch SMS endpoint"""
        logger.info(f"📱📱 Testing /twilio/send-sms-batch to {len(recipients)} recipients...")
        
        payload = {
            "recipients": recipients,
            "message": message,
        }

        try:
            response = await self.client.post("/api/twilio/send-sms-batch", json=payload)
            result = {
                "endpoint": "/api/twilio/send-sms-batch",
                "status_code": response.status_code,
                "request": payload,
                "response": response.json(),
                "timestamp": datetime.now().isoformat(),
            }
            self._log_result(result)
            return result
        except Exception as e:
            logger.error(f"❌ Batch SMS failed: {e}")
            return {"error": str(e)}

    async def test_event_confirmation(
        self,
        phone: str = "+1-555-1234",
        event_name: str = "Influwealth Summit 2025",
        event_date: str = "December 15, 2025",
    ) -> Dict:
        """Test event confirmation SMS"""
        logger.info(f"📅 Testing event confirmation to {phone}...")
        
        payload = {
            "phone": phone,
            "event_name": event_name,
            "event_date": event_date,
        }

        try:
            response = await self.client.post(
                "/api/twilio/send-event-confirmation", json=payload
            )
            result = {
                "endpoint": "/api/twilio/send-event-confirmation",
                "status_code": response.status_code,
                "request": payload,
                "response": response.json(),
                "timestamp": datetime.now().isoformat(),
            }
            self._log_result(result)
            return result
        except Exception as e:
            logger.error(f"❌ Event confirmation failed: {e}")
            return {"error": str(e)}

    async def test_affiliate_notification(
        self,
        phone: str = "+1-555-1234",
        affiliate_name: str = "Sarah Chen",
        notification_type: str = "payout",
    ) -> Dict:
        """Test affiliate notification"""
        logger.info(f"👤 Testing affiliate notification to {affiliate_name}...")
        
        payload = {
            "phone": phone,
            "affiliate_name": affiliate_name,
            "notification_type": notification_type,
        }

        try:
            response = await self.client.post(
                "/api/twilio/send-affiliate-notification", json=payload
            )
            result = {
                "endpoint": "/api/twilio/send-affiliate-notification",
                "status_code": response.status_code,
                "request": payload,
                "response": response.json(),
                "timestamp": datetime.now().isoformat(),
            }
            self._log_result(result)
            return result
        except Exception as e:
            logger.error(f"❌ Affiliate notification failed: {e}")
            return {"error": str(e)}

    async def run_full_test_suite(self) -> Dict:
        """Run all tests in sequence"""
        logger.info("🚀 Starting full test suite...")
        
        results = {
            "start_time": datetime.now().isoformat(),
            "tests": {},
        }

        # Health check
        results["tests"]["health"] = await self.test_health()

        # Code generation
        results["tests"]["suggest"] = await self.test_suggest_code()
        results["tests"]["generate"] = await self.test_generate_code()

        # Twilio tests
        results["tests"]["sms"] = await self.test_send_sms()
        results["tests"]["voice"] = await self.test_send_voice()
        results["tests"]["batch_sms"] = await self.test_batch_sms()
        results["tests"]["event_confirmation"] = await self.test_event_confirmation()
        results["tests"]["affiliate_notification"] = await self.test_affiliate_notification()

        results["end_time"] = datetime.now().isoformat()
        results["total_tests"] = len(results["tests"])
        results["passed"] = sum(
            1 for t in results["tests"].values() if t.get("status_code") == 200
        )

        logger.info(f"✅ Test suite complete: {results['passed']}/{results['total_tests']} passed")

        return results

    def _log_result(self, result: Dict):
        """Log test result"""
        self.test_history.append(result)
        status = "✅" if result.get("status_code") == 200 else "❌"
        logger.info(
            f"{status} {result.get('endpoint')} - "
            f"Status: {result.get('status_code')}"
        )

    def get_history(self) -> list:
        """Get test history"""
        return self.test_history

    def print_summary(self):
        """Print test summary"""
        passed = sum(1 for t in self.test_history if t.get("status_code") == 200)
        total = len(self.test_history)
        
        print("\n" + "="*60)
        print("TEST SUMMARY")
        print("="*60)
        print(f"Total Tests: {total}")
        print(f"Passed: {passed}")
        print(f"Failed: {total - passed}")
        print(f"Success Rate: {(passed/total*100):.1f}%" if total > 0 else "N/A")
        print("="*60 + "\n")


async def interactive_test_loop():
    """
    Interactive test loop - allows real-time testing
    Run this to get an interactive prompt for testing
    """
    terminal = InteractiveTestTerminal()
    
    print("\n" + "="*60)
    print("🧪 CODE CATALYST INTERACTIVE TEST TERMINAL")
    print("="*60)
    print("Available tests:")
    print("  1. health      - Test health endpoint")
    print("  2. suggest     - Test code suggestions")
    print("  3. generate    - Test code generation")
    print("  4. sms         - Test SMS endpoint")
    print("  5. voice       - Test voice endpoint")
    print("  6. batch       - Test batch SMS")
    print("  7. event       - Test event confirmation")
    print("  8. affiliate   - Test affiliate notification")
    print("  9. full        - Run full test suite")
    print("  q. quit        - Exit")
    print("="*60 + "\n")

    while True:
        try:
            choice = input("Enter test number: ").strip().lower()
            
            if choice == "q":
                await terminal.close()
                print("✅ Test terminal closed")
                break
            
            elif choice == "1":
                result = await terminal.test_health()
                print(json.dumps(result, indent=2))
            
            elif choice == "2":
                result = await terminal.test_suggest_code()
                print(json.dumps(result, indent=2))
            
            elif choice == "3":
                result = await terminal.test_generate_code()
                print(json.dumps(result, indent=2))
            
            elif choice == "4":
                result = await terminal.test_send_sms()
                print(json.dumps(result, indent=2))
            
            elif choice == "5":
                result = await terminal.test_send_voice()
                print(json.dumps(result, indent=2))
            
            elif choice == "6":
                result = await terminal.test_batch_sms()
                print(json.dumps(result, indent=2))
            
            elif choice == "7":
                result = await terminal.test_event_confirmation()
                print(json.dumps(result, indent=2))
            
            elif choice == "8":
                result = await terminal.test_affiliate_notification()
                print(json.dumps(result, indent=2))
            
            elif choice == "9":
                results = await terminal.run_full_test_suite()
                print(json.dumps(results, indent=2))
                terminal.print_summary()
            
            else:
                print("❌ Invalid choice. Try again.")
        
        except KeyboardInterrupt:
            print("\n⚠️ Interrupted")
            await terminal.close()
            break
        except Exception as e:
            logger.error(f"Error: {e}")
            print(f"❌ Error: {e}")
