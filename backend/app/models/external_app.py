"""
External Application Integration Models
SQLAlchemy models for Phase 12
"""

from sqlalchemy import Column, String, Integer, Boolean, Date, Numeric, Text, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID, JSONB, ARRAY
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import date
import uuid

from app.core.db import Base


class ExternalApplication(Base):
    """External application model"""
    __tablename__ = "external_applications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    app_type = Column(String(50))  # mobile, desktop, web, api
    app_url = Column(String(500))
    app_identifier = Column(String(255), unique=True)
    status = Column(String(50), default="pending")
    pricing_model = Column(String(50))  # free, paid, subscription, credit
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())

    api_keys = relationship("APIKey", back_populates="app", cascade="all, delete-orphan")
    users = relationship("ExternalAppUser", back_populates="app", cascade="all, delete-orphan")


class APIKey(Base):
    """API key model"""
    __tablename__ = "api_keys"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    app_id = Column(UUID(as_uuid=True), ForeignKey("external_applications.id"), nullable=False)
    key_hash = Column(String(255), unique=True, nullable=False)
    key_prefix = Column(String(20), nullable=False)
    name = Column(String(255))
    scopes = Column(ARRAY(Text))
    rate_limit = Column(Integer, default=1000)
    expires_at = Column(Text)
    last_used_at = Column(Text)
    status = Column(String(50), default="active")
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())

    app = relationship("ExternalApplication", back_populates="api_keys")


class ExternalAppUser(Base):
    """External app user model"""
    __tablename__ = "external_app_users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    app_id = Column(UUID(as_uuid=True), ForeignKey("external_applications.id"), nullable=False)
    external_user_id = Column(String(255), nullable=False)
    master_user_id = Column(UUID(as_uuid=True), nullable=True)  # References auth.users
    user_data = Column(JSONB, default={})
    status = Column(String(50), default="active")
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())

    app = relationship("ExternalApplication", back_populates="users")


class ExternalAppUsage(Base):
    """External app usage model"""
    __tablename__ = "external_app_usage"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    app_id = Column(UUID(as_uuid=True), ForeignKey("external_applications.id"), nullable=False)
    api_key_id = Column(UUID(as_uuid=True), ForeignKey("api_keys.id"), nullable=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("external_app_users.id"), nullable=True)
    endpoint = Column(String(255))
    method = Column(String(10))  # GET, POST, etc.
    request_data = Column(JSONB, default={})
    response_status = Column(Integer)
    response_data = Column(JSONB, default={})
    cost = Column(Numeric(10, 4))
    credits_used = Column(Integer, default=0)
    duration_ms = Column(Integer)
    created_at = Column(Text, server_default=func.now())


class ExternalAppPricing(Base):
    """External app pricing model"""
    __tablename__ = "external_app_pricing"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    app_id = Column(UUID(as_uuid=True), ForeignKey("external_applications.id"), nullable=False)
    feature_name = Column(String(255))
    pricing_type = Column(String(50))  # per_request, subscription, credit, free
    price_per_request = Column(Numeric(10, 4))
    credit_cost = Column(Integer)
    free_tier_limit = Column(Integer)
    subscription_price = Column(Numeric(10, 2))
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())


class ExternalAppSubscription(Base):
    """External app subscription model"""
    __tablename__ = "external_app_subscriptions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    app_id = Column(UUID(as_uuid=True), ForeignKey("external_applications.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("external_app_users.id"), nullable=False)
    plan_name = Column(String(255))
    price = Column(Numeric(10, 2))
    billing_cycle = Column(String(20))  # monthly, yearly
    status = Column(String(50), default="active")
    start_date = Column(Date, default=date.today)
    end_date = Column(Date)
    auto_renew = Column(Boolean, default=True)
    created_at = Column(Text, server_default=func.now())


class ExternalAppPayment(Base):
    """External app payment model"""
    __tablename__ = "external_app_payments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    app_id = Column(UUID(as_uuid=True), ForeignKey("external_applications.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("external_app_users.id"), nullable=False)
    amount = Column(Numeric(10, 2), nullable=False)
    currency = Column(String(10), default="THB")
    payment_type = Column(String(50))  # credit_purchase, subscription, one_time
    status = Column(String(50), default="pending")
    provider_transaction_id = Column(String(255))
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())

