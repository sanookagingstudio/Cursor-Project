"""
Monetization & Payment Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from uuid import UUID
from datetime import date
from decimal import Decimal


# Subscription Plan Schemas
class SubscriptionPlanCreate(BaseModel):
    name: str = Field(..., min_length=1)
    description: Optional[str] = None
    price_monthly: Optional[Decimal] = None
    price_yearly: Optional[Decimal] = None
    features: Dict[str, Any] = Field(default_factory=dict)
    credit_included: int = Field(default=0, ge=0)
    status: str = Field(default="active")

    model_config = {"from_attributes": True}


class SubscriptionPlanUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price_monthly: Optional[Decimal] = None
    price_yearly: Optional[Decimal] = None
    features: Optional[Dict[str, Any]] = None
    credit_included: Optional[int] = Field(None, ge=0)
    status: Optional[str] = None

    model_config = {"from_attributes": True}


class SubscriptionPlanResponse(BaseModel):
    id: UUID
    name: str
    description: Optional[str]
    price_monthly: Optional[Decimal]
    price_yearly: Optional[Decimal]
    features: Dict[str, Any]
    credit_included: int
    status: str
    created_at: str
    updated_at: str

    model_config = {"from_attributes": True}


# User Subscription Schemas
class UserSubscriptionCreate(BaseModel):
    user_id: UUID
    plan_id: UUID
    auto_renew: bool = Field(default=True)

    model_config = {"from_attributes": True}


class UserSubscriptionUpdate(BaseModel):
    plan_id: Optional[UUID] = None
    status: Optional[str] = None
    auto_renew: Optional[bool] = None

    model_config = {"from_attributes": True}


class UserSubscriptionResponse(BaseModel):
    id: UUID
    user_id: UUID
    plan_id: Optional[UUID]
    status: str
    start_date: date
    end_date: Optional[date]
    auto_renew: bool
    created_at: str
    updated_at: str
    plan: Optional[SubscriptionPlanResponse] = None

    model_config = {"from_attributes": True}


# Credit Schemas
class CreditBalanceResponse(BaseModel):
    user_id: UUID
    balance: Decimal
    total_earned: Decimal
    total_spent: Decimal
    updated_at: str

    model_config = {"from_attributes": True}


class CreditPurchaseRequest(BaseModel):
    amount: int = Field(..., gt=0)  # Credit amount to purchase
    payment_method: Optional[str] = None
    discount_code: Optional[str] = None  # Optional discount code

    model_config = {"from_attributes": True}


class CreditTransactionResponse(BaseModel):
    id: UUID
    user_id: UUID
    type: str
    amount: Decimal
    description: Optional[str]
    related_item_id: Optional[UUID]
    metadata: Dict[str, Any]
    created_at: str

    model_config = {"from_attributes": True}


# Payment Schemas
class PaymentCreateRequest(BaseModel):
    type: str  # subscription, credit_purchase, content_purchase, download
    amount: Decimal = Field(..., gt=0)
    currency: str = Field(default="THB")
    payment_method: str
    metadata: Optional[Dict[str, Any]] = None

    model_config = {"from_attributes": True}


class PaymentResponse(BaseModel):
    id: UUID
    user_id: UUID
    type: str
    amount: Decimal
    currency: str
    payment_method: Optional[str]
    payment_provider: Optional[str]
    provider_transaction_id: Optional[str]
    status: str
    metadata: Dict[str, Any]
    created_at: str
    updated_at: str

    model_config = {"from_attributes": True}


# Content Pricing Schemas
class ContentPricingCreate(BaseModel):
    content_id: UUID
    content_type: str
    pricing_model: str  # free, one_time, subscription, credit, pay_per_view
    price: Optional[Decimal] = None
    credit_cost: int = Field(default=0, ge=0)
    free_tier_limit: int = Field(default=0, ge=0)
    trial_days: int = Field(default=0, ge=0)
    status: str = Field(default="active")

    model_config = {"from_attributes": True}


class ContentPricingUpdate(BaseModel):
    pricing_model: Optional[str] = None
    price: Optional[Decimal] = None
    credit_cost: Optional[int] = Field(None, ge=0)
    free_tier_limit: Optional[int] = Field(None, ge=0)
    trial_days: Optional[int] = Field(None, ge=0)
    status: Optional[str] = None

    model_config = {"from_attributes": True}


class ContentPricingResponse(BaseModel):
    id: UUID
    content_id: UUID
    content_type: str
    pricing_model: str
    price: Optional[Decimal]
    credit_cost: int
    free_tier_limit: int
    trial_days: int
    status: str
    created_at: str
    updated_at: str

    model_config = {"from_attributes": True}


# Download Schemas
class DownloadRequest(BaseModel):
    content_id: UUID

    model_config = {"from_attributes": True}


class DownloadResponse(BaseModel):
    id: UUID
    user_id: UUID
    content_id: UUID
    download_type: str
    download_url: Optional[str]
    expires_at: Optional[str]
    download_count: int
    max_downloads: int
    status: str
    created_at: str

    model_config = {"from_attributes": True}


# Revenue Schemas
class RevenueSummary(BaseModel):
    total_revenue: Decimal
    revenue_by_type: Dict[str, Decimal]
    revenue_by_period: Dict[str, Decimal]
    transaction_count: int

    model_config = {"from_attributes": True}

