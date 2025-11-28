"""
Discount & Promotion Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from uuid import UUID
from datetime import datetime
from decimal import Decimal


# Discount Code Schemas
class DiscountCodeCreate(BaseModel):
    code: str = Field(..., min_length=1, max_length=50)
    name: str = Field(..., min_length=1)
    description: Optional[str] = None
    discount_type: str = Field(..., description="percentage, fixed_amount, free_item, buy_x_get_y")
    discount_value: Decimal = Field(..., gt=0)
    min_purchase_amount: Optional[Decimal] = Field(None, ge=0)
    max_discount_amount: Optional[Decimal] = Field(None, ge=0)
    applicable_to: str = Field(..., description="trip, activity, media_service, digital_download, subscription, credit, content, all")
    applicable_item_ids: Optional[List[UUID]] = None
    valid_from: str  # ISO format datetime
    valid_until: str  # ISO format datetime
    usage_limit: Optional[int] = Field(None, gt=0)
    user_limit: int = Field(default=1, ge=1)
    first_time_only: bool = Field(default=False)
    user_group: str = Field(default="all", description="all, member, premium, staff")
    auto_apply: bool = Field(default=False)
    stackable: bool = Field(default=False)
    meta_data: Dict[str, Any] = Field(default_factory=dict)

    model_config = {"from_attributes": True}


class DiscountCodeUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    discount_value: Optional[Decimal] = Field(None, gt=0)
    min_purchase_amount: Optional[Decimal] = Field(None, ge=0)
    max_discount_amount: Optional[Decimal] = Field(None, ge=0)
    valid_from: Optional[str] = None
    valid_until: Optional[str] = None
    usage_limit: Optional[int] = Field(None, gt=0)
    user_limit: Optional[int] = Field(None, ge=1)
    status: Optional[str] = None
    auto_apply: Optional[bool] = None
    stackable: Optional[bool] = None
    meta_data: Optional[Dict[str, Any]] = None

    model_config = {"from_attributes": True}


class DiscountCodeResponse(BaseModel):
    id: UUID
    code: str
    name: str
    description: Optional[str]
    discount_type: str
    discount_value: Decimal
    min_purchase_amount: Optional[Decimal]
    max_discount_amount: Optional[Decimal]
    applicable_to: str
    applicable_item_ids: Optional[List[UUID]]
    valid_from: str
    valid_until: str
    usage_limit: Optional[int]
    usage_count: int
    user_limit: int
    first_time_only: bool
    user_group: str
    status: str
    auto_apply: bool
    stackable: bool
    created_at: str
    updated_at: str

    model_config = {"from_attributes": True}


# Discount Application Schemas
class DiscountApplyRequest(BaseModel):
    discount_code: str
    item_type: str  # trip, activity, media_service, etc.
    item_id: UUID
    original_amount: Decimal = Field(..., gt=0)
    user_id: Optional[UUID] = None

    model_config = {"from_attributes": True}


class DiscountApplyResponse(BaseModel):
    discount_code_id: UUID
    discount_code: str
    discount_type: str
    discount_amount: Decimal
    final_amount: Decimal
    applicable: bool
    message: Optional[str] = None

    model_config = {"from_attributes": True}


# Discount Usage Schemas
class DiscountUsageResponse(BaseModel):
    id: UUID
    discount_code_id: UUID
    user_id: Optional[UUID]
    item_type: str
    item_id: Optional[UUID]
    original_amount: Decimal
    discount_amount: Decimal
    final_amount: Decimal
    used_at: str

    model_config = {"from_attributes": True}


# Discount Analytics Schemas
class DiscountAnalyticsResponse(BaseModel):
    discount_code_id: UUID
    discount_code: str
    total_usage: int
    total_discount_amount: Decimal
    total_revenue: Decimal
    new_users_count: int
    usage_by_date: List[Dict[str, Any]]

    model_config = {"from_attributes": True}

