"""
External Application Integration Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from uuid import UUID
from decimal import Decimal


# External Application Schemas
class ExternalApplicationCreate(BaseModel):
    name: str = Field(..., min_length=1)
    description: Optional[str] = None
    app_type: str  # mobile, desktop, web, api
    app_url: Optional[str] = None
    app_identifier: str
    pricing_model: Optional[str] = None
    meta_data: Dict[str, Any] = Field(default_factory=dict)

    model_config = {"from_attributes": True}


class ExternalApplicationUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    pricing_model: Optional[str] = None
    meta_data: Optional[Dict[str, Any]] = None

    model_config = {"from_attributes": True}


class ExternalApplicationResponse(BaseModel):
    id: UUID
    name: str
    description: Optional[str]
    app_type: str
    app_url: Optional[str]
    app_identifier: str
    status: str
    pricing_model: Optional[str]
    created_at: str
    updated_at: str

    model_config = {"from_attributes": True}


# API Key Schemas
class APIKeyCreate(BaseModel):
    app_id: UUID
    name: Optional[str] = None
    scopes: List[str] = Field(default_factory=list)
    rate_limit: int = Field(default=1000, ge=1)
    expires_at: Optional[str] = None

    model_config = {"from_attributes": True}


class APIKeyResponse(BaseModel):
    id: UUID
    app_id: UUID
    key_prefix: str
    name: Optional[str]
    scopes: List[str]
    rate_limit: int
    expires_at: Optional[str]
    last_used_at: Optional[str]
    status: str
    created_at: str

    model_config = {"from_attributes": True}


# External App User Schemas
class ExternalAppUserCreate(BaseModel):
    app_id: UUID
    external_user_id: str
    master_user_id: Optional[UUID] = None
    user_data: Dict[str, Any] = Field(default_factory=dict)

    model_config = {"from_attributes": True}


class ExternalAppUserResponse(BaseModel):
    id: UUID
    app_id: UUID
    external_user_id: str
    master_user_id: Optional[UUID]
    status: str
    created_at: str

    model_config = {"from_attributes": True}


# Usage Summary Schemas
class ExternalAppUsageSummary(BaseModel):
    total_requests: int
    total_cost: Decimal
    total_credits_used: int
    requests_by_endpoint: Dict[str, int]
    cost_by_endpoint: Dict[str, Decimal]

    model_config = {"from_attributes": True}

