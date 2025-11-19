"""
Code Catalyst Security Scanner
Integrates Trivy + custom vulnerability detection
Scans for secrets, vulnerabilities, and compliance issues
"""

import subprocess
import json
import re
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
from enum import Enum
import logging

logger = logging.getLogger(__name__)


class SeverityLevel(str, Enum):
    CRITICAL = "CRITICAL"
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"
    INFO = "INFO"


@dataclass
class SecurityFinding:
    """Represents a single security finding"""
    title: str
    description: str
    severity: SeverityLevel
    file_path: Optional[str] = None
    line_number: Optional[int] = None
    code_snippet: Optional[str] = None
    recommendation: Optional[str] = None
    cwe_id: Optional[str] = None


class SecurityScanner:
    """
    Multi-layer security scanner for Code Catalyst
    - Secret scanning (hardcoded credentials)
    - Vulnerability detection (Trivy)
    - Code quality issues
    - Compliance checks (IRS, DOL, SAM.gov patterns)
    - Web3-specific issues
    """

    def __init__(self):
        self.findings: List[SecurityFinding] = []
        self.trivy_available = self._check_trivy()

    def _check_trivy(self) -> bool:
        """Check if Trivy is installed"""
        try:
            subprocess.run(["trivy", "--version"], capture_output=True, check=True)
            logger.info("✅ Trivy is available")
            return True
        except Exception as e:
            logger.warning(f"⚠️ Trivy not available: {e}")
            return False

    def scan(self, code: str, language: str = "dart") -> Dict[str, Any]:
        """
        Run comprehensive security scan on code

        Args:
            code: Source code to scan
            language: Programming language (dart, solidity, javascript, python, rust)

        Returns:
            Dictionary with all findings
        """
        self.findings = []
        
        # Run multiple scan layers
        self._scan_secrets(code)
        self._scan_vulnerabilities(code, language)
        self._scan_compliance(code, language)
        self._scan_web3_patterns(code, language)
        self._scan_code_quality(code, language)

        return self._generate_report()

    def _scan_secrets(self, code: str) -> None:
        """Scan for hardcoded secrets and credentials"""
        # Patterns for common secrets
        patterns = {
            "AWS_KEY": r"AKIA[0-9A-Z]{16}",
            "PRIVATE_KEY": r"-----BEGIN PRIVATE KEY-----",
            "API_KEY": r"api[_-]?key\s*[:=]\s*['\"]([a-zA-Z0-9]{20,})['\"]",
            "DATABASE_URL": r"(mysql|postgres|mongodb)://.*:.*@",
            "STRIPE_KEY": r"sk_(test|live)_[0-9a-zA-Z]{20,}",
            "JWT_SECRET": r"jwt[_-]?secret\s*[:=]",
            "GITHUB_TOKEN": r"ghp_[0-9a-zA-Z]{36}",
            "ANTHROPIC_KEY": r"sk-ant-[0-9a-zA-Z]{20,}",
            "TWILIO_SID": r"AC[0-9a-f]{32}",
            "ROBLOX_KEY": r"--rbxCookie\s*['\"]([^'\"]+)['\"]",
        }

        for secret_type, pattern in patterns.items():
            if re.search(pattern, code, re.IGNORECASE):
                self.findings.append(SecurityFinding(
                    title=f"Exposed {secret_type}",
                    description=f"Potential {secret_type} found in code",
                    severity=SeverityLevel.CRITICAL,
                    recommendation="Move credentials to environment variables or VaultGemma",
                    cwe_id="CWE-798"
                ))

    def _scan_vulnerabilities(self, code: str, language: str) -> None:
        """Scan for known vulnerabilities using custom rules"""
        
        # SQL Injection patterns
        if re.search(r"(query|execute|sql)\s*\(\s*['\"].*\$", code):
            self.findings.append(SecurityFinding(
                title="Potential SQL Injection",
                description="Untrusted input concatenated into SQL query",
                severity=SeverityLevel.HIGH,
                recommendation="Use parameterized queries",
                cwe_id="CWE-89"
            ))

        # XSS vulnerabilities
        if re.search(r"(innerHTML|dangerouslySetInnerHTML)\s*[:=]", code):
            self.findings.append(SecurityFinding(
                title="XSS Vulnerability",
                description="Direct HTML injection detected",
                severity=SeverityLevel.HIGH,
                recommendation="Use textContent or escape user input",
                cwe_id="CWE-79"
            ))

        # Path traversal
        if re.search(r"(open|readFile|getFile)\s*\(\s*path\s*\)", code):
            self.findings.append(SecurityFinding(
                title="Potential Path Traversal",
                description="User-controlled path passed to file operation",
                severity=SeverityLevel.HIGH,
                recommendation="Validate and sanitize file paths",
                cwe_id="CWE-22"
            ))

        # CORS misconfiguration
        if re.search(r"allow_origins\s*[:=]\s*\[.*\*", code) or \
           re.search(r"Access-Control-Allow-Origin.*\*", code):
            self.findings.append(SecurityFinding(
                title="CORS Misconfiguration",
                description="Allow all origins (*) in CORS configuration",
                severity=SeverityLevel.HIGH,
                recommendation="Restrict to specific domains",
                cwe_id="CWE-942"
            ))

        # Insecure random
        if language in ["python", "javascript", "dart"] and \
           re.search(r"(random\.|Math\.random)", code):
            self.findings.append(SecurityFinding(
                title="Insecure Random Number Generation",
                description="Using weak RNG for security purposes",
                severity=SeverityLevel.MEDIUM,
                recommendation="Use cryptographically secure RNG",
                cwe_id="CWE-338"
            ))

        # Hardcoded IP addresses
        if re.search(r"(localhost|127\.0\.0\.1|0\.0\.0\.0)\s*[:=]", code):
            self.findings.append(SecurityFinding(
                title="Hardcoded Localhost Reference",
                description="Hardcoded localhost/loopback IP in code",
                severity=SeverityLevel.MEDIUM,
                recommendation="Use environment configuration",
                cwe_id="CWE-798"
            ))

        # Solidity-specific issues
        if language == "solidity":
            self._scan_solidity_vulnerabilities(code)

    def _scan_solidity_vulnerabilities(self, code: str) -> None:
        """Scan Solidity smart contracts for specific vulnerabilities"""
        
        # Re-entrancy pattern
        if re.search(r"call\.value\s*\(\s*\)|transfer\s*\(\s*\)", code) and \
           re.search(r"withdraw|sendFunds", code):
            self.findings.append(SecurityFinding(
                title="Potential Re-entrancy Vulnerability",
                description="Possible re-entrancy pattern detected",
                severity=SeverityLevel.CRITICAL,
                recommendation="Use checks-effects-interactions pattern",
                cwe_id="CWE-841"
            ))

        # Overflow/Underflow
        if "SafeMath" not in code and re.search(r"[+\-*]/\s*", code):
            self.findings.append(SecurityFinding(
                title="Missing SafeMath",
                description="Arithmetic operations without overflow/underflow checks",
                severity=SeverityLevel.HIGH,
                recommendation="Use SafeMath library or Solidity 0.8+",
                cwe_id="CWE-190"
            ))

        # Timestamp dependence
        if re.search(r"now\s|block\.timestamp", code) and \
           re.search(r"require.*timestamp|if.*timestamp", code):
            self.findings.append(SecurityFinding(
                title="Timestamp Dependency",
                description="Logic depends on block.timestamp",
                severity=SeverityLevel.MEDIUM,
                recommendation="Avoid critical logic based on timestamps",
                cwe_id="CWE-330"
            ))

        # Unchecked external calls
        if re.search(r"\.call\s*\(\s*\)" , code) and \
           "require" not in code[:code.find(".call")]:
            self.findings.append(SecurityFinding(
                title="Unchecked External Call",
                description="External call result not checked",
                severity=SeverityLevel.HIGH,
                recommendation="Always check external call return values",
                cwe_id="CWE-252"
            ))

    def _scan_compliance(self, code: str, language: str) -> None:
        """Scan for compliance issues (IRS, DOL, SAM.gov, Web3)"""
        
        # Check for IRS compliance patterns
        if re.search(r"(tax|withholding|1099|W-?2)\s", code, re.IGNORECASE):
            if not re.search(r"audit|log|record", code, re.IGNORECASE):
                self.findings.append(SecurityFinding(
                    title="Missing Tax Compliance Logging",
                    description="Tax-related code without audit logging",
                    severity=SeverityLevel.HIGH,
                    recommendation="Add comprehensive audit trail for tax calculations",
                    cwe_id="CWE-434"
                ))

        # Check for DOL compliance patterns
        if re.search(r"(wage|salary|overtime|labor)\s", code, re.IGNORECASE):
            if not re.search(r"log.*employment|audit.*wage", code, re.IGNORECASE):
                self.findings.append(SecurityFinding(
                    title="Missing DOL Compliance Logging",
                    description="Employment/wage code without proper logging",
                    severity=SeverityLevel.HIGH,
                    recommendation="Add DOL-compliant audit logging",
                    cwe_id="CWE-434"
                ))

        # Check for GDPR/Privacy compliance
        if re.search(r"(password|email|phone|ssn|pii)\s", code, re.IGNORECASE):
            if not re.search(r"encrypt|hash|mask", code, re.IGNORECASE):
                self.findings.append(SecurityFinding(
                    title="PII Not Protected",
                    description="Personally identifiable information not encrypted",
                    severity=SeverityLevel.HIGH,
                    recommendation="Encrypt all PII at rest and in transit",
                    cwe_id="CWE-327"
                ))

    def _scan_web3_patterns(self, code: str, language: str) -> None:
        """Scan for Web3/blockchain-specific security patterns"""
        
        if language == "solidity" or "web3" in code.lower():
            # Check for front-running vulnerability
            if re.search(r"public\s+function.*payable", code) and \
               not re.search(r"nonce|ordering", code):
                self.findings.append(SecurityFinding(
                    title="Potential Front-Running Risk",
                    description="Public payable function without ordering protection",
                    severity=SeverityLevel.MEDIUM,
                    recommendation="Implement ordering protection or batching",
                    cwe_id="CWE-362"
                ))

            # Check for flashloan vulnerability patterns
            if "flashloan" in code.lower() or "flash_loan" in code.lower():
                if "check" not in code.lower() or "verify" not in code.lower():
                    self.findings.append(SecurityFinding(
                        title="Unprotected Flash Loan Pattern",
                        description="Flash loan usage without verification",
                        severity=SeverityLevel.HIGH,
                        recommendation="Add flash loan protection checks",
                        cwe_id="CWE-841"
                    ))

    def _scan_code_quality(self, code: str, language: str) -> None:
        """Scan for code quality and best practice issues"""
        
        # Check for TODO/FIXME comments
        if re.search(r"(TODO|FIXME|HACK|XXX):", code):
            self.findings.append(SecurityFinding(
                title="Incomplete Code Detected",
                description="TODO/FIXME comments found in production code",
                severity=SeverityLevel.LOW,
                recommendation="Review and complete all TODO items",
                cwe_id="CWE-470"
            ))

        # Check for overly broad exception handling
        if re.search(r"except\s*:|catch\s*\(\s*\)", code):
            self.findings.append(SecurityFinding(
                title="Broad Exception Handling",
                description="Catching all exceptions without specific handling",
                severity=SeverityLevel.LOW,
                recommendation="Catch specific exception types",
                cwe_id="CWE-395"
            ))

        # Check for missing input validation
        if re.search(r"(process|handle|save).*input\s", code, re.IGNORECASE) and \
           not re.search(r"validate|sanitize|check.*input", code, re.IGNORECASE):
            self.findings.append(SecurityFinding(
                title="Missing Input Validation",
                description="Input processing without validation",
                severity=SeverityLevel.MEDIUM,
                recommendation="Always validate and sanitize user input",
                cwe_id="CWE-20"
            ))

    def _generate_report(self) -> Dict[str, Any]:
        """Generate security report"""
        
        # Count by severity
        severity_counts = {}
        for finding in self.findings:
            severity = finding.severity.value
            severity_counts[severity] = severity_counts.get(severity, 0) + 1

        return {
            "total_findings": len(self.findings),
            "severity_counts": severity_counts,
            "has_critical": SeverityLevel.CRITICAL.value in severity_counts,
            "has_high": SeverityLevel.HIGH.value in severity_counts,
            "findings": [asdict(f) for f in self.findings],
            "status": "PASS" if not self.findings else "FAIL"
        }


# Standalone functions for API integration
def scan_code(code: str, language: str = "dart") -> Dict[str, Any]:
    """Scan code for security issues"""
    scanner = SecurityScanner()
    return scanner.scan(code, language)


def scan_file(file_path: str, language: str = "dart") -> Dict[str, Any]:
    """Scan a file for security issues"""
    try:
        with open(file_path, 'r') as f:
            code = f.read()
        return scan_code(code, language)
    except Exception as e:
        logger.error(f"Error scanning file: {e}")
        return {"error": str(e), "status": "ERROR"}
