#!/usr/bin/env python3
"""
Code Catalyst Interactive Test Runner
Starts services and opens interactive testing terminal

Usage:
    python test_interactive.py
    
Or from CLI:
    python cli/codecatalyst-cli.py test
"""

import asyncio
import subprocess
import sys
import time
import logging
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent / "backend"))

from app.interactive_testing import InteractiveTestTerminal, interactive_test_loop

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


async def main():
    """Main test runner"""
    
    print("\n" + "="*70)
    print("🧪 CODE CATALYST - INTERACTIVE TEST RUNNER")
    print("="*70 + "\n")
    
    # Check if services are running
    terminal = InteractiveTestTerminal()
    
    try:
        health = await terminal.test_health()
        if health.get("status_code") == 200:
            print("✅ Services are running!")
            print("   - FastAPI: http://localhost:8001")
            print("   - Redis: localhost:6379")
            print("   - MongoDB: localhost:27017")
        else:
            print("⚠️ Services may not be fully initialized")
    except Exception as e:
        print(f"❌ Cannot connect to services: {e}")
        print("\n📝 To start services, run:")
        print("   docker-compose up -d")
        await terminal.close()
        return
    
    print("\n" + "="*70)
    print("SELECT TEST MODE:")
    print("="*70)
    print("1. Interactive - Choose tests individually")
    print("2. Quick Test - Run 3 basic tests (health, suggest, sms)")
    print("3. Full Suite - Run all tests")
    print("4. Custom    - Enter custom parameters")
    print("0. Exit")
    print()
    
    while True:
        choice = input("Enter choice (0-4): ").strip()
        
        if choice == "0":
            print("✅ Exiting")
            await terminal.close()
            return
        
        elif choice == "1":
            print("\n🧪 Opening interactive test terminal...\n")
            await terminal.close()
            await interactive_test_loop()
            return
        
        elif choice == "2":
            print("\n⚡ Running quick test suite...\n")
            
            results = {
                "health": await terminal.test_health(),
                "suggest": await terminal.test_suggest_code(),
                "sms": await terminal.test_send_sms(),
            }
            
            print("\n" + "="*70)
            print("QUICK TEST RESULTS")
            print("="*70)
            for name, result in results.items():
                status = "✅ PASS" if result.get("status_code") == 200 else "❌ FAIL"
                print(f"{name:20} {status}")
            print("="*70 + "\n")
            
            await terminal.close()
            return
        
        elif choice == "3":
            print("\n🚀 Running full test suite...\n")
            
            results = await terminal.run_full_test_suite()
            terminal.print_summary()
            
            # Save results to file
            import json
            results_file = Path(__file__).parent / "test_results.json"
            with open(results_file, "w") as f:
                json.dump(results, f, indent=2)
            
            print(f"📊 Results saved to: {results_file}\n")
            
            await terminal.close()
            return
        
        elif choice == "4":
            print("\n⚙️ Custom test mode")
            print("Available: health, suggest, generate, sms, voice, batch, event, affiliate")
            test_name = input("Enter test name: ").strip().lower()
            
            test_map = {
                "health": terminal.test_health,
                "suggest": terminal.test_suggest_code,
                "generate": terminal.test_generate_code,
                "sms": terminal.test_send_sms,
                "voice": terminal.test_send_voice,
                "batch": terminal.test_batch_sms,
                "event": terminal.test_event_confirmation,
                "affiliate": terminal.test_affiliate_notification,
            }
            
            if test_name in test_map:
                result = await test_map[test_name]()
                
                import json
                print("\n" + json.dumps(result, indent=2))
            else:
                print(f"❌ Unknown test: {test_name}")
            
            print()
        
        else:
            print("❌ Invalid choice")


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n⚠️ Interrupted by user")
        sys.exit(0)
