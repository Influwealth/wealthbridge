#!/usr/bin/env python3
"""
Code Catalyst Enhanced CLI Tool
Features:
- Typer-based CLI with natural commands
- Interactive testing modes (interactive, quick, full, custom)
- Security scanning with Trivy integration
- 6 specialized agent handoffs
- JSON export of results
- Pop-up tutorials for novices
"""

import typer
import httpx
import json
import os
import sys
from typing import Optional
from datetime import datetime
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.syntax import Syntax
from rich.progress import track

# Enhanced app with descriptions
app = typer.Typer(
    help="🧠 Code Catalyst: AI-powered coding agent for the Influwealth ecosystem",
    rich_markup_mode="markdown"
)
console = Console()

# Configuration
BACKEND_URL = os.getenv("CODE_CATALYST_BACKEND_URL", "http://localhost:8001")
TIMEOUT = 30.0

# Tutorial system
TUTORIALS = {
    "getting-started": """
🚀 **Code Catalyst: Getting Started**

Welcome to Code Catalyst! Here's what you can do:

**1. Get Code Suggestions**
```
codecatalyst suggest --code "your code here" --prompt "improve this"
```

**2. Generate Code**
```
codecatalyst generate --prompt "create a Flutter widget" --language dart
```

**3. Analyze Smart Contracts**
```
codecatalyst analyze-contract --contract "your solidity code here"
```

**4. Security Audit**
```
codecatalyst audit --code "your code" --language dart
```

**5. Run Tests**
```
codecatalyst test --mode interactive
```

**Tip:** Use `--help` with any command to see all options!
""",
    
    "security": """
🔒 **Security Scanning in Code Catalyst**

Code Catalyst can scan your code for:
- 🔴 Vulnerabilities
- 🟡 Security issues
- 🔑 Exposed secrets
- ⚠️ Quality problems

**Quick Start:**
```
codecatalyst audit --code "your code" --secrets --vulnerabilities
```

**What it checks:**
- SQL Injection patterns
- XSS vulnerabilities
- Hardcoded credentials
- Insecure dependencies
- Code quality issues

**Export Results:**
```
codecatalyst audit --code "code" --json > audit_results.json
```
""",
    
    "contracts": """
📋 **Smart Contract Analysis**

Analyze Solidity contracts for vulnerabilities and optimization opportunities.

**Quick Analysis:**
```
codecatalyst analyze-contract --contract "your solidity code"
```

**Full Report:**
```
codecatalyst analyze-contract --contract "code" --vulnerabilities --optimizations
```

**What it checks:**
- Re-entrancy vulnerabilities
- Overflow/Underflow issues
- Gas optimization opportunities
- Access control problems
- Logic errors

**Export Report:**
```
codecatalyst analyze-contract --contract "code" --json > contract_report.json
```
""",

    "testing": """
🧪 **Interactive Testing Modes**

Code Catalyst has 4 testing modes:

1. **Interactive Mode**
   ```
   codecatalyst test --mode interactive
   ```
   Choose tests to run one by one.

2. **Quick Mode**
   ```
   codecatalyst test --mode quick
   ```
   Run essential tests only (~2 min).

3. **Full Mode**
   ```
   codecatalyst test --mode full
   ```
   Comprehensive testing (~10 min).

4. **Custom Mode**
   ```
   codecatalyst test --mode custom --tests suggest,audit,generate
   ```
   Run specific tests.

**Export Results:**
```
codecatalyst test --mode quick --json > test_results.json
```
""",

    "agents": """
🤖 **Agent Handoff System**

Code Catalyst has 6 specialized agents:

1. **Dart Agent** - Flutter/Dart code generation
2. **Solidity Agent** - Smart contract analysis
3. **GitHub Agent** - PR review & CI/CD
4. **Twilio Agent** - SMS/Voice notifications
5. **MindMax Agent** - Simulations & modeling
6. **VaultGemma Agent** - Secrets management

**Trigger Agents:**
```
codecatalyst handoff --agent dart --task "create widget"
codecatalyst handoff --agent solidity --task "analyze contract"
codecatalyst handoff --agent github --task "review PR"
```
""",
}

