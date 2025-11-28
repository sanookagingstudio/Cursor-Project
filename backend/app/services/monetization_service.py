"""
Monetization & Payment Service
Business logic for Phase 11
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_, func, desc
from decimal import Decimal
from datetime import date, datetime, timedelta
from typing import Optional, List, Dict, Any
from uuid import UUID

from app.models.monetization import (
    SubscriptionPlan,
    UserSubscription,
    UserCredit,
    CreditTransaction,
    PaymentTransaction,
    ContentPricing,
    Download
)
from app.schemas.monetization import (
    SubscriptionPlanCreate,
    SubscriptionPlanUpdate,
    UserSubscriptionCreate,
    CreditPurchaseRequest,
    PaymentCreateRequest,
    ContentPricingCreate,
    ContentPricingUpdate,
    DownloadRequest
)


class MonetizationService:
    """Service for monetization and payment operations"""

    @staticmethod
    def get_subscription_plans(db: Session, status: Optional[str] = None) -> List[SubscriptionPlan]:
        """Get all subscription plans"""
        query = db.query(SubscriptionPlan)
        if status:
            query = query.filter(SubscriptionPlan.status == status)
        return query.all()

    @staticmethod
    def get_subscription_plan(db: Session, plan_id: UUID) -> Optional[SubscriptionPlan]:
        """Get subscription plan by ID"""
        return db.query(SubscriptionPlan).filter(SubscriptionPlan.id == plan_id).first()

    @staticmethod
    def create_subscription_plan(db: Session, plan_data: SubscriptionPlanCreate) -> SubscriptionPlan:
        """Create a new subscription plan"""
        plan = SubscriptionPlan(**plan_data.model_dump())
        db.add(plan)
        db.commit()
        db.refresh(plan)
        return plan

    @staticmethod
    def update_subscription_plan(db: Session, plan_id: UUID, plan_data: SubscriptionPlanUpdate) -> Optional[SubscriptionPlan]:
        """Update subscription plan"""
        plan = db.query(SubscriptionPlan).filter(SubscriptionPlan.id == plan_id).first()
        if not plan:
            return None
        
        update_data = plan_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(plan, key, value)
        
        db.commit()
        db.refresh(plan)
        return plan

    @staticmethod
    def get_user_subscription(db: Session, user_id: UUID) -> Optional[UserSubscription]:
        """Get user's active subscription"""
        return db.query(UserSubscription).filter(
            and_(
                UserSubscription.user_id == user_id,
                UserSubscription.status == "active"
            )
        ).first()

    @staticmethod
    def create_user_subscription(db: Session, subscription_data: UserSubscriptionCreate) -> UserSubscription:
        """Create user subscription"""
        plan = db.query(SubscriptionPlan).filter(SubscriptionPlan.id == subscription_data.plan_id).first()
        if not plan:
            raise ValueError("Subscription plan not found")
        
        # Calculate end date (30 days for monthly, 365 for yearly)
        start = date.today()
        if plan.price_monthly and plan.price_monthly > 0:
            end = start + timedelta(days=30)
        elif plan.price_yearly and plan.price_yearly > 0:
            end = start + timedelta(days=365)
        else:
            end = None  # Free plan
        
        subscription = UserSubscription(
            user_id=subscription_data.user_id,
            plan_id=subscription_data.plan_id,
            start_date=start,
            end_date=end,
            auto_renew=subscription_data.auto_renew,
            status="active"
        )
        db.add(subscription)
        
        # Add included credits
        if plan.credit_included > 0:
            MonetizationService.add_credits(db, subscription_data.user_id, plan.credit_included, "subscription_bonus", subscription.id)
        
        db.commit()
        db.refresh(subscription)
        return subscription

    @staticmethod
    def get_user_credits(db: Session, user_id: UUID) -> Optional[UserCredit]:
        """Get user credit balance"""
        credit = db.query(UserCredit).filter(UserCredit.user_id == user_id).first()
        if not credit:
            # Create credit record if doesn't exist
            credit = UserCredit(user_id=user_id, balance=Decimal("0"))
            db.add(credit)
            db.commit()
            db.refresh(credit)
        return credit

    @staticmethod
    def add_credits(db: Session, user_id: UUID, amount: int, description: str, related_item_id: Optional[UUID] = None) -> UserCredit:
        """Add credits to user"""
        credit = MonetizationService.get_user_credits(db, user_id)
        credit.balance += Decimal(str(amount))
        credit.total_earned += Decimal(str(amount))
        
        # Create transaction record
        transaction = CreditTransaction(
            user_id=user_id,
            type="earned",
            amount=Decimal(str(amount)),
            description=description,
            related_item_id=related_item_id
        )
        db.add(transaction)
        db.commit()
        db.refresh(credit)
        return credit

    @staticmethod
    def spend_credits(db: Session, user_id: UUID, amount: int, description: str, related_item_id: Optional[UUID] = None) -> bool:
        """Spend credits from user"""
        credit = MonetizationService.get_user_credits(db, user_id)
        if credit.balance < Decimal(str(amount)):
            return False
        
        credit.balance -= Decimal(str(amount))
        credit.total_spent += Decimal(str(amount))
        
        # Create transaction record
        transaction = CreditTransaction(
            user_id=user_id,
            type="spent",
            amount=Decimal(str(amount)),
            description=description,
            related_item_id=related_item_id
        )
        db.add(transaction)
        db.commit()
        return True

    @staticmethod
    def purchase_credits(db: Session, user_id: UUID, purchase_data: CreditPurchaseRequest, discount_code: Optional[str] = None) -> PaymentTransaction:
        """Purchase credits"""
        # Credit packages: 100 credits = 50 THB, 500 = 200 THB, 1000 = 350 THB
        credit_packages = {
            100: 50,
            500: 200,
            1000: 350
        }
        
        amount = purchase_data.amount
        price = credit_packages.get(amount, amount * Decimal("0.5"))  # Default 0.5 THB per credit
        original_price = Decimal(str(price))
        discount_amount = Decimal("0")
        
        # Apply discount if provided
        if discount_code:
            from app.services.discount_service import DiscountService
            from app.schemas.discount import DiscountApplyRequest
            apply_data = DiscountApplyRequest(
                discount_code=discount_code,
                item_type="credit",
                item_id=user_id,  # Use user_id as item_id for credit purchase
                original_amount=original_price,
                user_id=user_id
            )
            discount_response, error = DiscountService.apply_discount(db, apply_data)
            if discount_response:
                discount_amount = discount_response.discount_amount
                price = discount_response.final_amount
        
        # Create payment transaction
        payment = PaymentTransaction(
            user_id=user_id,
            type="credit_purchase",
            amount=price,
            currency="THB",
            payment_method=purchase_data.payment_method or "card",
            status="pending",
            metadata={"original_amount": float(original_price), "discount_amount": float(discount_amount), "discount_code": discount_code}
        )
        db.add(payment)
        db.commit()
        db.refresh(payment)
        
        # TODO: Process payment through payment provider
        # For now, assume payment is successful
        payment.status = "completed"
        MonetizationService.add_credits(db, user_id, amount, f"Purchased {amount} credits", payment.id)
        
        db.commit()
        db.refresh(payment)
        return payment

    @staticmethod
    def create_payment(db: Session, user_id: UUID, payment_data: PaymentCreateRequest) -> PaymentTransaction:
        """Create payment transaction"""
        payment = PaymentTransaction(
            user_id=user_id,
            **payment_data.model_dump()
        )
        db.add(payment)
        db.commit()
        db.refresh(payment)
        return payment

    @staticmethod
    def get_content_pricing(db: Session, content_id: UUID) -> Optional[ContentPricing]:
        """Get content pricing"""
        return db.query(ContentPricing).filter(
            and_(
                ContentPricing.content_id == content_id,
                ContentPricing.status == "active"
            )
        ).first()

    @staticmethod
    def set_content_pricing(db: Session, pricing_data: ContentPricingCreate) -> ContentPricing:
        """Set content pricing"""
        # Check if pricing exists
        existing = db.query(ContentPricing).filter(
            and_(
                ContentPricing.content_id == pricing_data.content_id,
                ContentPricing.status == "active"
            )
        ).first()
        
        if existing:
            # Update existing
            for key, value in pricing_data.model_dump().items():
                setattr(existing, key, value)
            db.commit()
            db.refresh(existing)
            return existing
        else:
            # Create new
            pricing = ContentPricing(**pricing_data.model_dump())
            db.add(pricing)
            db.commit()
            db.refresh(pricing)
            return pricing

    @staticmethod
    def request_download(db: Session, user_id: UUID, download_data: DownloadRequest) -> Optional[Download]:
        """Request download for content"""
        pricing = MonetizationService.get_content_pricing(db, download_data.content_id)
        
        if not pricing:
            # Free if no pricing set
            download_type = "free"
        elif pricing.pricing_model == "free":
            download_type = "free"
        elif pricing.pricing_model == "credit":
            # Check if user has enough credits
            credit = MonetizationService.get_user_credits(db, user_id)
            if credit.balance >= Decimal(str(pricing.credit_cost)):
                MonetizationService.spend_credits(db, user_id, pricing.credit_cost, f"Download content {download_data.content_id}", download_data.content_id)
                download_type = "paid"
            else:
                raise ValueError("Insufficient credits")
        elif pricing.pricing_model == "subscription":
            # Check if user has active subscription
            subscription = MonetizationService.get_user_subscription(db, user_id)
            if subscription:
                download_type = "subscription"
            else:
                raise ValueError("Subscription required")
        else:
            # One-time purchase
            download_type = "paid"
        
        download = Download(
            user_id=user_id,
            content_id=download_data.content_id,
            download_type=download_type,
            expires_at=(datetime.now() + timedelta(days=7)).isoformat(),
            max_downloads=1
        )
        db.add(download)
        db.commit()
        db.refresh(download)
        return download

    @staticmethod
    def get_revenue_summary(db: Session, start_date: Optional[date] = None, end_date: Optional[date] = None) -> Dict[str, Any]:
        """Get revenue summary"""
        query = db.query(PaymentTransaction).filter(PaymentTransaction.status == "completed")
        
        if start_date:
            query = query.filter(PaymentTransaction.created_at >= start_date.isoformat())
        if end_date:
            query = query.filter(PaymentTransaction.created_at <= end_date.isoformat())
        
        transactions = query.all()
        
        total_revenue = sum(t.amount for t in transactions)
        revenue_by_type = {}
        for t in transactions:
            revenue_by_type[t.type] = revenue_by_type.get(t.type, Decimal("0")) + t.amount
        
        return {
            "total_revenue": total_revenue,
            "revenue_by_type": revenue_by_type,
            "transaction_count": len(transactions)
        }

