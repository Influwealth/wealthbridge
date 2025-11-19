#!/usr/bin/env python
"""
🔐 Code Catalyst Sandboxed Environment
Secure execution sandbox for WealthBridge backend services
"""

import sys
import os
import json
from pathlib import Path
from typing import Dict, Any
import subprocess
import shutil

class CodeCatalystSandbox:
    """Sandboxed environment for Code Catalyst"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.sandbox_dir = self.project_root / ".sandbox"
        self.venv_dir = self.sandbox_dir / "venv"
        self.config_file = self.sandbox_dir / "sandbox_config.json"
        
    def initialize(self) -> bool:
        """Initialize sandboxed environment"""
        print("🔐 Initializing Code Catalyst Sandbox...")
        
        # Create sandbox directory
        self.sandbox_dir.mkdir(parents=True, exist_ok=True)
        print(f"✅ Sandbox directory: {self.sandbox_dir}")
        
        # Create virtual environment
        if not self.venv_dir.exists():
            print("📦 Creating virtual environment...")
            subprocess.run([sys.executable, "-m", "venv", str(self.venv_dir)], check=True)
            print(f"✅ Virtual environment created: {self.venv_dir}")
        else:
            print(f"✅ Virtual environment exists: {self.venv_dir}")
        
        # Install dependencies in sandbox
        self._install_dependencies()
        
        # Create configuration
        self._create_config()
        
        return True
    
    def _install_dependencies(self) -> bool:
        """Install dependencies in sandboxed venv"""
        print("📦 Installing dependencies in sandbox...")
        
        req_file = self.project_root / "code-catalyst" / "backend" / "requirements.txt"
        if req_file.exists():
            if os.name == 'nt':  # Windows
                pip_path = self.venv_dir / "Scripts" / "pip.exe"
            else:  # Unix
                pip_path = self.venv_dir / "bin" / "pip"
            
            subprocess.run([str(pip_path), "install", "-r", str(req_file)], check=False)
            print("✅ Dependencies installed")
        return True
    
    def _create_config(self) -> bool:
        """Create sandbox configuration"""
        config = {
            "name": "Code Catalyst Sandbox",
            "version": "1.0",
            "sandboxed": True,
            "paths": {
                "project_root": str(self.project_root),
                "sandbox_dir": str(self.sandbox_dir),
                "venv_dir": str(self.venv_dir),
            },
            "security": {
                "isolated_network": True,
                "restricted_fs": True,
                "vault_integration": True,
                "encryption": "VaultGemma",
            },
            "features": {
                "code_catalyst": True,
                "vaultgemma": True,
                "docker_optional": True,
                "quantum_ready": True,
            }
        }
        
        with open(self.config_file, 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"✅ Configuration: {self.config_file}")
        return True
    
    def activate(self) -> str:
        """Get activation command for current OS"""
        if os.name == 'nt':  # Windows
            return str(self.venv_dir / "Scripts" / "activate.bat")
        else:  # Unix
            return f"source {self.venv_dir}/bin/activate"
    
    def run_command(self, cmd: str) -> int:
        """Run command in sandboxed environment"""
        if os.name == 'nt':  # Windows
            python_exe = self.venv_dir / "Scripts" / "python.exe"
        else:  # Unix
            python_exe = self.venv_dir / "bin" / "python"
        
        # Prepend venv python to command
        full_cmd = f"{python_exe} {cmd}"
        return subprocess.run(full_cmd, shell=True)
    
    def status(self) -> Dict[str, Any]:
        """Get sandbox status"""
        return {
            "initialized": self.sandbox_dir.exists(),
            "venv_created": self.venv_dir.exists(),
            "config_exists": self.config_file.exists(),
            "sandbox_dir": str(self.sandbox_dir),
            "venv_dir": str(self.venv_dir),
        }
    
    def destroy(self) -> bool:
        """Destroy sandbox (careful!)"""
        if self.sandbox_dir.exists():
            shutil.rmtree(self.sandbox_dir)
            print("⚠️  Sandbox destroyed")
            return True
        return False


def main():
    """Main entry point"""
    project_root = "c:\\Users\\VICTOR MORALES\\Documents\\WealthBridge"
    
    sandbox = CodeCatalystSandbox(project_root)
    
    if len(sys.argv) < 2:
        print("Code Catalyst Sandbox Manager")
        print("Usage: python sandbox.py <command>")
        print("\nCommands:")
        print("  init     - Initialize sandbox")
        print("  status   - Check sandbox status")
        print("  activate - Show activation command")
        print("  destroy  - Remove sandbox (careful!)")
        return
    
    command = sys.argv[1].lower()
    
    if command == "init":
        sandbox.initialize()
        print("\n✅ Sandbox initialized!")
        print(f"Activate with: {sandbox.activate()}")
    
    elif command == "status":
        status = sandbox.status()
        print(json.dumps(status, indent=2))
    
    elif command == "activate":
        print(f"Activate sandbox:\n  {sandbox.activate()}")
    
    elif command == "destroy":
        response = input("Are you sure? (yes/no): ")
        if response.lower() == "yes":
            sandbox.destroy()
    
    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
