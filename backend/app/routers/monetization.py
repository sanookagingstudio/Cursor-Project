"""
Monetization & Payment API Router
FastAPI endpoints for Phase 11
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID
from datetime import date

from app.core.db import get_db
from app.services.monetization_service import MonetizationService
from app.schemas.monetization import (
    SubscriptionPlanCreate,
    SubscriptionPlanUpdate,
    SubscriptionPlanResponse,
    UserSubscriptionCreate,
    UserSubscriptionResponse,
    CreditBalanceResponse,
    CreditPurchaseRequest,
    CreditTransactionResponse,
    PaymentCreateRequest,
    PaymentResponse,
    ContentPricingCreate,
    ContentPricingUpdate,
    ContentPricingResponse,
    DownloadRequest,
    DownloadResponse,
    RevenueSummary
)

router = APIRouter()


# Subscription Plans
@router.get("/plans", response_model=List[SubscriptionPlanResponse])
def get_subscription_plans(
    status: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all subscription plans"""
    plans = MonetizationService.get_subscription_plans(db, status)
    return plans


@router.get("/plans/{plan_id}", response_model=SubscriptionPlanResponse)
def get_subscription_plan(
    plan_id: UUID,
    db: Session = Depends(get_db)
):
    """Get subscription plan by ID"""
    plan = MonetizationService.get_subscription_plan(db, plan_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Subscription plan not found")
    return plan


@router.post("/plans", response_model=SubscriptionPlanResponse, status_code=status.HTTP_201_CREATED)
def create_subscription_plan(
    plan_data: SubscriptionPlanCreate,
    db: Session = Depends(get_db)
):
    """Create a new subscription plan"""
    return MonetizationService.create_subscription_plan(db, plan_data)


@router.put("/plans/{plan_id}", response_model=SubscriptionPlanResponse)
def update_subscription_plan(
    plan_id: UUID,
    plan_data: SubscriptionPlanUpdate,
    db: Session = Depends(get_db)
):
    """Update subscription plan"""
    plan = MonetizationService.update_subscription_plan(db, plan_id, plan_data)
    if not plan:
        raise HTTPException(status_code=404, detail="Subscription plan not found")
    return plan


# User Subscriptions
@router.get("/subscriptions/{user_id}", response_model=Optional[UserSubscriptionResponse])
def get_user_subscription(
    user_id: UUID,
    db: Session = Depends(get_db)
):
    """Get user's active subscription"""
    subscription = MonetizationService.get_user_subscription(db, user_id)
    return subscription


@router.post("/subscriptions", response_model=UserSubscriptionResponse, status_code=status.HTTP_201_CREATED)
def create_user_subscription(
    subscription_data: UserSubscriptionCreate,
    db: Session = Depends(get_db)
):
    """Create user subscription"""
    try:
        return MonetizationService.create_user_subscription(db, subscription_data)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


# Credits
@router.get("/credits/{user_id}", response_model=CreditBalanceResponse)
def get_user_credits(
    user_id: UUID,
    db: Session = Depends(get_db)
):
    """Get user credit balance"""
    credit = MonetizationService.get_user_credits(db, user_id)
    if not credit:
        raise HTTPException(status_code=404, detail="User credits not found")
    return credit


@router.post("/credits/{user_id}/purchase", response_model=PaymentResponse)
def purchase_credits(
    user_id: UUID,
    purchase_data: CreditPurchaseRequest,
    discount_code: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Purchase credits"""
    return MonetizationService.purchase_credits(db, user_id, purchase_data, discount_code)


# Payments
@router.post("/payments", response_model=PaymentResponse, status_code=status.HTTP_201_CREATED)
def create_payment(
    user_id: UUID,
    payment_data: PaymentCreateRequest,
    db: Session = Depends(get_db)
):
    """Create payment transaction"""
    return MonetizationService.create_payment(db, user_id, payment_data)


@router.get("/payments/{payment_id}", response_model=PaymentResponse)
def get_payment(
    payment_id: UUID,
    db: Session = Depends(get_db)
):
    """Get payment transaction"""
    from app.models.monetization import PaymentTransaction
    payment = db.query(PaymentTransaction).filter(PaymentTransaction.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    return payment


# Content Pricing
@router.get("/pricing/{content_id}", response_model=Optional[ContentPricingResponse])
def get_content_pricing(
    content_id: UUID,
    db: Session = Depends(get_db)
):
    """Get content pricing"""
    pricing = MonetizationService.get_content_pricing(db, content_id)
    return pricing


@router.post("/pricing", response_model=ContentPricingResponse, status_code=status.HTTP_201_CREATED)
def set_content_pricing(
    pricing_data: ContentPricingCreate,
    db: Session = Depends(get_db)
):
    """Set content pricing"""
    return MonetizationService.set_content_pricing(db, pricing_data)


@router.put("/pricing/{pricing_id}", response_model=ContentPricingResponse)
def update_content_pricing(
    pricing_id: UUID,
    pricing_data: ContentPricingUpdate,
    db: Session = Depends(get_db)
):
    """Update content pricing"""
    from app.models.monetization import ContentPricing
    pricing = db.query(ContentPricing).filter(ContentPricing.id == pricing_id).first()
    if not pricing:
        raise HTTPException(status_code=404, detail="Content pricing not found")
    
    update_data = pricing_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(pricing, key, value)
    
    db.commit()
    db.refresh(pricing)
    return pricing


# Downloads
@router.post("/downloads", response_model=DownloadResponse, status_code=status.HTTP_201_CREATED)
def request_download(
    user_id: UUID,
    download_data: DownloadRequest,
    db: Session = Depends(get_db)
):
    """Request download for content"""
    try:
        return MonetizationService.request_download(db, user_id, download_data)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


# Revenue
@router.get("/revenue", response_model=RevenueSummary)
def get_revenue_summary(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db)
):
    """Get revenue summary"""
    summary = MonetizationService.get_revenue_summary(db, start_date, end_date)
    return RevenueSummary(**summary)

