#!/usr/bin/env python3
"""
Code Catalyst CLI Tool
Command-line interface for Code Catalyst backend
"""

import typer
import httpx
import json
from typing import Optional
from rich.console import Console
from rich.table import Table
from rich.syntax import Syntax

app = typer.Typer(help="Code Catalyst: AI-powered coding agent")
console = Console()

# Configuration
BACKEND_URL = "http://localhost:8001"  # Can override via env var CODE_CATALYST_BACKEND_URL
TIMEOUT = 30.0


def get_backend_url() -> str:
    """Get backend URL from config or environment"""
    import os
    return os.getenv("CODE_CATALYST_BACKEND_URL", BACKEND_URL)


@app.command()
def suggest(
    code: str = typer.Option(..., "--code", "-c", help="Code to analyze"),
    language: str = typer.Option("dart", "--language", "-l", help="Programming language"),
    prompt: str = typer.Option(..., "--prompt", "-p", help="What to suggest"),
    file: Optional[str] = typer.Option(None, "--file", "-f", help="File path"),
):
    """Get AI code suggestions"""
    console.print(f"🔍 Analyzing {language} code...", style="cyan")
    
    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.post(
                f"{get_backend_url()}/api/suggest",
                json={
                    "code": code,
                    "language": language,
                    "prompt": prompt,
                    "file_path": file,
                    "context": "wealthbridge",
                },
            )
            response.raise_for_status()
            result = response.json()
        
        console.print("✅ Suggestion queued", style="green")
        console.print(f"Task ID: {result['task_id']}", style="blue")
        console.print(f"Status: {result['status']}", style="cyan")
    
    except Exception as e:
        console.print(f"❌ Error: {str(e)}", style="red")
        raise typer.Exit(code=1)


@app.command()
def generate(
    prompt: str = typer.Option(..., "--prompt", "-p", help="What to generate"),
    language: str = typer.Option("dart", "--language", "-l", help="Programming language"),
    template: Optional[str] = typer.Option(None, "--template", "-t", help="Template: capsule, contract, api"),
):
    """Generate code from natural language"""
    console.print(f"🔨 Generating {language} code...", style="cyan")
    
    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.post(
                f"{get_backend_url()}/api/generate",
                json={
                    "prompt": prompt,
                    "language": language,
                    "template": template,
                },
            )
            response.raise_for_status()
            result = response.json()
        
        console.print("✅ Generation started", style="green")
        console.print(f"Task ID: {result['task_id']}", style="blue")
        console.print(f"Status: {result['status']}", style="cyan")
    
    except Exception as e:
        console.print(f"❌ Error: {str(e)}", style="red")
        raise typer.Exit(code=1)


@app.command()
def analyze_contract(
    contract: str = typer.Option(..., "--contract", "-c", help="Solidity contract code"),
    check_vulns: bool = typer.Option(True, "--vulnerabilities", "-v", help="Check for vulnerabilities"),
):
    """Analyze smart contract for security issues"""
    console.print("🔍 Analyzing smart contract...", style="cyan")
    
    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.post(
                f"{get_backend_url()}/api/analyze-contract",
                json={
                    "contract_code": contract,
                    "language": "solidity",
                    "check_vulnerabilities": check_vulns,
                },
            )
            response.raise_for_status()
            result = response.json()
        
        console.print("✅ Analysis complete", style="green")
        
        # Display vulnerabilities
        if result.get("vulnerabilities"):
            console.print("\n⚠️ Vulnerabilities found:", style="yellow")
            for vuln in result["vulnerabilities"]:
                console.print(f"  - {vuln}", style="red")
        else:
            console.print("✅ No vulnerabilities detected", style="green")
        
        # Display optimizations
        if result.get("optimizations"):
            console.print("\n💡 Optimizations:", style="cyan")
            for opt in result["optimizations"]:
                console.print(f"  - {opt}", style="blue")
    
    except Exception as e:
        console.print(f"❌ Error: {str(e)}", style="red")
        raise typer.Exit(code=1)


@app.command()
def audit(
    code: str = typer.Option(..., "--code", "-c", help="Code to audit"),
    language: str = typer.Option("dart", "--language", "-l", help="Programming language"),
    secrets: bool = typer.Option(True, "--secrets", "-s", help="Scan for secrets"),
    vulns: bool = typer.Option(True, "--vulnerabilities", "-v", help="Scan for vulnerabilities"),
):
    """Run security audit on code"""
    console.print("🔒 Running security audit...", style="cyan")
    
    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.post(
                f"{get_backend_url()}/api/audit",
                json={
                    "code": code,
                    "language": language,
                    "scan_secrets": secrets,
                    "scan_vulnerabilities": vulns,
                },
            )
            response.raise_for_status()
            result = response.json()
        
        findings = result.get("findings", {})
        
        # Create table
        table = Table(title="🔒 Audit Results")
        table.add_column("Category", style="cyan")
        table.add_column("Count", style="magenta")
        
        table.add_row("Secrets", str(findings.get("secrets_found", 0)))
        table.add_row("Vulnerabilities", str(findings.get("vulnerabilities_found", 0)))
        table.add_row("Quality Issues", str(findings.get("quality_issues", 0)))
        
        console.print(table)
        
        if result.get("safe"):
            console.print("✅ Code is safe", style="green")
        else:
            console.print("⚠️ Issues found", style="yellow")
    
    except Exception as e:
        console.print(f"❌ Error: {str(e)}", style="red")
        raise typer.Exit(code=1)


@app.command()
def health():
    """Check backend health status"""
    console.print("🏥 Checking backend health...", style="cyan")
    
    try:
        with httpx.Client(timeout=5) as client:
            response = client.get(f"{get_backend_url()}/health")
            response.raise_for_status()
            result = response.json()
        
        # Create table
        table = Table(title="✅ Backend Status")
        table.add_column("Service", style="cyan")
        table.add_column("Status", style="magenta")
        
        for service, status in result.get("services", {}).items():
            style = "green" if status == "connected" else "yellow"
            table.add_row(service, status, style=style)
        
        console.print(table)
        console.print(f"Version: {result.get('version')}", style="blue")
    
    except Exception as e:
        console.print(f"❌ Backend not responding: {str(e)}", style="red")
        raise typer.Exit(code=1)


@app.command()
def config():
    """View configuration"""
    console.print("⚙️ Loading configuration...", style="cyan")
    
    try:
        with httpx.Client(timeout=5) as client:
            response = client.get(f"{get_backend_url()}/config")
            response.raise_for_status()
            result = response.json()
        
        # Create table
        table = Table(title="⚙️ Configuration")
        table.add_column("Key", style="cyan")
        table.add_column("Value", style="magenta")
        
        for key, value in result.items():
            table.add_row(key, str(value))
        
        console.print(table)
    
    except Exception as e:
        console.print(f"❌ Error: {str(e)}", style="red")
        raise typer.Exit(code=1)


@app.command()
def status(task_id: str = typer.Argument(..., help="Task ID to check")):
    """Check task status"""
    console.print(f"📋 Checking task {task_id}...", style="cyan")
    
    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.get(f"{get_backend_url()}/api/task/{task_id}")
            response.raise_for_status()
            result = response.json()
        
        console.print(f"Task ID: {result['task_id']}", style="blue")
        console.print(f"Status: {result['status']}", style="cyan")
        console.print(f"Progress: {result['progress']}%", style="magenta")
    
    except Exception as e:
        console.print(f"❌ Error: {str(e)}", style="red")
        raise typer.Exit(code=1)


if __name__ == "__main__":
    app()