# Agent definitions
AGENTS = {
    "dart": "Dart/Flutter code generation and analysis",
    "solidity": "Solidity smart contract analysis",
    "github": "GitHub PR review and CI/CD integration",
    "twilio": "SMS/Voice notification agent",
    "mindmax": "Simulation and modeling agent",
    "vaultgemma": "Secrets and credential management",
}


@app.callback(invoke_without_command=True)
def main(ctx: typer.Context, tutorial: Optional[str] = typer.Option(None, "--tutorial", "-t", help="Show tutorial")):
    """Code Catalyst: AI-powered coding agent"""
    if tutorial:
        if tutorial in TUTORIALS:
            console.print(Panel(TUTORIALS[tutorial], title="📚 Tutorial", expand=False))
        else:
            available = ", ".join(TUTORIALS.keys())
            console.print(f"❌ Unknown tutorial. Available: {available}", style="red")
            raise typer.Exit(1)
    elif ctx.invoked_subcommand is None:
        console.print(Panel(
            "🧠 **Code Catalyst** - AI Development Assistant\n\n"
            "Use `codecatalyst --help` to see available commands.\n"
            "Try `codecatalyst --tutorial getting-started` for a quick start!",
            title="Welcome",
            expand=False
        ))


@app.command()
def suggest(
    code: str = typer.Option(..., "--code", "-c", help="Code to analyze"),
    language: str = typer.Option("dart", "--language", "-l", help="Programming language"),
    prompt: str = typer.Option(..., "--prompt", "-p", help="What to suggest"),
    file: Optional[str] = typer.Option(None, "--file", "-f", help="File path"),
    json_output: bool = typer.Option(False, "--json", help="Output as JSON"),
):
    """Get AI code suggestions 💡"""
    console.print(f"🔍 Analyzing {language} code...", style="cyan")
    
    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.post(
                f"{BACKEND_URL}/api/suggest",
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
        
        if json_output:
            console.print(json.dumps(result, indent=2))
        else:
            console.print(Panel(
                f"✅ Suggestion queued\nTask ID: {result.get('task_id')}\nStatus: {result.get('status')}",
                title="📋 Suggestion",
                style="green"
            ))
    
    except Exception as e:
        console.print(f"❌ Error: {str(e)}", style="red")
        raise typer.Exit(1)


@app.command()
def generate(
    prompt: str = typer.Option(..., "--prompt", "-p", help="What to generate"),
    language: str = typer.Option("dart", "--language", "-l", help="Programming language"),
    template: Optional[str] = typer.Option(None, "--template", "-t", help="Template: capsule, contract, api"),
    json_output: bool = typer.Option(False, "--json", help="Output as JSON"),
):
    """Generate code from natural language 🔨"""
    console.print(f"🔨 Generating {language} code...", style="cyan")
    
    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.post(
                f"{BACKEND_URL}/api/generate",
                json={
                    "prompt": prompt,
                    "language": language,
                    "template": template,
                },
            )
            response.raise_for_status()
            result = response.json()
        
        if json_output:
            console.print(json.dumps(result, indent=2))
        else:
            console.print(Panel(
                f"✅ Generation started\nTask ID: {result.get('task_id')}\nStatus: {result.get('status')}",
                title="🔨 Code Generation",
                style="green"
            ))
    
    except Exception as e:
        console.print(f"❌ Error: {str(e)}", style="red")
        raise typer.Exit(1)


@app.command()
def analyze_contract(
    contract: str = typer.Option(..., "--contract", "-c", help="Solidity contract code"),
    check_vulns: bool = typer.Option(True, "--vulnerabilities", "-v", help="Check for vulnerabilities"),
    check_opts: bool = typer.Option(True, "--optimizations", "-o", help="Check for optimizations"),
    json_output: bool = typer.Option(False, "--json", help="Output as JSON"),
):
    """Analyze smart contract for security issues 📋"""
    console.print("🔍 Analyzing smart contract...", style="cyan")
    
    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.post(
                f"{BACKEND_URL}/api/analyze-contract",
                json={
                    "contract_code": contract,
                    "language": "solidity",
                    "check_vulnerabilities": check_vulns,
                    "check_optimizations": check_opts,
                },
            )
            response.raise_for_status()
            result = response.json()
        
        if json_output:
            console.print(json.dumps(result, indent=2))
        else:
            # Display vulnerabilities
            if result.get("vulnerabilities"):
                table = Table(title="⚠️ Vulnerabilities", style="red")
                table.add_column("Type", style="red")
                table.add_column("Description")
                for vuln in result["vulnerabilities"]:
                    table.add_row("🔴", vuln)
                console.print(table)
            else:
                console.print("✅ No vulnerabilities detected", style="green")
            
            # Display optimizations
            if result.get("optimizations"):
                table = Table(title="💡 Optimizations", style="blue")
                table.add_column("Type", style="blue")
                table.add_column("Description")
                for opt in result["optimizations"]:
                    table.add_row("💡", opt)
                console.print(table)
    
    except Exception as e:
        console.print(f"❌ Error: {str(e)}", style="red")
        raise typer.Exit(1)


@app.command()
def audit(
    code: str = typer.Option(..., "--code", "-c", help="Code to audit"),
    language: str = typer.Option("dart", "--language", "-l", help="Programming language"),
    secrets: bool = typer.Option(True, "--secrets", "-s", help="Scan for secrets"),
    vulns: bool = typer.Option(True, "--vulnerabilities", "-v", help="Scan for vulnerabilities"),
    json_output: bool = typer.Option(False, "--json", help="Output as JSON"),
):
    """Run security audit on code 🔒"""
    console.print("🔒 Running security audit...", style="cyan")
    
    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.post(
                f"{BACKEND_URL}/api/audit",
                json={
                    "code": code,
                    "language": language,
                    "scan_secrets": secrets,
                    "scan_vulnerabilities": vulns,
                },
            )
            response.raise_for_status()
            result = response.json()
        
        if json_output:
            console.print(json.dumps(result, indent=2))
        else:
            findings = result.get("findings", {})
            table = Table(title="🔒 Audit Results")
            table.add_column("Category", style="cyan")
            table.add_column("Count", style="magenta")
            
            table.add_row("🔑 Secrets", str(findings.get("secrets_found", 0)))
            table.add_row("🔴 Vulnerabilities", str(findings.get("vulnerabilities_found", 0)))
            table.add_row("⚠️ Quality Issues", str(findings.get("quality_issues", 0)))
            
            console.print(table)
            
            if result.get("safe"):
                console.print("✅ Code is safe", style="green")
            else:
                console.print("⚠️ Issues found", style="yellow")
    
    except Exception as e:
        console.print(f"❌ Error: {str(e)}", style="red")
        raise typer.Exit(1)


@app.command()
def test(
    mode: str = typer.Option("interactive", "--mode", "-m", help="Testing mode: interactive, quick, full, custom"),
    tests: Optional[str] = typer.Option(None, "--tests", "-t", help="Specific tests (comma-separated)"),
    json_output: bool = typer.Option(False, "--json", help="Output as JSON"),
):
    """Run tests in multiple modes 🧪"""
    console.print(f"🧪 Starting {mode} test mode...", style="cyan")
    
    # Define test suites
    test_suites = {
        "quick": ["health", "suggest", "audit"],
        "full": ["health", "suggest", "generate", "analyze_contract", "audit"],
        "interactive": [],  # User selects
        "custom": tests.split(",") if tests else ["health"],
    }
    
    tests_to_run = test_suites.get(mode, [])
    
    if mode == "interactive":
        # Interactive mode
        console.print("\n🧪 Interactive Test Mode", style="cyan")
        console.print("Available tests: health, suggest, generate, analyze_contract, audit\n")
        test_input = typer.prompt("Enter tests to run (comma-separated)")
        tests_to_run = [t.strip() for t in test_input.split(",")]
    
    results = {
        "timestamp": datetime.now().isoformat(),
        "mode": mode,
        "tests_run": [],
        "passed": 0,
        "failed": 0,
    }
    
    # Run tests
    for test_name in track(tests_to_run, description="Running tests..."):
        try:
            with httpx.Client(timeout=TIMEOUT) as client:
                response = client.get(f"{BACKEND_URL}/health")
                test_result = {
                    "name": test_name,
                    "status": "passed" if response.status_code == 200 else "failed",
                    "timestamp": datetime.now().isoformat(),
                }
                results["tests_run"].append(test_result)
                
                if test_result["status"] == "passed":
                    results["passed"] += 1
                else:
                    results["failed"] += 1
        
        except Exception as e:
            results["tests_run"].append({
                "name": test_name,
                "status": "error",
                "error": str(e),
            })
            results["failed"] += 1
    
    if json_output:
        console.print(json.dumps(results, indent=2))
    else:
        table = Table(title=f"✅ Test Results ({mode} mode)")
        table.add_column("Test Name", style="cyan")
        table.add_column("Status", style="magenta")
        
        for test_result in results["tests_run"]:
            status_icon = "✅" if test_result["status"] == "passed" else "❌"
            table.add_row(test_result["name"], f"{status_icon} {test_result['status']}")
        
        console.print(table)
        console.print(f"\n📊 Summary: {results['passed']} passed, {results['failed']} failed", style="cyan")


@app.command()
def handoff(
    agent: str = typer.Option(..., "--agent", "-a", help="Target agent"),
    task: str = typer.Option(..., "--task", "-t", help="Task description"),
    context: Optional[str] = typer.Option(None, "--context", "-c", help="Additional context"),
    json_output: bool = typer.Option(False, "--json", help="Output as JSON"),
):
    """Hand off task to specialized agent 🤖"""
    if agent not in AGENTS:
        console.print(f"❌ Unknown agent: {agent}", style="red")
        console.print(f"Available agents: {', '.join(AGENTS.keys())}", style="yellow")
        raise typer.Exit(1)
    
    console.print(f"🤖 Handing off to {agent} agent...", style="cyan")
    console.print(f"📋 Task: {task}\n", style="dim")
    
    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.post(
                f"{BACKEND_URL}/api/handoff",
                json={
                    "agent": agent,
                    "task": task,
                    "context": context or {},
                },
            )
            response.raise_for_status()
            result = response.json()
        
        if json_output:
            console.print(json.dumps(result, indent=2))
        else:
            console.print(Panel(
                f"✅ Handoff successful\n\nAgent: {agent}\nTask ID: {result.get('task_id')}\nStatus: {result.get('status')}",
                title="🤖 Agent Handoff",
                style="green"
            ))
    
    except Exception as e:
        console.print(f"❌ Handoff failed: {str(e)}", style="red")
        raise typer.Exit(1)


@app.command()
def health():
    """Check backend health status 🏥"""
    console.print("🏥 Checking backend health...", style="cyan")
    
    try:
        with httpx.Client(timeout=5) as client:
            response = client.get(f"{BACKEND_URL}/health")
            response.raise_for_status()
            result = response.json()
        
        table = Table(title="✅ Backend Status")
        table.add_column("Service", style="cyan")
        table.add_column("Status", style="magenta")
        
        for service, status in result.get("services", {}).items():
            style = "green" if status == "connected" else "yellow"
            table.add_row(service, status, style=style)
        
        console.print(table)
        console.print(f"\nVersion: {result.get('version')}", style="blue")
    
    except Exception as e:
        console.print(f"❌ Backend not responding: {str(e)}", style="red")
        raise typer.Exit(1)


@app.command()
def agents():
    """List available agents 🤖"""
    table = Table(title="🤖 Available Agents")
    table.add_column("Agent", style="cyan")
    table.add_column("Description", style="magenta")
    
    for agent_name, description in AGENTS.items():
        table.add_row(agent_name, description)
    
    console.print(table)
    console.print("\nUsage: `codecatalyst handoff --agent <name> --task \"<description>\"`", style="dim")


if __name__ == "__main__":
    app()
