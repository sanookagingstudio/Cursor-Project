"""
Discount & Promotion Models
SQLAlchemy models for Phase 13
"""

from sqlalchemy import Column, String, Integer, Boolean, Numeric, Text, ForeignKey, JSON, ARRAY
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
from datetime import datetime
import uuid

from app.core.db import Base


class DiscountCode(Base):
    """Discount code model"""
    __tablename__ = "discount_codes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    code = Column(String(50), unique=True, nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    discount_type = Column(String(50), nullable=False)  # percentage, fixed_amount, free_item, buy_x_get_y
    discount_value = Column(Numeric(10, 2), nullable=False)
    min_purchase_amount = Column(Numeric(10, 2))
    max_discount_amount = Column(Numeric(10, 2))
    applicable_to = Column(String(50), nullable=False)  # trip, activity, media_service, digital_download, subscription, credit, content, all
    applicable_item_ids = Column(ARRAY(UUID))
    valid_from = Column(Text, nullable=False)
    valid_until = Column(Text, nullable=False)
    usage_limit = Column(Integer)
    usage_count = Column(Integer, default=0)
    user_limit = Column(Integer, default=1)
    first_time_only = Column(Boolean, default=False)
    user_group = Column(String(50), default="all")  # all, member, premium, staff
    status = Column(String(50), default="active")  # active, inactive, expired
    auto_apply = Column(Boolean, default=False)
    stackable = Column(Boolean, default=False)
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())
    updated_at = Column(Text, server_default=func.now(), onupdate=func.now())


class DiscountUsage(Base):
    """Discount usage model"""
    __tablename__ = "discount_usage"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    discount_code_id = Column(UUID(as_uuid=True), ForeignKey("discount_codes.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), nullable=True)  # References auth.users
    order_id = Column(UUID(as_uuid=True))
    item_type = Column(String(50), nullable=False)  # trip, activity, media_service, etc.
    item_id = Column(UUID(as_uuid=True))
    original_amount = Column(Numeric(10, 2), nullable=False)
    discount_amount = Column(Numeric(10, 2), nullable=False)
    final_amount = Column(Numeric(10, 2), nullable=False)
    used_at = Column(Text, server_default=func.now())


class DiscountAnalytics(Base):
    """Discount analytics model"""
    __tablename__ = "discount_analytics"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    discount_code_id = Column(UUID(as_uuid=True), ForeignKey("discount_codes.id"), nullable=False)
    date = Column(String, nullable=False)  # DATE as string
    usage_count = Column(Integer, default=0)
    total_discount_amount = Column(Numeric(10, 2), default=0)
    total_revenue = Column(Numeric(10, 2), default=0)
    new_users_count = Column(Integer, default=0)
    created_at = Column(Text, server_default=func.now())

