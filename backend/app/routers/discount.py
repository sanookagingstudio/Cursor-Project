"""
Discount & Promotion API Router
FastAPI endpoints for Phase 13
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.core.db import get_db
from app.services.discount_service import DiscountService
from app.schemas.discount import (
    DiscountCodeCreate,
    DiscountCodeUpdate,
    DiscountCodeResponse,
    DiscountApplyRequest,
    DiscountApplyResponse,
    DiscountUsageResponse,
    DiscountAnalyticsResponse
)

router = APIRouter()


# Discount Codes (Admin)
@router.get("/codes", response_model=List[DiscountCodeResponse])
def get_discount_codes(
    status: Optional[str] = None,
    applicable_to: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all discount codes"""
    return DiscountService.get_discount_codes(db, status, applicable_to)


@router.get("/codes/{code}", response_model=DiscountCodeResponse)
def get_discount_code(
    code: str,
    db: Session = Depends(get_db)
):
    """Get discount code by code string"""
    discount = DiscountService.get_discount_code(db, code)
    if not discount:
        raise HTTPException(status_code=404, detail="Discount code not found")
    return discount


@router.post("/codes", response_model=DiscountCodeResponse, status_code=status.HTTP_201_CREATED)
def create_discount_code(
    discount_data: DiscountCodeCreate,
    db: Session = Depends(get_db)
):
    """Create a new discount code"""
    try:
        return DiscountService.create_discount_code(db, discount_data)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/codes/{discount_id}", response_model=DiscountCodeResponse)
def update_discount_code(
    discount_id: UUID,
    discount_data: DiscountCodeUpdate,
    db: Session = Depends(get_db)
):
    """Update discount code"""
    discount = DiscountService.update_discount_code(db, discount_id, discount_data)
    if not discount:
        raise HTTPException(status_code=404, detail="Discount code not found")
    return discount


# Discount Application
@router.post("/apply", response_model=DiscountApplyResponse)
def apply_discount(
    apply_data: DiscountApplyRequest,
    db: Session = Depends(get_db)
):
    """Apply discount code"""
    response, error = DiscountService.apply_discount(db, apply_data)
    if error:
        raise HTTPException(status_code=400, detail=error)
    return response


@router.get("/auto-apply", response_model=List[DiscountCodeResponse])
def get_auto_apply_discounts(
    item_type: str,
    item_id: UUID,
    original_amount: float,
    user_id: Optional[UUID] = None,
    db: Session = Depends(get_db)
):
    """Get auto-apply discounts"""
    from decimal import Decimal
    return DiscountService.get_auto_apply_discounts(
        db, user_id, item_type, item_id, Decimal(str(original_amount))
    )


@router.get("/best", response_model=Optional[DiscountCodeResponse])
def get_best_discount(
    item_type: str,
    item_id: UUID,
    original_amount: float,
    user_id: Optional[UUID] = None,
    db: Session = Depends(get_db)
):
    """Get best discount (auto-apply)"""
    from decimal import Decimal
    discount = DiscountService.get_best_discount(
        db, user_id, item_type, item_id, Decimal(str(original_amount))
    )
    return discount


# Discount Usage
@router.get("/usage", response_model=List[DiscountUsageResponse])
def get_discount_usage(
    discount_code_id: Optional[UUID] = None,
    user_id: Optional[UUID] = None,
    db: Session = Depends(get_db)
):
    """Get discount usage records"""
    from app.models.discount import DiscountUsage
    query = db.query(DiscountUsage)
    if discount_code_id:
        query = query.filter(DiscountUsage.discount_code_id == discount_code_id)
    if user_id:
        query = query.filter(DiscountUsage.user_id == user_id)
    return query.order_by(DiscountUsage.used_at.desc()).all()


# Discount Analytics
@router.get("/analytics/{discount_code_id}", response_model=DiscountAnalyticsResponse)
def get_discount_analytics(
    discount_code_id: UUID,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get discount analytics"""
    analytics = DiscountService.get_discount_analytics(db, discount_code_id, start_date, end_date)
    return DiscountAnalyticsResponse(**analytics)

