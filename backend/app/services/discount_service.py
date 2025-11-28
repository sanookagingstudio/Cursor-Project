"""
Discount & Promotion Service
Business logic for Phase 13
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from datetime import datetime
from typing import Optional, List, Dict, Any
from uuid import UUID
from decimal import Decimal

from app.models.discount import (
    DiscountCode,
    DiscountUsage,
    DiscountAnalytics
)
from app.schemas.discount import (
    DiscountCodeCreate,
    DiscountCodeUpdate,
    DiscountApplyRequest
)


class DiscountService:
    """Service for discount and promotion operations"""

    @staticmethod
    def get_discount_codes(
        db: Session,
        status: Optional[str] = None,
        applicable_to: Optional[str] = None
    ) -> List[DiscountCode]:
        """Get all discount codes"""
        query = db.query(DiscountCode)
        if status:
            query = query.filter(DiscountCode.status == status)
        if applicable_to:
            query = query.filter(
                or_(
                    DiscountCode.applicable_to == applicable_to,
                    DiscountCode.applicable_to == "all"
                )
            )
        return query.all()

    @staticmethod
    def get_discount_code(db: Session, code: str) -> Optional[DiscountCode]:
        """Get discount code by code string"""
        return db.query(DiscountCode).filter(
            and_(
                DiscountCode.code == code.upper(),
                DiscountCode.status == "active"
            )
        ).first()

    @staticmethod
    def create_discount_code(db: Session, discount_data: DiscountCodeCreate) -> DiscountCode:
        """Create a new discount code"""
        # Check if code already exists
        existing = db.query(DiscountCode).filter(DiscountCode.code == discount_data.code.upper()).first()
        if existing:
            raise ValueError(f"Discount code '{discount_data.code}' already exists")
        
        discount = DiscountCode(
            code=discount_data.code.upper(),
            **discount_data.model_dump(exclude={"code"})
        )
        db.add(discount)
        db.commit()
        db.refresh(discount)
        return discount

    @staticmethod
    def update_discount_code(
        db: Session,
        discount_id: UUID,
        discount_data: DiscountCodeUpdate
    ) -> Optional[DiscountCode]:
        """Update discount code"""
        discount = db.query(DiscountCode).filter(DiscountCode.id == discount_id).first()
        if not discount:
            return None
        
        update_data = discount_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(discount, key, value)
        
        db.commit()
        db.refresh(discount)
        return discount

    @staticmethod
    def validate_discount_code(
        db: Session,
        code: str,
        user_id: Optional[UUID],
        item_type: str,
        item_id: UUID,
        original_amount: Decimal
    ) -> tuple[Optional[DiscountCode], Optional[str]]:
        """Validate discount code"""
        discount = DiscountService.get_discount_code(db, code)
        if not discount:
            return None, "Discount code not found"
        
        # Check validity period
        now = datetime.now()
        valid_from = datetime.fromisoformat(discount.valid_from.replace('Z', '+00:00'))
        valid_until = datetime.fromisoformat(discount.valid_until.replace('Z', '+00:00'))
        
        if now < valid_from:
            return None, "Discount code not yet valid"
        if now > valid_until:
            return None, "Discount code has expired"
        
        # Check usage limit
        if discount.usage_limit and discount.usage_count >= discount.usage_limit:
            return None, "Discount code usage limit reached"
        
        # Check applicable to
        if discount.applicable_to != "all" and discount.applicable_to != item_type:
            return None, f"Discount code not applicable to {item_type}"
        
        # Check applicable item IDs
        if discount.applicable_item_ids and item_id not in discount.applicable_item_ids:
            return None, "Discount code not applicable to this item"
        
        # Check min purchase amount
        if discount.min_purchase_amount and original_amount < discount.min_purchase_amount:
            return None, f"Minimum purchase amount of {discount.min_purchase_amount} required"
        
        # Check first time only
        if discount.first_time_only and user_id:
            usage_count = db.query(DiscountUsage).filter(
                and_(
                    DiscountUsage.user_id == user_id,
                    DiscountUsage.discount_code_id == discount.id
                )
            ).count()
            if usage_count > 0:
                return None, "Discount code can only be used once per user"
        
        # Check user limit
        if user_id:
            user_usage_count = db.query(DiscountUsage).filter(
                and_(
                    DiscountUsage.user_id == user_id,
                    DiscountUsage.discount_code_id == discount.id
                )
            ).count()
            if user_usage_count >= discount.user_limit:
                return None, f"User has reached the usage limit for this discount code"
        
        return discount, None

    @staticmethod
    def calculate_discount(
        discount: DiscountCode,
        original_amount: Decimal
    ) -> Decimal:
        """Calculate discount amount"""
        if discount.discount_type == "percentage":
            discount_amount = original_amount * (discount.discount_value / Decimal("100"))
            if discount.max_discount_amount:
                discount_amount = min(discount_amount, discount.max_discount_amount)
        elif discount.discount_type == "fixed_amount":
            discount_amount = discount.discount_value
        elif discount.discount_type == "free_item":
            discount_amount = original_amount  # Free
        else:  # buy_x_get_y
            discount_amount = Decimal("0")  # TODO: Implement buy_x_get_y logic
        
        # Ensure discount doesn't exceed original amount
        discount_amount = min(discount_amount, original_amount)
        return discount_amount

    @staticmethod
    def apply_discount(
        db: Session,
        apply_data: DiscountApplyRequest
    ) -> tuple[Optional[DiscountApplyResponse], Optional[str]]:
        """Apply discount code"""
        discount, error = DiscountService.validate_discount_code(
            db,
            apply_data.discount_code,
            apply_data.user_id,
            apply_data.item_type,
            apply_data.item_id,
            apply_data.original_amount
        )
        
        if error:
            return None, error
        
        if not discount:
            return None, "Discount code not found"
        
        # Calculate discount
        discount_amount = DiscountService.calculate_discount(discount, apply_data.original_amount)
        final_amount = apply_data.original_amount - discount_amount
        
        # Record usage
        usage = DiscountUsage(
            discount_code_id=discount.id,
            user_id=apply_data.user_id,
            item_type=apply_data.item_type,
            item_id=apply_data.item_id,
            original_amount=apply_data.original_amount,
            discount_amount=discount_amount,
            final_amount=final_amount
        )
        db.add(usage)
        
        # Update discount usage count
        discount.usage_count += 1
        db.commit()
        db.refresh(usage)
        
        response = DiscountApplyResponse(
            discount_code_id=discount.id,
            discount_code=discount.code,
            discount_type=discount.discount_type,
            discount_amount=discount_amount,
            final_amount=final_amount,
            applicable=True,
            message="Discount applied successfully"
        )
        
        return response, None

    @staticmethod
    def get_auto_apply_discounts(
        db: Session,
        user_id: Optional[UUID],
        item_type: str,
        item_id: UUID,
        original_amount: Decimal
    ) -> List[DiscountCode]:
        """Get auto-apply discounts"""
        now = datetime.now().isoformat()
        
        query = db.query(DiscountCode).filter(
            and_(
                DiscountCode.status == "active",
                DiscountCode.auto_apply == True,
                DiscountCode.valid_from <= now,
                DiscountCode.valid_until >= now
            )
        )
        
        # Filter by applicable_to
        query = query.filter(
            or_(
                DiscountCode.applicable_to == item_type,
                DiscountCode.applicable_to == "all"
            )
        )
        
        discounts = query.all()
        
        # Filter by validation rules
        valid_discounts = []
        for discount in discounts:
            _, error = DiscountService.validate_discount_code(
                db,
                discount.code,
                user_id,
                item_type,
                item_id,
                original_amount
            )
            if not error:
                valid_discounts.append(discount)
        
        return valid_discounts

    @staticmethod
    def get_best_discount(
        db: Session,
        user_id: Optional[UUID],
        item_type: str,
        item_id: UUID,
        original_amount: Decimal
    ) -> Optional[DiscountCode]:
        """Get best discount (highest discount amount)"""
        auto_discounts = DiscountService.get_auto_apply_discounts(
            db, user_id, item_type, item_id, original_amount
        )
        
        if not auto_discounts:
            return None
        
        best_discount = None
        best_amount = Decimal("0")
        
        for discount in auto_discounts:
            discount_amount = DiscountService.calculate_discount(discount, original_amount)
            if discount_amount > best_amount:
                best_amount = discount_amount
                best_discount = discount
        
        return best_discount

    @staticmethod
    def get_discount_analytics(
        db: Session,
        discount_code_id: UUID,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None
    ) -> Dict[str, Any]:
        """Get discount analytics"""
        query = db.query(DiscountUsage).filter(
            DiscountUsage.discount_code_id == discount_code_id
        )
        
        if start_date:
            query = query.filter(DiscountUsage.used_at >= start_date)
        if end_date:
            query = query.filter(DiscountUsage.used_at <= end_date)
        
        usages = query.all()
        
        total_usage = len(usages)
        total_discount_amount = sum(usage.discount_amount for usage in usages)
        total_revenue = sum(usage.final_amount for usage in usages)
        
        # Count new users (first-time users)
        user_ids = set(usage.user_id for usage in usages if usage.user_id)
        new_users_count = 0
        for user_id in user_ids:
            # Check if this is user's first purchase
            first_usage = db.query(DiscountUsage).filter(
                DiscountUsage.user_id == user_id
            ).order_by(DiscountUsage.used_at).first()
            if first_usage and first_usage.discount_code_id == discount_code_id:
                new_users_count += 1
        
        # Group by date
        usage_by_date = {}
        for usage in usages:
            date = usage.used_at[:10]  # Extract date
            if date not in usage_by_date:
                usage_by_date[date] = {
                    "date": date,
                    "usage_count": 0,
                    "discount_amount": Decimal("0"),
                    "revenue": Decimal("0")
                }
            usage_by_date[date]["usage_count"] += 1
            usage_by_date[date]["discount_amount"] += usage.discount_amount
            usage_by_date[date]["revenue"] += usage.final_amount
        
        discount = db.query(DiscountCode).filter(DiscountCode.id == discount_code_id).first()
        
        return {
            "discount_code_id": discount_code_id,
            "discount_code": discount.code if discount else "",
            "total_usage": total_usage,
            "total_discount_amount": float(total_discount_amount),
            "total_revenue": float(total_revenue),
            "new_users_count": new_users_count,
            "usage_by_date": [
                {
                    "date": v["date"],
                    "usage_count": v["usage_count"],
                    "discount_amount": float(v["discount_amount"]),
                    "revenue": float(v["revenue"])
                }
                for v in usage_by_date.values()
            ]
        }

