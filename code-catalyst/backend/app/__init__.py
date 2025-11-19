"""
Code Catalyst Backend Package
AI-powered coding agent for WealthBridge ecosystem
"""

__version__ = "1.0.0"
__author__ = "Influwealth Consult LLC"
__license__ = "Proprietary"

from .config import Config
from .main import app

__all__ = ["app", "Config"]
