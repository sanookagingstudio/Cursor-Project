"""
Analytics & Statistics Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from uuid import UUID
from datetime import date


# User Session Schemas
class UserSessionCreate(BaseModel):
    user_id: Optional[UUID] = None
    country: Optional[str] = None
    city: Optional[str] = None
    device_type: Optional[str] = None
    browser: Optional[str] = None
    meta_data: Dict[str, Any] = Field(default_factory=dict)

    model_config = {"from_attributes": True}


class UserSessionResponse(BaseModel):
    id: UUID
    user_id: Optional[UUID]
    session_start: str
    session_end: Optional[str]
    duration_seconds: Optional[int]
    page_views: int
    country: Optional[str]
    city: Optional[str]
    device_type: Optional[str]
    browser: Optional[str]
    created_at: str

    model_config = {"from_attributes": True}


# Page View Schemas
class PageViewCreate(BaseModel):
    user_id: Optional[UUID] = None
    session_id: Optional[UUID] = None
    page_path: str
    page_title: Optional[str] = None
    referrer: Optional[str] = None
    duration_seconds: Optional[int] = None

    model_config = {"from_attributes": True}


class PageViewResponse(BaseModel):
    id: UUID
    user_id: Optional[UUID]
    session_id: Optional[UUID]
    page_path: str
    page_title: Optional[str]
    referrer: Optional[str]
    duration_seconds: Optional[int]
    created_at: str

    model_config = {"from_attributes": True}


# Content Interaction Schemas
class ContentInteractionCreate(BaseModel):
    user_id: Optional[UUID] = None
    content_id: UUID
    content_type: str
    interaction_type: str  # view, like, share, download, comment
    meta_data: Dict[str, Any] = Field(default_factory=dict)

    model_config = {"from_attributes": True}


class ContentInteractionResponse(BaseModel):
    id: UUID
    user_id: Optional[UUID]
    content_id: UUID
    content_type: str
    interaction_type: str
    created_at: str

    model_config = {"from_attributes": True}


# Feature Usage Schemas
class FeatureUsageCreate(BaseModel):
    user_id: Optional[UUID] = None
    feature_name: str
    meta_data: Dict[str, Any] = Field(default_factory=dict)

    model_config = {"from_attributes": True}


class FeatureUsageResponse(BaseModel):
    id: UUID
    user_id: Optional[UUID]
    feature_name: str
    usage_count: int
    last_used_at: str
    created_at: str

    model_config = {"from_attributes": True}


# Analytics Summary Schemas
class UserAnalyticsSummary(BaseModel):
    total_users: int
    active_users: Dict[str, int]  # DAU, WAU, MAU
    new_users: int
    returning_users: int
    retention_rate: float
    growth_rate: float

    model_config = {"from_attributes": True}


class ContentAnalyticsSummary(BaseModel):
    most_viewed: List[Dict[str, Any]]
    most_liked: List[Dict[str, Any]]
    most_shared: List[Dict[str, Any]]
    most_downloaded: List[Dict[str, Any]]
    trending: List[Dict[str, Any]]

    model_config = {"from_attributes": True}


class TimeAnalyticsSummary(BaseModel):
    peak_hours: List[Dict[str, Any]]
    peak_days: List[Dict[str, Any]]
    peak_months: List[Dict[str, Any]]
    average_session_duration: float

    model_config = {"from_attributes": True}


class GeographicAnalyticsSummary(BaseModel):
    users_by_country: Dict[str, int]
    users_by_region: Dict[str, int]
    top_countries: List[Dict[str, Any]]

    model_config = {"from_attributes": True}


class FeatureUsageSummary(BaseModel):
    feature_adoption: Dict[str, float]
    feature_usage_stats: Dict[str, int]
    most_used_features: List[Dict[str, Any]]

    model_config = {"from_attributes": True}


class AnalyticsDashboardResponse(BaseModel):
    user_analytics: UserAnalyticsSummary
    content_analytics: ContentAnalyticsSummary
    time_analytics: TimeAnalyticsSummary
    geographic_analytics: GeographicAnalyticsSummary
    feature_usage: FeatureUsageSummary

    model_config = {"from_attributes": True}

