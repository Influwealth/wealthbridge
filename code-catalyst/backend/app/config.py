"""
Code Catalyst Configuration Management
Loads environment variables, validates credentials, manages application settings
"""

import os
from dotenv import load_dotenv
import logging

logger = logging.getLogger(__name__)

# Load .env.local first
load_dotenv(override=False)

class Config:
    """Application configuration from environment variables"""
    
    # ===== LLM ROUTING =====
    LLM_PROVIDER = os.getenv("LLM_PROVIDER", "claude").lower()  # claude or openai
    ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
    
    # ===== POLYGON WEB3 =====
    POLYGON_RPC_URL = os.getenv("POLYGON_RPC_URL", "https://polygon-mumbai.g.alchemy.com/v2/demo")
    POLYGON_NETWORK = os.getenv("POLYGON_NETWORK", "mumbai")
    POLYGON_PRIVATE_KEY = os.getenv("POLYGON_PRIVATE_KEY", "")
    
    # ===== STRIPE TREASURY =====
    STRIPE_API_KEY = os.getenv("STRIPE_API_KEY", "")
    STRIPE_SECRET_KEY = os.getenv("STRIPE_SECRET_KEY", "")
    
    # ===== PLAID =====
    PLAID_CLIENT_ID = os.getenv("PLAID_CLIENT_ID", "")
    PLAID_SECRET = os.getenv("PLAID_SECRET", "")
    PLAID_ENV = os.getenv("PLAID_ENV", "sandbox")
    
    # ===== MONGODB =====
    MONGODB_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017/code-catalyst")
    
    # ===== GITHUB APP =====
    GITHUB_APP_ID = os.getenv("GITHUB_APP_ID", "")
    GITHUB_PRIVATE_KEY = os.getenv("GITHUB_PRIVATE_KEY", "")
    GITHUB_WEBHOOK_SECRET = os.getenv("GITHUB_WEBHOOK_SECRET", "")
    
    # ===== REDIS =====
    REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")
    REDIS_PASSWORD = os.getenv("REDIS_PASSWORD", "")
    
    # ===== COMMUNICATIONS (TWILIO) =====
    TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID", "")
    TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN", "")
    TWILIO_PHONE_NUMBER = os.getenv("TWILIO_PHONE_NUMBER", "+1-555-INFLUWEALTH")
    
    # ===== CONTACT INFO =====
    SUPPORT_EMAIL = os.getenv("SUPPORT_EMAIL", "support@influwealth.com")
    COMPANY_NAME = os.getenv("COMPANY_NAME", "Influwealth Consult LLC")
    COMPANY_ADDRESS = os.getenv("COMPANY_ADDRESS", "224 W 35th St Fl 5, New York, NY 10001")
    WEBSITE = os.getenv("WEBSITE", "https://influwealth.wixsite.com/influwealth-consult")
    
    # ===== SERVER CONFIG =====
    PORT = int(os.getenv("PORT", "8001"))
    ENV = os.getenv("ENV", "development")
    DEBUG = os.getenv("DEBUG", "true").lower() == "true"
    
    # ===== VAULTGEMMA ENCRYPTION (Optional) =====
    VAULTGEMMA_KEY = os.getenv("VAULTGEMMA_KEY", "")
    VAULTGEMMA_ENDPOINT = os.getenv("VAULTGEMMA_ENDPOINT", "")
    
    @classmethod
    def validate(cls):
        """Validate critical configuration on startup"""
        errors = []
        warnings = []
        
        # Check LLM configuration
        if cls.LLM_PROVIDER == "claude" and not cls.ANTHROPIC_API_KEY:
            errors.append("ANTHROPIC_API_KEY not set (Claude provider selected)")
        elif cls.LLM_PROVIDER == "openai" and not cls.OPENAI_API_KEY:
            errors.append("OPENAI_API_KEY not set (OpenAI provider selected)")
        
        # Check Twilio configuration
        if not cls.TWILIO_ACCOUNT_SID:
            warnings.append("TWILIO_ACCOUNT_SID not set (SMS/Voice disabled)")
        if not cls.TWILIO_AUTH_TOKEN:
            warnings.append("TWILIO_AUTH_TOKEN not set (SMS/Voice disabled)")
        
        # Check optional Web3 config
        if not cls.POLYGON_PRIVATE_KEY and cls.POLYGON_NETWORK != "mumbai":
            warnings.append("POLYGON_PRIVATE_KEY not set (smart contract signing disabled)")
        
        # Check GitHub App config
        if not cls.GITHUB_APP_ID or not cls.GITHUB_PRIVATE_KEY:
            warnings.append("GitHub App credentials incomplete (webhook disabled)")
        
        # Report errors
        if errors:
            logger.error("❌ Configuration Errors:")
            for error in errors:
                logger.error(f"   - {error}")
            raise ValueError("Critical configuration missing")
        
        # Report warnings
        if warnings:
            logger.warning("⚠️ Configuration Warnings:")
            for warning in warnings:
                logger.warning(f"   - {warning}")
        
        logger.info("✅ Configuration validation passed")
        return True
    
    @classmethod
    def to_dict(cls):
        """Return non-sensitive config as dictionary"""
        return {
            "llm_provider": cls.LLM_PROVIDER,
            "polygon_network": cls.POLYGON_NETWORK,
            "plaid_env": cls.PLAID_ENV,
            "twilio_enabled": bool(cls.TWILIO_ACCOUNT_SID),
            "github_app_enabled": bool(cls.GITHUB_APP_ID),
            "mongodb_configured": bool(cls.MONGODB_URI),
            "redis_url": cls.REDIS_URL,
            "company_name": cls.COMPANY_NAME,
            "support_email": cls.SUPPORT_EMAIL,
            "environment": cls.ENV,
            "debug": cls.DEBUG,
        }
