"""
Analytics & Statistics API Router
FastAPI endpoints for Phase 10
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional
from datetime import date

from app.core.db import get_db
from app.services.analytics_service import AnalyticsService
from app.schemas.analytics import (
    UserSessionCreate,
    UserSessionResponse,
    PageViewCreate,
    PageViewResponse,
    ContentInteractionCreate,
    ContentInteractionResponse,
    FeatureUsageCreate,
    FeatureUsageResponse,
    UserAnalyticsSummary,
    ContentAnalyticsSummary,
    TimeAnalyticsSummary,
    GeographicAnalyticsSummary,
    FeatureUsageSummary,
    AnalyticsDashboardResponse
)

router = APIRouter()


# User Sessions
@router.post("/sessions", response_model=UserSessionResponse, status_code=status.HTTP_201_CREATED)
def create_user_session(
    session_data: UserSessionCreate,
    db: Session = Depends(get_db)
):
    """Create a new user session"""
    return AnalyticsService.create_user_session(db, session_data)


@router.put("/sessions/{session_id}/end", response_model=UserSessionResponse)
def end_user_session(
    session_id: str,
    duration_seconds: int,
    db: Session = Depends(get_db)
):
    """End a user session"""
    from uuid import UUID
    session = AnalyticsService.end_user_session(db, UUID(session_id), duration_seconds)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return session


# Page Views
@router.post("/page-views", response_model=PageViewResponse, status_code=status.HTTP_201_CREATED)
def create_page_view(
    view_data: PageViewCreate,
    db: Session = Depends(get_db)
):
    """Create a page view record"""
    return AnalyticsService.create_page_view(db, view_data)


# Content Interactions
@router.post("/interactions", response_model=ContentInteractionResponse, status_code=status.HTTP_201_CREATED)
def create_content_interaction(
    interaction_data: ContentInteractionCreate,
    db: Session = Depends(get_db)
):
    """Create a content interaction record"""
    return AnalyticsService.create_content_interaction(db, interaction_data)


# Feature Usage
@router.post("/feature-usage", response_model=FeatureUsageResponse, status_code=status.HTTP_201_CREATED)
def record_feature_usage(
    usage_data: FeatureUsageCreate,
    db: Session = Depends(get_db)
):
    """Record feature usage"""
    return AnalyticsService.record_feature_usage(db, usage_data)


# Analytics Summaries
@router.get("/users", response_model=UserAnalyticsSummary)
def get_user_analytics(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db)
):
    """Get user analytics summary"""
    return AnalyticsService.get_user_analytics(db, start_date, end_date)


@router.get("/content", response_model=ContentAnalyticsSummary)
def get_content_analytics(
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """Get content analytics summary"""
    return AnalyticsService.get_content_analytics(db, limit)


@router.get("/time", response_model=TimeAnalyticsSummary)
def get_time_analytics(
    db: Session = Depends(get_db)
):
    """Get time-based analytics"""
    return AnalyticsService.get_time_analytics(db)


@router.get("/geographic", response_model=GeographicAnalyticsSummary)
def get_geographic_analytics(
    db: Session = Depends(get_db)
):
    """Get geographic analytics"""
    return AnalyticsService.get_geographic_analytics(db)


@router.get("/features", response_model=FeatureUsageSummary)
def get_feature_usage_analytics(
    db: Session = Depends(get_db)
):
    """Get feature usage analytics"""
    return AnalyticsService.get_feature_usage_analytics(db)


# Dashboard
@router.get("/dashboard", response_model=AnalyticsDashboardResponse)
def get_analytics_dashboard(
    db: Session = Depends(get_db)
):
    """Get complete analytics dashboard"""
    return AnalyticsDashboardResponse(
        user_analytics=UserAnalyticsSummary(**AnalyticsService.get_user_analytics(db)),
        content_analytics=ContentAnalyticsSummary(**AnalyticsService.get_content_analytics(db)),
        time_analytics=TimeAnalyticsSummary(**AnalyticsService.get_time_analytics(db)),
        geographic_analytics=GeographicAnalyticsSummary(**AnalyticsService.get_geographic_analytics(db)),
        feature_usage=FeatureUsageSummary(**AnalyticsService.get_feature_usage_analytics(db))
    )

