# -*- coding: utf-8 -*-
"""
VaultGemma Setup & Installation Script
Creates VaultGemma security module locally and globally
"""

import os
import json
import shutil
import subprocess
import sys
from pathlib import Path
from datetime import datetime


class VaultGemmaSetup:
    """Setup VaultGemma security module"""
    
    def __init__(self):
        self.home_dir = Path.home()
        self.vaultgemma_local = self.home_dir / "Documents" / "VaultGemma-Local"
        self.vaultgemma_global = self.home_dir / "AppData" / "Local" / "VaultGemma"
        self.timestamp = datetime.now().isoformat()
    
    def create_vaultgemma_module(self):
        """Create VaultGemma security module"""
        print("[+] Creating VaultGemma module structure...")
        
        # Create local directory
        self.vaultgemma_local.mkdir(parents=True, exist_ok=True)
        
        # Create VaultGemma package
        vg_package = self.vaultgemma_local / "vaultgemma"
        vg_package.mkdir(exist_ok=True)
        
        # Create __init__.py
        init_file = vg_package / "__init__.py"
        init_content = '''"""VaultGemma Security Module v1.0"""

__version__ = "1.0.0"
__author__ = "Influwealth Security Team"

from .encryption import EncryptionManager
from .credentials import CredentialManager
from .scanner import SecurityScanner

__all__ = ["EncryptionManager", "CredentialManager", "SecurityScanner"]
'''
        init_file.write_text(init_content, encoding='utf-8')
        
        # Create encryption module
        encryption_file = vg_package / "encryption.py"
        encryption_content = '''"""Encryption utilities for VaultGemma"""

from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2
import base64
import os


class EncryptionManager:
    """Encryption and decryption utilities"""
    
    def __init__(self, password=None):
        """Initialize with optional password"""
        self.password = password or os.environ.get("VAULTGEMMA_PASSWORD", "default-password")
        self._derive_key()
    
    def _derive_key(self):
        """Derive encryption key from password"""
        salt = b"vaultgemma-salt"
        kdf = PBKDF2(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(self.password.encode()))
        self.cipher = Fernet(key)
    
    def encrypt(self, data):
        """Encrypt string data"""
        if isinstance(data, str):
            data = data.encode()
        encrypted = self.cipher.encrypt(data)
        return encrypted.decode()
    
    def decrypt(self, encrypted_data):
        """Decrypt string data"""
        if isinstance(encrypted_data, str):
            encrypted_data = encrypted_data.encode()
        decrypted = self.cipher.decrypt(encrypted_data)
        return decrypted.decode()


__all__ = ["EncryptionManager"]
'''
        encryption_file.write_text(encryption_content, encoding='utf-8')
        
        # Create credentials module
        credentials_file = vg_package / "credentials.py"
        credentials_content = '''"""Credential management for VaultGemma"""

import json
from pathlib import Path
import os
from .encryption import EncryptionManager


class CredentialManager:
    """Secure credential storage and retrieval"""
    
    def __init__(self, vault_path=None):
        """Initialize credential manager"""
        self.vault_path = Path(vault_path or os.path.expanduser("~/.vaultgemma/credentials.json"))
        self.vault_path.parent.mkdir(parents=True, exist_ok=True)
        self.cipher = EncryptionManager()
        self._load_vault()
    
    def _load_vault(self):
        """Load credentials from vault"""
        if self.vault_path.exists():
            try:
                with open(self.vault_path, 'r') as f:
                    self.vault = json.load(f)
            except:
                self.vault = {}
        else:
            self.vault = {}
    
    def store_credential(self, name, value, metadata=None):
        """Store an encrypted credential"""
        encrypted = self.cipher.encrypt(value)
        self.vault[name] = {
            "encrypted": encrypted,
            "metadata": metadata or {}
        }
        self._save_vault()
    
    def get_credential(self, name):
        """Retrieve and decrypt a credential"""
        if name in self.vault:
            encrypted = self.vault[name]["encrypted"]
            return self.cipher.decrypt(encrypted)
        return None
    
    def _save_vault(self):
        """Save vault to file"""
        with open(self.vault_path, 'w') as f:
            json.dump(self.vault, f)


__all__ = ["CredentialManager"]
'''
        credentials_file.write_text(credentials_content, encoding='utf-8')
        
        # Create scanner module
        scanner_file = vg_package / "scanner.py"
        scanner_content = '''"""Security scanning for VaultGemma"""

import re
from typing import List, Dict


class SecurityScanner:
    """Scan code for security vulnerabilities"""
    
    def __init__(self):
        """Initialize scanner"""
        self.patterns = {
            "API_KEY": r"(?i)[a-z_]*api[_-]?key[\\s]*[:=][\\s]*['\\\"][\\w\\-]{20,}['\\\"]",
            "AWS_KEY": r"AKIA[0-9A-Z]{16}",
            "PRIVATE_KEY": r"-----BEGIN.*PRIVATE KEY-----",
            "DATABASE_URL": r"(mongodb|postgres|mysql)://",
            "SLACK_TOKEN": r"xox[baprs]-[0-9]{10,13}-[0-9]{10,13}[a-zA-Z0-9-]*",
        }
    
    def scan_code(self, code):
        """Scan code for security issues"""
        findings = []
        lines = code.split("\\n")
        
        for pattern_name, pattern in self.patterns.items():
            try:
                regex = re.compile(pattern)
                for line_num, line in enumerate(lines, 1):
                    if regex.search(line):
                        findings.append({
                            "type": pattern_name,
                            "line": line_num,
                            "severity": "HIGH"
                        })
            except:
                pass
        
        return findings


__all__ = ["SecurityScanner"]
'''
        scanner_file.write_text(scanner_content, encoding='utf-8')
        
        print("[OK] VaultGemma module created at " + str(self.vaultgemma_local))
    
    def create_global_link(self):
        """Copy to global Python path"""
        print("[+] Setting up global VaultGemma installation...")
        
        self.vaultgemma_global.mkdir(parents=True, exist_ok=True)
        
        # Copy vaultgemma package
        vg_src = self.vaultgemma_local / "vaultgemma"
        vg_dst = self.vaultgemma_global / "vaultgemma"
        
        if vg_dst.exists():
            shutil.rmtree(vg_dst)
        
        shutil.copytree(vg_src, vg_dst)
        
        print("[OK] Global VaultGemma installed at " + str(self.vaultgemma_global))
    
    def add_to_path(self):
        """Add VaultGemma to Python path"""
        print("[+] Adding VaultGemma to Python path...")
        
        # Create site-packages vaultgemma.pth
        site_packages = Path(sys.base_prefix) / "lib" / "site-packages"
        if not site_packages.exists():
            site_packages = Path(sys.base_prefix) / "Lib" / "site-packages"
        
        pth_file = site_packages / "vaultgemma.pth"
        pth_content = str(self.vaultgemma_global) + "\n" + str(self.vaultgemma_local)
        
        try:
            pth_file.write_text(pth_content)
            print("[OK] Python path updated")
        except Exception as e:
            print("[WARN] Could not write pth file: " + str(e))
    
    def create_env_file(self):
        """Create environment configuration"""
        print("[+] Creating environment configuration...")
        
        env_path = self.home_dir / ".env"
        env_content = """# VaultGemma Configuration
VAULTGEMMA_ENABLED=true
VAULTGEMMA_PASSWORD=your-secure-password-here
VAULTGEMMA_VAULT_PATH=~/.vaultgemma/credentials.json
VAULTGEMMA_LOG_LEVEL=INFO
VAULTGEMMA_AUTO_ENCRYPT=true
"""
        env_path.write_text(env_content)
        print("[OK] Environment configuration created")
    
    def run_setup(self):
        """Run complete setup"""
        print("\n[*] VaultGemma Setup Starting...")
        print("=" * 60)
        
        self.create_vaultgemma_module()
        self.create_global_link()
        self.add_to_path()
        self.create_env_file()
        
        print("=" * 60)
        print("[SUCCESS] VaultGemma Setup Complete!")
        print("\nUsage:")
        print("  from vaultgemma import EncryptionManager, CredentialManager, SecurityScanner")
        print("  cipher = EncryptionManager('password')")
        print("  encrypted = cipher.encrypt('data')")


if __name__ == "__main__":
    setup = VaultGemmaSetup()
    setup.run_setup()
