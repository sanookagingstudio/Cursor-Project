"""
Cost & Infrastructure Management Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from uuid import UUID
from datetime import date
from decimal import Decimal


# Infrastructure Item Schemas
class InfrastructureItemCreate(BaseModel):
    name: str = Field(..., min_length=1)
    type: str  # domain, hosting, cdn, storage
    provider: Optional[str] = None
    cost_per_period: Optional[Decimal] = None
    period: Optional[str] = None  # monthly, yearly
    renewal_date: Optional[date] = None
    status: str = Field(default="active")
    auto_renewal: bool = Field(default=False)
    meta_data: Dict[str, Any] = Field(default_factory=dict)

    model_config = {"from_attributes": True}


class InfrastructureItemUpdate(BaseModel):
    name: Optional[str] = None
    provider: Optional[str] = None
    cost_per_period: Optional[Decimal] = None
    period: Optional[str] = None
    renewal_date: Optional[date] = None
    status: Optional[str] = None
    auto_renewal: Optional[bool] = None
    meta_data: Optional[Dict[str, Any]] = None

    model_config = {"from_attributes": True}


class InfrastructureItemResponse(BaseModel):
    id: UUID
    name: str
    type: str
    provider: Optional[str]
    cost_per_period: Optional[Decimal]
    period: Optional[str]
    renewal_date: Optional[date]
    status: str
    auto_renewal: bool
    created_at: str
    updated_at: str

    model_config = {"from_attributes": True}


# AI Provider Cost Schemas
class AIProviderCostCreate(BaseModel):
    provider_name: str = Field(..., min_length=1)
    service_type: Optional[str] = None
    pricing_model: Optional[str] = None
    cost_per_request: Optional[Decimal] = None
    monthly_cost: Optional[Decimal] = None
    free_tier_limit: Optional[int] = None
    billing_cycle: Optional[str] = None
    api_key_status: str = Field(default="active")
    meta_data: Dict[str, Any] = Field(default_factory=dict)

    model_config = {"from_attributes": True}


class AIProviderCostUpdate(BaseModel):
    cost_per_request: Optional[Decimal] = None
    monthly_cost: Optional[Decimal] = None
    current_usage: Optional[int] = None
    api_key_status: Optional[str] = None
    meta_data: Optional[Dict[str, Any]] = None

    model_config = {"from_attributes": True}


class AIProviderCostResponse(BaseModel):
    id: UUID
    provider_name: str
    service_type: Optional[str]
    pricing_model: Optional[str]
    cost_per_request: Optional[Decimal]
    monthly_cost: Optional[Decimal]
    free_tier_limit: Optional[int]
    current_usage: int
    billing_cycle: Optional[str]
    api_key_status: str
    created_at: str
    updated_at: str

    model_config = {"from_attributes": True}


# Third-Party Integration Schemas
class ThirdPartyIntegrationCreate(BaseModel):
    service_name: str = Field(..., min_length=1)
    integration_type: Optional[str] = None
    provider: Optional[str] = None
    pricing_model: Optional[str] = None
    monthly_cost: Optional[Decimal] = None
    usage_limit: Optional[int] = None
    status: str = Field(default="active")
    meta_data: Dict[str, Any] = Field(default_factory=dict)

    model_config = {"from_attributes": True}


class ThirdPartyIntegrationUpdate(BaseModel):
    monthly_cost: Optional[Decimal] = None
    current_usage: Optional[int] = None
    status: Optional[str] = None
    meta_data: Optional[Dict[str, Any]] = None

    model_config = {"from_attributes": True}


class ThirdPartyIntegrationResponse(BaseModel):
    id: UUID
    service_name: str
    integration_type: Optional[str]
    provider: Optional[str]
    pricing_model: Optional[str]
    monthly_cost: Optional[Decimal]
    usage_limit: Optional[int]
    current_usage: int
    status: str
    created_at: str
    updated_at: str

    model_config = {"from_attributes": True}


# Cost Summary Schemas
class CostSummary(BaseModel):
    total_monthly_cost: Decimal
    cost_by_category: Dict[str, Decimal]
    cost_trends: List[Dict[str, Any]]
    upcoming_renewals: List[Dict[str, Any]]

    model_config = {"from_attributes": True}

