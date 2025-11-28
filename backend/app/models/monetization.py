"""
Monetization & Payment Models
SQLAlchemy models for Phase 11
"""

from sqlalchemy import Column, String, Integer, Numeric, Boolean, Date, ForeignKey, Text, JSON
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import date
import uuid

from app.core.db import Base


class SubscriptionPlan(Base):
    """Subscription plan model"""
    __tablename__ = "subscription_plans"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    price_monthly = Column(Numeric(10, 2))
    price_yearly = Column(Numeric(10, 2))
    features = Column(JSONB, default={})
    credit_included = Column(Integer, default=0)
    status = Column(String(50), default="active")
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())

    subscriptions = relationship("UserSubscription", back_populates="plan")


class UserSubscription(Base):
    """User subscription model"""
    __tablename__ = "user_subscriptions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)  # References auth.users
    plan_id = Column(UUID(as_uuid=True), ForeignKey("subscription_plans.id"), nullable=True)
    status = Column(String(50), default="active")
    start_date = Column(Date, default=date.today)
    end_date = Column(Date)
    auto_renew = Column(Boolean, default=True)
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())

    plan = relationship("SubscriptionPlan", back_populates="subscriptions")


class UserCredit(Base):
    """User credit balance model"""
    __tablename__ = "user_credits"

    user_id = Column(UUID(as_uuid=True), primary_key=True)  # References auth.users
    balance = Column(Numeric(10, 2), default=0)
    total_earned = Column(Numeric(10, 2), default=0)
    total_spent = Column(Numeric(10, 2), default=0)
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())


class CreditTransaction(Base):
    """Credit transaction model"""
    __tablename__ = "credit_transactions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)  # References auth.users
    type = Column(String(50), nullable=False)  # earned, purchased, spent, expired, refunded
    amount = Column(Numeric(10, 2), nullable=False)
    description = Column(Text)
    related_item_id = Column(UUID(as_uuid=True))  # Content ID, Subscription ID, etc.
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())


class PaymentTransaction(Base):
    """Payment transaction model"""
    __tablename__ = "payment_transactions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)  # References auth.users
    type = Column(String(50), nullable=False)  # subscription, credit_purchase, content_purchase, download
    amount = Column(Numeric(10, 2), nullable=False)
    currency = Column(String(10), default="THB")
    payment_method = Column(String(50))
    payment_provider = Column(String(100))
    provider_transaction_id = Column(String(255))
    status = Column(String(50), default="pending")
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())


class ContentPricing(Base):
    """Content pricing model"""
    __tablename__ = "content_pricing"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_id = Column(UUID(as_uuid=True), nullable=False)
    content_type = Column(String(50), nullable=False)  # image, video, audio, article
    pricing_model = Column(String(50), nullable=False)  # free, one_time, subscription, credit, pay_per_view
    price = Column(Numeric(10, 2))
    credit_cost = Column(Integer, default=0)
    free_tier_limit = Column(Integer, default=0)
    trial_days = Column(Integer, default=0)
    status = Column(String(50), default="active")
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())


class Download(Base):
    """Download model"""
    __tablename__ = "downloads"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)  # References auth.users
    content_id = Column(UUID(as_uuid=True), nullable=False)
    download_type = Column(String(50), default="free")  # free, paid, subscription
    payment_transaction_id = Column(UUID(as_uuid=True), ForeignKey("payment_transactions.id"), nullable=True)
    download_url = Column(Text)
    expires_at = Column(Text)
    download_count = Column(Integer, default=0)
    max_downloads = Column(Integer, default=1)
    status = Column(String(50), default="active")
    created_at = Column(Text, server_default=func.now())

