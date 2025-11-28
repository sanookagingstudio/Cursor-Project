"""
Dashboard & Publishing Module Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime, date


# Platform Account Schemas
class PlatformAccountCreate(BaseModel):
    platform: str = Field(..., description="Platform: youtube, tiktok, facebook, instagram, twitter")
    external_id: Optional[str] = None
    name: Optional[str] = None
    handle: Optional[str] = None
    metadata: Dict[str, Any] = Field(default={})
    auth_config: Dict[str, Any] = Field(default={})


class PlatformAccountResponse(BaseModel):
    id: UUID
    user_id: UUID
    platform: str
    external_id: Optional[str]
    name: Optional[str]
    handle: Optional[str]
    metadata: Dict[str, Any]
    created_at: datetime

    model_config = {"from_attributes": True}


# Content Channel Schemas
class ContentChannelCreate(BaseModel):
    name: str = Field(..., min_length=1)
    description: Optional[str] = None
    metadata: Dict[str, Any] = Field(default={})


class ContentChannelResponse(BaseModel):
    id: UUID
    owner_id: UUID
    name: str
    description: Optional[str]
    metadata: Dict[str, Any]
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


# Series Schemas
class SeriesCreate(BaseModel):
    content_channel_id: UUID
    name: str = Field(..., min_length=1)
    description: Optional[str] = None
    metadata: Dict[str, Any] = Field(default={})


class SeriesResponse(BaseModel):
    id: UUID
    content_channel_id: UUID
    name: str
    description: Optional[str]
    metadata: Dict[str, Any]
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


# Episode Schemas
class EpisodeCreate(BaseModel):
    series_id: UUID
    project_id: Optional[UUID] = None
    primary_asset_id: Optional[UUID] = None
    title: str = Field(..., min_length=1)
    description: Optional[str] = None
    metadata: Dict[str, Any] = Field(default={})


class EpisodeResponse(BaseModel):
    id: UUID
    series_id: UUID
    project_id: Optional[UUID]
    primary_asset_id: Optional[UUID]
    title: str
    description: Optional[str]
    status: str
    metadata: Dict[str, Any]
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


# Publishing Schemas
class PublishingPlanRequest(BaseModel):
    episode_id: UUID
    platform_account_id: UUID
    scheduled_time: Optional[datetime] = None
    metadata: Dict[str, Any] = Field(default={})


class PublishingPlanResponse(BaseModel):
    publication_id: UUID
    status: str
    scheduled_time: Optional[datetime]
    estimated_time: Optional[int] = None  # seconds


class PublicationRecordResponse(BaseModel):
    id: UUID
    episode_id: UUID
    platform_account_id: UUID
    platform: str
    external_post_id: Optional[str]
    status: str
    scheduled_time: Optional[datetime]
    published_time: Optional[datetime]
    fail_reason: Optional[str]
    metadata: Dict[str, Any]
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


# Performance Schemas
class PerformanceSnapshotResponse(BaseModel):
    id: UUID
    publication_id: UUID
    timestamp: datetime
    views: int
    likes: int
    comments: int
    shares: int
    watch_time_seconds: float
    ctr: float
    engagement_rate: float
    estimated_revenue: float
    metadata: Dict[str, Any]

    model_config = {"from_attributes": True}


# Revenue Schemas
class RevenueRecordResponse(BaseModel):
    id: UUID
    publication_id: UUID
    source: str
    amount: float
    currency: str
    period_start: Optional[date]
    period_end: Optional[date]
    metadata: Dict[str, Any]
    created_at: datetime

    model_config = {"from_attributes": True}


# Dashboard Overview Schemas
class DashboardOverviewResponse(BaseModel):
    total_channels: int
    total_episodes: int
    total_publications: int
    total_views: int
    total_revenue: float
    revenue_currency: str
    recent_episodes: List[EpisodeResponse]
    top_performers: List[Dict[str, Any]]


class EpisodePerformanceResponse(BaseModel):
    episode_id: UUID
    episode_title: str
    total_views: int
    total_likes: int
    total_comments: int
    total_shares: int
    total_watch_time: float
    average_ctr: float
    average_engagement_rate: float
    estimated_revenue: float
    publications: List[PublicationRecordResponse]
    snapshots: List[PerformanceSnapshotResponse]


class FinanceResponse(BaseModel):
    total_revenue: float
    total_cost: float
    profit: float
    roi: float
    revenue_by_source: Dict[str, float]
    revenue_by_period: List[Dict[str, Any]]
    currency: str

