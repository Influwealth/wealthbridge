"""
Agent Handoff System - Inspired by argus-prime/handoff.py
Allows Code Catalyst to delegate specialized tasks to domain-specific agents
"""

import logging
import time
import json
from typing import Dict, Optional, List
from datetime import datetime
from enum import Enum

logger = logging.getLogger(__name__)


class AgentType(Enum):
    """Specialized agent types in Code Catalyst ecosystem"""
    DART_CAPSULE = "dart-capsule"
    SOLIDITY_AUDITOR = "solidity-auditor"
    TWILIO_INTEGRATOR = "twilio-integrator"
    GITHUB_APP_AGENT = "github-app-agent"
    MINDMAX_OPTIMIZER = "mindmax-optimizer"
    VAULTGEMMA_SECURITY = "vaultgemma-security"
    DEEPAGENT = "deepagent"  # Fallback generalist


class TaskStatus(Enum):
    """Task lifecycle states"""
    CREATED = "created"
    DELEGATED = "delegated"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    HANDED_BACK = "handed_back"


class AgentHandoff:
    """
    Central handoff coordinator for Code Catalyst agents
    Matches tasks to specialized agents and tracks delegation
    """

    def __init__(self):
        self.handoff_log: List[Dict] = []
        self.active_delegations: Dict[str, Dict] = {}
        
        # Agent specializations mapping
        self.agent_specializations = {
            AgentType.DART_CAPSULE: {
                "keywords": ["dart", "capsule", "flutter", "wealthbridge", "stateful"],
                "capabilities": ["code-generation", "code-review", "pattern-matching"],
                "models": ["claude-3.5-sonnet", "gpt-4"],
            },
            AgentType.SOLIDITY_AUDITOR: {
                "keywords": ["solidity", "smart-contract", "ethereum", "polygon", "security"],
                "capabilities": ["vulnerability-scan", "gas-optimization", "audit"],
                "models": ["claude-3.5-sonnet"],
            },
            AgentType.TWILIO_INTEGRATOR: {
                "keywords": ["sms", "voice", "twilio", "notification", "outreach"],
                "capabilities": ["sms-generation", "voice-twiml", "batch-messaging"],
                "models": ["gpt-4"],
            },
            AgentType.GITHUB_APP_AGENT: {
                "keywords": ["github", "webhook", "pr", "pull-request", "commit"],
                "capabilities": ["webhook-handling", "pr-review", "automation"],
                "models": ["claude-3.5-sonnet"],
            },
            AgentType.MINDMAX_OPTIMIZER: {
                "keywords": ["optimize", "performance", "vgpu", "quantum", "simulation"],
                "capabilities": ["optimization", "benchmarking", "parallel-processing"],
                "models": ["claude-3.5-sonnet"],
            },
            AgentType.VAULTGEMMA_SECURITY: {
                "keywords": ["security", "encryption", "credential", "vault", "secret"],
                "capabilities": ["credential-scanning", "encryption", "compliance"],
                "models": ["claude-3.5-sonnet"],
            },
        }

    def predict_agent(self, task_description: str, code_language: Optional[str] = None) -> AgentType:
        """
        Predict best agent for a task based on keywords and language
        Returns the specialized agent type
        """
        task_lower = task_description.lower()
        language_lower = code_language.lower() if code_language else ""
        
        # Dart capsule task
        if "dart" in language_lower or "capsule" in task_lower or "flutter" in task_lower:
            return AgentType.DART_CAPSULE
        
        # Solidity/security task
        if "solidity" in language_lower or "contract" in task_lower or "vulnerability" in task_lower:
            return AgentType.SOLIDITY_AUDITOR
        
        # Twilio/SMS/Voice task
        if "sms" in task_lower or "voice" in task_lower or "twilio" in task_lower or "notification" in task_lower:
            return AgentType.TWILIO_INTEGRATOR
        
        # GitHub task
        if "github" in task_lower or "webhook" in task_lower or "pull request" in task_lower:
            return AgentType.GITHUB_APP_AGENT
        
        # Optimization task
        if "optimize" in task_lower or "performance" in task_lower or "quantum" in task_lower:
            return AgentType.MINDMAX_OPTIMIZER
        
        # Security/credential task
        if "security" in task_lower or "credential" in task_lower or "encrypt" in task_lower:
            return AgentType.VAULTGEMMA_SECURITY
        
        # Fallback to generalist
        return AgentType.DEEPAGENT

    def delegate(
        self,
        from_agent: str,
        task_id: str,
        task_description: str,
        code_language: Optional[str] = None,
        context: Optional[Dict] = None,
        timeout_seconds: int = 300,
    ) -> Dict:
        """
        Delegate a task to a specialized agent
        
        Args:
            from_agent: Name of originating agent (e.g., "code-catalyst")
            task_id: Unique task identifier
            task_description: What needs to be done
            code_language: Programming language (dart, solidity, javascript, etc)
            context: Additional context/parameters for the task
            timeout_seconds: Max time before handback timeout
        
        Returns:
            Delegation record with agent assignment
        """
        
        # Predict best agent for this task
        target_agent = self.predict_agent(task_description, code_language)
        
        # Create delegation record
        delegation = {
            "task_id": task_id,
            "from_agent": from_agent,
            "to_agent": target_agent.value,
            "task_description": task_description,
            "code_language": code_language,
            "context": context or {},
            "status": TaskStatus.DELEGATED.value,
            "delegated_at": datetime.now().isoformat(),
            "expected_handback_at": (datetime.now().timestamp() + timeout_seconds),
            "timestamp": time.time(),
        }
        
        # Track active delegation
        self.active_delegations[task_id] = delegation
        
        # Log handoff
        self.handoff_log.append(delegation)
        
        logger.info(
            f"🤝 HANDOFF: {from_agent} → {target_agent.value} | "
            f"Task: {task_description[:50]}... | ID: {task_id}"
        )
        
        return delegation

    def handback(
        self,
        task_id: str,
        agent: str,
        result: Dict,
        status: str = "completed",
    ) -> Dict:
        """
        Receive delegated work back from specialized agent
        
        Args:
            task_id: Original task identifier
            agent: Agent returning the work
            result: Generated code, analysis, or solution
            status: "completed" or "failed"
        
        Returns:
            Handback record
        """
        
        if task_id not in self.active_delegations:
            logger.error(f"❌ Unknown task_id in handback: {task_id}")
            return {"error": "Task not found"}
        
        delegation = self.active_delegations[task_id]
        
        handback_record = {
            "task_id": task_id,
            "from_agent": agent,
            "to_agent": delegation["from_agent"],
            "status": status,
            "result": result,
            "handed_back_at": datetime.now().isoformat(),
            "duration_seconds": time.time() - delegation["timestamp"],
        }
        
        # Log handback
        self.handoff_log.append(handback_record)
        
        # Update active delegation status
        delegation["status"] = TaskStatus.HANDED_BACK.value
        delegation["result"] = result
        
        logger.info(
            f"🔄 HANDBACK: {agent} → {delegation['from_agent']} | "
            f"Status: {status} | Duration: {handback_record['duration_seconds']:.2f}s"
        )
        
        return handback_record

    def get_task_status(self, task_id: str) -> Optional[Dict]:
        """Get current status of a delegated task"""
        return self.active_delegations.get(task_id)

    def get_agent_info(self, agent_type: AgentType) -> Dict:
        """Get specialization info for an agent type"""
        return self.agent_specializations.get(agent_type, {})

    def export_handoff_log(self) -> str:
        """Export handoff log as JSON string"""
        return json.dumps(self.handoff_log, indent=2)


# Singleton instance for global access
handoff_coordinator = AgentHandoff()


async def delegate_task_to_agent(
    task_description: str,
    code_language: Optional[str] = None,
    context: Optional[Dict] = None,
) -> Dict:
    """
    Convenient async function to delegate a task
    Used by Code Catalyst API endpoints
    
    Example:
        result = await delegate_task_to_agent(
            task_description="Create AP2 affiliate tracking capsule",
            code_language="dart",
            context={"affiliate_id": "aff_123"}
        )
    """
    import uuid
    
    task_id = str(uuid.uuid4())
    
    delegation = handoff_coordinator.delegate(
        from_agent="code-catalyst",
        task_id=task_id,
        task_description=task_description,
        code_language=code_language,
        context=context,
    )
    
    logger.info(f"📤 Delegated to {delegation['to_agent']}: {task_id}")
    
    return delegation
