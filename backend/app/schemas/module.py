"""Module schemas"""
from pydantic import BaseModel
from typing import Dict, Any, Optional
from datetime import datetime


class ModuleRegister(BaseModel):
    """Schema for registering a module"""
    id: str
    name: str
    category: str
    version: str
    active: bool = True
    capabilities: Dict[str, Any]
    cost_profile: Optional[Dict[str, Any]] = None
    endpoint: Optional[str] = None
    endpoint_type: str = "internal"


class ModuleResponse(BaseModel):
    """Schema for module response"""
    id: str
    name: str
    category: str
    version: str
    active: bool
    capabilities: Dict[str, Any]
    cost_profile: Optional[Dict[str, Any]]
    endpoint: Optional[str]
    endpoint_type: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

