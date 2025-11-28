"""
Analytics & Statistics Models
SQLAlchemy models for Phase 10
"""

from sqlalchemy import Column, String, Integer, ForeignKey, Text, JSON
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
from datetime import date
import uuid

from app.core.db import Base


class UserSession(Base):
    """User session model"""
    __tablename__ = "user_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=True)  # References auth.users
    session_start = Column(Text, server_default=func.now())
    session_end = Column(Text)
    duration_seconds = Column(Integer)
    page_views = Column(Integer, default=0)
    country = Column(String(100))
    city = Column(String(100))
    device_type = Column(String(50))  # desktop, mobile, tablet
    browser = Column(String(100))
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())


class PageView(Base):
    """Page view model"""
    __tablename__ = "page_views"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=True)  # References auth.users
    session_id = Column(UUID(as_uuid=True), ForeignKey("user_sessions.id"), nullable=True)
    page_path = Column(String(500), nullable=False)
    page_title = Column(String(255))
    referrer = Column(String(500))
    duration_seconds = Column(Integer)
    created_at = Column(Text, server_default=func.now())


class ContentInteraction(Base):
    """Content interaction model"""
    __tablename__ = "content_interactions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=True)  # References auth.users
    content_id = Column(UUID(as_uuid=True), nullable=False)
    content_type = Column(String(50), nullable=False)  # image, video, audio, article
    interaction_type = Column(String(50), nullable=False)  # view, like, share, download, comment
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())


class FeatureUsage(Base):
    """Feature usage model"""
    __tablename__ = "feature_usage"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=True)  # References auth.users
    feature_name = Column(String(100), nullable=False)  # image_editor, video_editor, etc.
    usage_count = Column(Integer, default=1)
    last_used_at = Column(Text, server_default=func.now())
    meta_data = Column("metadata", JSONB, default={})
    created_at = Column(Text, server_default=func.now())


class AnalyticsSnapshot(Base):
    """Analytics snapshot model (daily aggregates)"""
    __tablename__ = "analytics_snapshots"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    snapshot_date = Column(String, nullable=False, unique=True)  # DATE as string
    total_users = Column(Integer, default=0)
    active_users = Column(Integer, default=0)
    new_users = Column(Integer, default=0)
    page_views = Column(Integer, default=0)
    content_views = Column(Integer, default=0)
    feature_usage = Column(JSONB, default={})
    geographic_data = Column(JSONB, default={})
    time_patterns = Column(JSONB, default={})
    created_at = Column(Text, server_default=func.now())

