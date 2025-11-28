"""
Cost & Infrastructure Management Models
SQLAlchemy models for Phase 9
"""

from sqlalchemy import Column, String, Integer, Boolean, Date, Numeric, Text, JSON
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
import uuid

from app.core.db import Base


class InfrastructureItem(Base):
    """Infrastructure item model"""
    __tablename__ = "infrastructure_items"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    type = Column(String(50), nullable=False)  # domain, hosting, cdn, storage
    provider = Column(String(255))
    cost_per_period = Column(Numeric(10, 2))
    period = Column(String(20))  # monthly, yearly
    renewal_date = Column(Date)
    status = Column(String(50), default="active")
    auto_renewal = Column(Boolean, default=False)
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())


class AIProviderCost(Base):
    """AI provider cost model"""
    __tablename__ = "ai_provider_costs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    provider_name = Column(String(255), nullable=False)
    service_type = Column(String(50))  # image, video, audio, text
    pricing_model = Column(String(50))  # pay_per_use, subscription, free
    cost_per_request = Column(Numeric(10, 4))
    monthly_cost = Column(Numeric(10, 2))
    free_tier_limit = Column(Integer)
    current_usage = Column(Integer, default=0)
    billing_cycle = Column(String(20))  # monthly, yearly
    api_key_status = Column(String(50), default="active")
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())


class ThirdPartyIntegration(Base):
    """Third-party integration model"""
    __tablename__ = "third_party_integrations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    service_name = Column(String(255), nullable=False)
    integration_type = Column(String(50))  # auth, payment, database, etc.
    provider = Column(String(255))
    pricing_model = Column(String(50))
    monthly_cost = Column(Numeric(10, 2))
    usage_limit = Column(Integer)
    current_usage = Column(Integer, default=0)
    status = Column(String(50), default="active")
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())


class CostRecord(Base):
    """Cost record model (historical)"""
    __tablename__ = "cost_records"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    item_type = Column(String(50), nullable=False)  # infrastructure, ai_provider, third_party
    item_id = Column(UUID(as_uuid=True), nullable=False)
    cost = Column(Numeric(10, 2), nullable=False)
    period_start = Column(Date)
    period_end = Column(Date)
    usage_data = Column(JSONB, default={})
    created_at = Column(Text, server_default=func.now())
