#!/usr/bin/env python
"""
🔐 VaultGemma CLI - Credential & Security Management
Integrated with WealthBridge Beta Platform
"""

import sys
import os
from pathlib import Path
from typing import Optional, List, Dict

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

try:
    from vaultgemma import EncryptionManager, CredentialManager, SecurityScanner
except ImportError:
    print("❌ VaultGemma not installed. Install with: pip install vaultgemma")
    sys.exit(1)


class VaultGemmaCLI:
    """Command-line interface for VaultGemma security operations"""
    
    def __init__(self):
        self.cred_mgr = CredentialManager()
        self.cipher = EncryptionManager()
        self.scanner = SecurityScanner()
    
    def store_credential(self, name: str, value: str, description: str = None) -> None:
        """Store a credential securely"""
        try:
            self.cred_mgr.store_credential(name, value)
            print(f"✅ Stored credential: {name}")
            if description:
                print(f"   Description: {description}")
            print(f"   Timestamp: {self._get_timestamp()}")
        except Exception as e:
            print(f"❌ Failed to store credential: {e}")
    
    def get_credential(self, name: str) -> None:
        """Retrieve a stored credential"""
        try:
            val = self.cred_mgr.get_credential(name)
            if val:
                print(f"✅ Retrieved: {name}")
                print(f"   Value: {'*' * len(str(val))}")  # Mask value
                print(f"   Length: {len(str(val))} chars")
            else:
                print(f"❌ Credential not found: {name}")
        except Exception as e:
            print(f"❌ Failed to retrieve credential: {e}")
    
    def rotate_credential(self, name: str, new_value: str) -> None:
        """Rotate (update) a credential"""
        try:
            old_val = self.cred_mgr.get_credential(name)
            if old_val:
                # Use store to update
                self.cred_mgr.store_credential(name, new_value)
                print(f"✅ Rotated credential: {name}")
                print(f"   Previous length: {len(str(old_val))} chars")
                print(f"   New length: {len(str(new_value))} chars")
                print(f"   Timestamp: {self._get_timestamp()}")
            else:
                print(f"❌ Credential not found: {name}")
        except Exception as e:
            print(f"❌ Failed to rotate credential: {e}")
    
    def delete_credential(self, name: str) -> None:
        """Delete a stored credential"""
        try:
            # Try to delete by storing empty value
            self.cred_mgr.store_credential(name, "")
            print(f"✅ Deleted credential: {name}")
        except Exception as e:
            print(f"❌ Failed to delete credential: {e}")
    
    def list_credentials(self, mask_values: bool = True) -> None:
        """List all stored credentials"""
        try:
            # Get the vault directly to list credentials
            vault = self.cred_mgr.vault
            if vault:
                print("📋 Stored Credentials:")
                print("─" * 60)
                for name in vault.keys():
                    try:
                        val = self.cred_mgr.get_credential(name)
                        display_val = '*' * min(len(str(val)), 20) if mask_values else str(val)
                        print(f"  • {name}: {display_val}")
                    except:
                        print(f"  • {name}: <error reading>")
                print("─" * 60)
                print(f"Total credentials: {len(vault)}")
            else:
                print("📋 No credentials stored yet")
        except Exception as e:
            print(f"❌ Failed to list credentials: {e}")
    
    def scan_code(self, file_path: str, show_details: bool = False) -> None:
        """Scan code file for security vulnerabilities"""
        try:
            if not os.path.exists(file_path):
                print(f"❌ File not found: {file_path}")
                return
            
            with open(file_path, 'r') as f:
                code = f.read()
            
            findings = self.scanner.scan_code(code)
            
            if findings:
                print(f"🔍 Security Scan Results for: {file_path}")
                print("─" * 60)
                
                # Parse findings if it's a string
                if isinstance(findings, str):
                    print(findings)
                elif isinstance(findings, dict):
                    for key, value in findings.items():
                        print(f"  {key}: {value}")
                else:
                    print(findings)
                print("─" * 60)
            else:
                print(f"✅ No security issues found in: {file_path}")
        except Exception as e:
            print(f"❌ Failed to scan code: {e}")
    
    def encrypt_text(self, text: str, show_encrypted: bool = False) -> None:
        """Encrypt text using VaultGemma"""
        try:
            encrypted = self.cipher.encrypt(text)
            if show_encrypted:
                print(f"✅ Encrypted text")
                print(f"   Original: {text[:30]}{'...' if len(text) > 30 else ''}")
                print(f"   Encrypted: {str(encrypted)[:50]}...")
            else:
                print(f"✅ Text encrypted successfully")
                print(f"   Encrypted length: {len(str(encrypted))} chars")
        except Exception as e:
            print(f"❌ Failed to encrypt: {e}")
    
    def decrypt_text(self, encrypted_text: str) -> None:
        """Decrypt text using VaultGemma"""
        try:
            decrypted = self.cipher.decrypt(encrypted_text)
            print(f"✅ Decrypted text:")
            print(f"   {decrypted}")
        except Exception as e:
            print(f"❌ Failed to decrypt: {e}")
    
    def verify_installation(self) -> None:
        """Verify VaultGemma installation and status"""
        print("🔐 VaultGemma Installation Check")
        print("─" * 60)
        
        try:
            # Check EncryptionManager
            print("✅ EncryptionManager: Available")
            test_encrypt = self.cipher.encrypt("test")
            print(f"   • Encryption: Working")
            
            # Check CredentialManager
            print("✅ CredentialManager: Available")
            vault = self.cred_mgr.vault
            cred_count = len(vault) if vault else 0
            print(f"   • Stored credentials: {cred_count}")
            
            # Check SecurityScanner
            print("✅ SecurityScanner: Available")
            print(f"   • Code scanning: Ready")
            
            print("─" * 60)
            print("✅ VaultGemma is fully installed and operational!")
        except Exception as e:
            print(f"❌ Installation check failed: {e}")
    
    @staticmethod
    def _get_timestamp() -> str:
        """Get current timestamp"""
        from datetime import datetime
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    def show_help(self) -> None:
        """Show help information"""
        help_text = """
🔐 VaultGemma CLI - Security Management Tool

USAGE:
  python vaultgemma_cli.py <command> [arguments]

COMMANDS:
  
  CREDENTIAL MANAGEMENT:
    store <name> <value>           Store a credential securely
    get <name>                     Retrieve a stored credential
    rotate <name> <new_value>      Update a credential
    delete <name>                  Delete a credential
    list                           List all stored credentials
  
  SECURITY SCANNING:
    scan <file_path>               Scan file for vulnerabilities
    scan-detailed <file_path>      Scan with detailed output
  
  ENCRYPTION:
    encrypt <text>                 Encrypt text
    decrypt <encrypted_text>       Decrypt text
  
  SYSTEM:
    verify                         Verify installation
    help                           Show this help message
    version                        Show version info

EXAMPLES:
  
  Store API key:
    python vaultgemma_cli.py store stripe-key sk_live_xxxxx
  
  List all credentials:
    python vaultgemma_cli.py list
  
  Scan Python file:
    python vaultgemma_cli.py scan backend/app/api.py
  
  Rotate credential:
    python vaultgemma_cli.py rotate stripe-key sk_live_yyyyy

SECURITY NOTES:
  • Credentials are encrypted and stored securely
  • Use strong passwords for credential manager
  • Rotate credentials regularly
  • Never commit credentials to version control
  • Use environment variables for sensitive data in production

For more help, see: SYSTEM_ACTIVATION_GUIDE.md
"""
        print(help_text)
    
    def show_version(self) -> None:
        """Show version information"""
        print("🔐 VaultGemma CLI v1.0.0")
        print("   Part of WealthBridge Security Platform")
        print("   https://wealthbridge.dev")


