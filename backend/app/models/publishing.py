"""
Dashboard & Publishing Module Models
Platform Accounts, Content Channels, Series, Episodes, Publications, Performance, Revenue
"""

from sqlalchemy import Column, String, Integer, Float, Date, ForeignKey, Text, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from sqlalchemy.types import TIMESTAMP
from app.core.db import Base
import uuid


class PlatformAccount(Base):
    """Platform Account Model"""
    __tablename__ = "platform_accounts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("auth.users(id)", ondelete="CASCADE"), nullable=False)
    platform = Column(String(50), nullable=False)  # "youtube" | "tiktok" | "facebook"
    external_id = Column(String(255), nullable=True)
    name = Column(String(255), nullable=True)
    handle = Column(String(255), nullable=True)
    metadata = Column(JSONB, default={})
    auth_config = Column(JSONB, default={})  # encrypted tokens
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    publications = relationship("PublicationRecord", backref="platform_account")
    channel_links = relationship("ContentChannelPlatformLink", backref="platform_account")

    def __repr__(self):
        return f"<PlatformAccount(id={self.id}, platform={self.platform}, handle={self.handle})>"


class ContentChannel(Base):
    """Content Channel Model"""
    __tablename__ = "content_channels"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("auth.users(id)", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    metadata = Column(JSONB, default={})
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    series = relationship("Series", backref="content_channel", cascade="all, delete-orphan")
    platform_links = relationship("ContentChannelPlatformLink", backref="content_channel", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<ContentChannel(id={self.id}, name={self.name})>"


class ContentChannelPlatformLink(Base):
    """Content Channel Platform Link Model"""
    __tablename__ = "content_channel_platform_links"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_channel_id = Column(UUID(as_uuid=True), ForeignKey("content_channels(id)", ondelete="CASCADE"), nullable=False)
    platform_account_id = Column(UUID(as_uuid=True), ForeignKey("platform_accounts(id)", ondelete="CASCADE"), nullable=False)
    role = Column(String(50), nullable=False)  # "primary" | "secondary"
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    def __repr__(self):
        return f"<ContentChannelPlatformLink(channel_id={self.content_channel_id}, account_id={self.platform_account_id})>"


class Series(Base):
    """Series Model"""
    __tablename__ = "series"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_channel_id = Column(UUID(as_uuid=True), ForeignKey("content_channels(id)", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    metadata = Column(JSONB, default={})
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    episodes = relationship("Episode", backref="series", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Series(id={self.id}, name={self.name})>"


class Episode(Base):
    """Episode Model"""
    __tablename__ = "episodes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    series_id = Column(UUID(as_uuid=True), ForeignKey("series(id)", ondelete="CASCADE"), nullable=False)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects(id)", ondelete="SET NULL"), nullable=True)
    primary_asset_id = Column(UUID(as_uuid=True), ForeignKey("assets(id)", ondelete="SET NULL"), nullable=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String(50), nullable=False, default="draft")  # "draft" | "ready" | "publishing" | "published"
    metadata = Column(JSONB, default={})
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    publications = relationship("PublicationRecord", backref="episode", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Episode(id={self.id}, title={self.title}, status={self.status})>"


class PublicationRecord(Base):
    """Publication Record Model"""
    __tablename__ = "publication_records"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    episode_id = Column(UUID(as_uuid=True), ForeignKey("episodes(id)", ondelete="CASCADE"), nullable=False)
    platform_account_id = Column(UUID(as_uuid=True), ForeignKey("platform_accounts(id)", ondelete="CASCADE"), nullable=False)
    platform = Column(String(50), nullable=False)
    external_post_id = Column(String(255), nullable=True)
    status = Column(String(50), nullable=False, default="scheduled")  # "scheduled" | "published" | "failed"
    scheduled_time = Column(TIMESTAMP(timezone=True), nullable=True)
    published_time = Column(TIMESTAMP(timezone=True), nullable=True)
    fail_reason = Column(Text, nullable=True)
    metadata = Column(JSONB, default={})
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    performance_snapshots = relationship("PerformanceSnapshot", backref="publication", cascade="all, delete-orphan")
    revenue_records = relationship("RevenueRecord", backref="publication", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<PublicationRecord(id={self.id}, platform={self.platform}, status={self.status})>"


class PerformanceSnapshot(Base):
    """Performance Snapshot Model"""
    __tablename__ = "performance_snapshots"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    publication_id = Column(UUID(as_uuid=True), ForeignKey("publication_records(id)", ondelete="CASCADE"), nullable=False)
    timestamp = Column(TIMESTAMP(timezone=True), server_default=func.now())
    views = Column(Integer, default=0)
    likes = Column(Integer, default=0)
    comments = Column(Integer, default=0)
    shares = Column(Integer, default=0)
    watch_time_seconds = Column(Float, default=0)
    ctr = Column(Float, default=0)  # Click-through rate
    engagement_rate = Column(Float, default=0)
    estimated_revenue = Column(Float, default=0)
    metadata = Column(JSONB, default={})

    def __repr__(self):
        return f"<PerformanceSnapshot(id={self.id}, views={self.views}, timestamp={self.timestamp})>"


class RevenueRecord(Base):
    """Revenue Record Model"""
    __tablename__ = "revenue_records"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    publication_id = Column(UUID(as_uuid=True), ForeignKey("publication_records(id)", ondelete="CASCADE"), nullable=False)
    source = Column(String(50), nullable=False)  # "adsense" | "creator_fund" | "product_sale" | "sponsorship"
    amount = Column(Float, nullable=False)
    currency = Column(String(10), nullable=False, default="THB")
    period_start = Column(Date, nullable=True)
    period_end = Column(Date, nullable=True)
    metadata = Column(JSONB, default={})
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    def __repr__(self):
        return f"<RevenueRecord(id={self.id}, amount={self.amount} {self.currency}, source={self.source})>"

