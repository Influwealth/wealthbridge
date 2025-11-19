"""
Code Catalyst Backend - Main FastAPI Application
Sovereign AI coding agent for WealthBridge ecosystem
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
import redis.asyncio as redis
from .config import Config

logger = logging.getLogger(__name__)

# Global Redis client
redis_client = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan: startup and shutdown"""
    global redis_client
    
    # Startup
    logger.info("🚀 Starting Code Catalyst Backend...")
    
    # Initialize Redis
    try:
        redis_client = await redis.from_url(
            Config.REDIS_URL,
            encoding="utf8",
            decode_responses=True,
            socket_connect_timeout=5,
            socket_keepalive=True,
        )
        await redis_client.ping()
        logger.info("✅ Redis connected")
    except Exception as e:
        logger.warning(f"⚠️ Redis connection failed: {str(e)}")
        redis_client = None
    
    # Load configuration
    try:
        Config.validate()
        logger.info("✅ Configuration loaded and validated")
    except Exception as e:
        logger.error(f"❌ Configuration error: {str(e)}")
        raise
    
    yield
    
    # Shutdown
    logger.info("🛑 Shutting down Code Catalyst Backend...")
    if redis_client:
        await redis_client.close()
        logger.info("✅ Redis disconnected")

# FastAPI application
app = FastAPI(
    title="Code Catalyst",
    description="AI-powered coding agent for WealthBridge",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routes
from .api import router as api_router
app.include_router(api_router, prefix="/api", tags=["Code Generation"])

# Health check endpoints
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    redis_status = "connected"
    if redis_client is None:
        redis_status = "disconnected"
    
    return {
        "status": "healthy",
        "services": {
            "redis": redis_status,
            "mongodb": "configured",
            "config": "loaded",
        },
        "version": "1.0.0",
    }

@app.get("/config")
async def config_check():
    """Configuration validation endpoint"""
    try:
        Config.validate()
        return {
            "status": "valid",
            "llm_provider": Config.LLM_PROVIDER,
            "environment": "production" if not Config.DEBUG else "development",
            "twilio_enabled": bool(Config.TWILIO_ACCOUNT_SID),
            "polygon_enabled": bool(Config.POLYGON_RPC_URL),
            "github_app_enabled": bool(Config.GITHUB_APP_ID),
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": "Code Catalyst",
        "version": "1.0.0",
        "description": "AI-powered coding agent for Influwealth",
        "docs": "/docs",
        "health": "/health",
        "endpoints": {
            "suggest": "POST /api/suggest",
            "generate": "POST /api/generate",
            "analyze": "POST /api/analyze-contract",
            "audit": "POST /api/audit",
            "twilio_sms": "POST /api/twilio/send-sms",
            "twilio_voice": "POST /api/twilio/send-voice",
            "webhook": "POST /api/webhook",
            "sima2": "POST /api/sima2-bridge",
        },
    }

if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=Config.PORT,
        reload=Config.DEBUG,
        log_level="info",
    )