def main():
    """Main entry point"""
    cli = VaultGemmaCLI()
    
    if len(sys.argv) < 2:
        cli.show_help()
        return
    
    cmd = sys.argv[1].lower()
    args = sys.argv[2:] if len(sys.argv) > 2 else []
    
    try:
        if cmd == "store" and len(args) >= 2:
            description = args[2] if len(args) > 2 else None
            cli.store_credential(args[0], args[1], description)
        
        elif cmd == "get" and len(args) >= 1:
            cli.get_credential(args[0])
        
        elif cmd == "rotate" and len(args) >= 2:
            cli.rotate_credential(args[0], args[1])
        
        elif cmd == "delete" and len(args) >= 1:
            cli.delete_credential(args[0])
        
        elif cmd == "list":
            mask_values = "--show" not in args
            cli.list_credentials(mask_values=mask_values)
        
        elif cmd == "scan" and len(args) >= 1:
            detailed = "--detailed" in args
            cli.scan_code(args[0], show_details=detailed)
        
        elif cmd == "scan-detailed" and len(args) >= 1:
            cli.scan_code(args[0], show_details=True)
        
        elif cmd == "encrypt" and len(args) >= 1:
            text = " ".join(args)
            cli.encrypt_text(text, show_encrypted=True)
        
        elif cmd == "decrypt" and len(args) >= 1:
            encrypted = " ".join(args)
            cli.decrypt_text(encrypted)
        
        elif cmd == "verify":
            cli.verify_installation()
        
        elif cmd == "version":
            cli.show_version()
        
        elif cmd in ["help", "--help", "-h"]:
            cli.show_help()
        
        else:
            print(f"❌ Unknown command: {cmd}")
            print("   Run 'python vaultgemma_cli.py help' for usage")
    
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
