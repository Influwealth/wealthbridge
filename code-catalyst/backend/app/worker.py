"""
Code Catalyst Worker - Background Task Processing
Async LLM calls, code generation, analysis workflows
"""

import asyncio
import logging
from typing import Optional
import uuid
from .config import Config

logger = logging.getLogger(__name__)

class LLMProcessor:
    """Language model processing for code tasks"""
    
    SYSTEM_PROMPTS = {
        "dart": """You are an expert Dart and Flutter developer specializing in WealthBridge capsule development.
You understand:
- Dart language semantics and Flutter best practices
- Capsule architecture patterns (StatelessWidget, StatefulWidget)
- Integration with SIMA2Agent for orchestration
- Web3 patterns with Polygon smart contracts
- VaultGemma encryption for sensitive data

Provide concise, production-ready code with clear explanations.""",

        "solidity": """You are an expert Solidity smart contract developer.
You understand:
- Gas optimization techniques
- Security best practices (reentrancy, overflow/underflow)
- ERC-20, ERC-721, ERC-1155 standards
- Polygon network specifics
- Integration with Stripe treasury

Provide secure, audited, production-ready contracts.""",

        "javascript": """You are an expert Node.js and Express backend developer.
You understand:
- RESTful API design
- Middleware patterns
- Error handling and logging
- Integration with MongoDB, Redis
- Stripe and Plaid API integration

Provide clean, maintainable, secure backend code.""",

        "python": """You are an expert Python developer.
You understand:
- FastAPI and async Python
- CLI development with Typer
- Data processing and analysis
- Integration with external APIs
- Credential management and security

Provide clean, well-documented Python code.""",
    }
    
    @staticmethod
    async def call_claude(prompt: str, code_context: str = "", language: str = "dart") -> str:
        """Call Anthropic Claude for code suggestions"""
        try:
            from anthropic import Anthropic
            
            client = Anthropic()
            system_prompt = LLMProcessor.SYSTEM_PROMPTS.get(language, LLMProcessor.SYSTEM_PROMPTS["dart"])
            
            messages = [
                {
                    "role": "user",
                    "content": f"{prompt}\n\nContext:\n{code_context}" if code_context else prompt,
                }
            ]
            
            response = client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=2048,
                system=system_prompt,
                messages=messages,
            )
            
            return response.content[0].text
        
        except Exception as e:
            logger.error(f"Claude API error: {str(e)}")
            raise
    
    @staticmethod
    async def call_openai(prompt: str, code_context: str = "", language: str = "dart") -> str:
        """Call OpenAI GPT-4 for code suggestions"""
        try:
            from openai import OpenAI
            
            client = OpenAI()
            system_prompt = LLMProcessor.SYSTEM_PROMPTS.get(language, LLMProcessor.SYSTEM_PROMPTS["dart"])
            
            response = client.chat.completions.create(
                model="gpt-4",
                max_tokens=2048,
                system=system_prompt,
                messages=[
                    {
                        "role": "user",
                        "content": f"{prompt}\n\nContext:\n{code_context}" if code_context else prompt,
                    }
                ],
            )
            
            return response.choices[0].message.content
        
        except Exception as e:
            logger.error(f"OpenAI API error: {str(e)}")
            raise


async def process_suggestion(
    code: str,
    language: str,
    prompt: str,
    file_path: Optional[str] = None,
    context: str = "wealthbridge",
) -> str:
    """Process code suggestion request"""
    task_id = str(uuid.uuid4())
    
    logger.info(f"📝 Processing suggestion: {task_id}")
    logger.info(f"   Language: {language}")
    logger.info(f"   File: {file_path}")
    
    try:
        if Config.LLM_PROVIDER == "claude":
            suggestion = await LLMProcessor.call_claude(prompt, code, language)
        elif Config.LLM_PROVIDER == "openai":
            suggestion = await LLMProcessor.call_openai(prompt, code, language)
        else:
            raise ValueError(f"Unknown LLM provider: {Config.LLM_PROVIDER}")
        
        logger.info(f"✅ Suggestion generated: {task_id}")
        return task_id
    
    except Exception as e:
        logger.error(f"❌ Suggestion failed: {str(e)}")
        raise


async def process_generation(
    prompt: str,
    language: str,
    template: Optional[str] = None,
    context: dict = None,
) -> str:
    """Process code generation request"""
    task_id = str(uuid.uuid4())
    
    if context is None:
        context = {}
    
    logger.info(f"🔨 Processing generation: {task_id}")
    logger.info(f"   Language: {language}")
    logger.info(f"   Template: {template}")
    
    try:
        # Add template context
        template_context = ""
        if template == "capsule":
            template_context = """Generate a Dart capsule following WealthBridge patterns:
- Extend StatelessWidget or StatefulWidget
- Implement build() method
- Use Material Design 3
- Include Influwealth branding
- Follow capsule naming convention"""
        
        elif template == "contract":
            template_context = """Generate a Solidity smart contract:
- Include SPDX license identifier
- Add natspec comments
- Follow OpenZeppelin patterns
- Gas optimize where possible
- Include security checks"""
        
        elif template == "api":
            template_context = """Generate a Node.js/Express API endpoint:
- Use async/await
- Include error handling
- Add logging
- Validate inputs
- Return standard JSON response"""
        
        full_prompt = f"{prompt}\n\n{template_context}" if template_context else prompt
        
        if Config.LLM_PROVIDER == "claude":
            generated_code = await LLMProcessor.call_claude(full_prompt, "", language)
        elif Config.LLM_PROVIDER == "openai":
            generated_code = await LLMProcessor.call_openai(full_prompt, "", language)
        else:
            raise ValueError(f"Unknown LLM provider: {Config.LLM_PROVIDER}")
        
        logger.info(f"✅ Code generated: {task_id}")
        return task_id
    
    except Exception as e:
        logger.error(f"❌ Generation failed: {str(e)}")
        raise
