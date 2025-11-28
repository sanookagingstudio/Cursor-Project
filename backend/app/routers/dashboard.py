"""
Dashboard Router
API endpoints for content channels, series, episodes, and analytics
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.core.db import get_db
from app.schemas.publishing import (
    ContentChannelCreate,
    ContentChannelResponse,
    SeriesCreate,
    SeriesResponse,
    EpisodeCreate,
    EpisodeResponse,
    DashboardOverviewResponse,
    EpisodePerformanceResponse,
    FinanceResponse
)
from app.services.dashboard_service import DashboardService
# from app.contexts.auth_context import get_current_user  # TODO: Implement auth context

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

dashboard_service = DashboardService()


# Channel Endpoints
@router.post("/channels", response_model=ContentChannelResponse, status_code=status.HTTP_201_CREATED)
def create_channel(
    channel_data: ContentChannelCreate,
    db: Session = Depends(get_db),
    # user_id: UUID = Depends(get_current_user)  # TODO: Add auth
):
    """Create content channel"""
    try:
        # TODO: Get user_id from auth
        user_id = UUID("00000000-0000-0000-0000-000000000000")  # Mock user_id
        channel = dashboard_service.create_channel(db, channel_data, user_id)
        return channel
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create channel: {str(e)}"
        )


@router.get("/channels", response_model=List[ContentChannelResponse])
def get_channels(
    db: Session = Depends(get_db),
    # user_id: UUID = Depends(get_current_user)  # TODO: Add auth
):
    """Get all channels for user"""
    # TODO: Get user_id from auth
    user_id = UUID("00000000-0000-0000-0000-000000000000")  # Mock user_id
    channels = dashboard_service.get_channels(db, user_id)
    return channels


@router.get("/channels/{channel_id}", response_model=ContentChannelResponse)
def get_channel(channel_id: UUID, db: Session = Depends(get_db)):
    """Get channel by ID"""
    channel = dashboard_service.get_channel(db, channel_id)
    if not channel:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Channel not found"
        )
    return channel


# Series Endpoints
@router.post("/channels/{channel_id}/series", response_model=SeriesResponse, status_code=status.HTTP_201_CREATED)
def create_series(
    channel_id: UUID,
    series_data: SeriesCreate,
    db: Session = Depends(get_db)
):
    """Create series"""
    try:
        series = dashboard_service.create_series(db, channel_id, series_data)
        return series
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create series: {str(e)}"
        )


@router.get("/channels/{channel_id}/series", response_model=List[SeriesResponse])
def get_series(channel_id: UUID, db: Session = Depends(get_db)):
    """Get all series for channel"""
    series = dashboard_service.get_series(db, channel_id)
    return series


# Episode Endpoints
@router.post("/episodes", response_model=EpisodeResponse, status_code=status.HTTP_201_CREATED)
def create_episode(
    episode_data: EpisodeCreate,
    db: Session = Depends(get_db)
):
    """Create episode"""
    try:
        episode = dashboard_service.create_episode(db, episode_data)
        return episode
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create episode: {str(e)}"
        )


@router.get("/episodes/{episode_id}", response_model=EpisodeResponse)
def get_episode(episode_id: UUID, db: Session = Depends(get_db)):
    """Get episode by ID"""
    episode = dashboard_service.get_episode(db, episode_id)
    if not episode:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Episode not found"
        )
    return episode


@router.get("/series/{series_id}/episodes", response_model=List[EpisodeResponse])
def get_episodes(series_id: UUID, db: Session = Depends(get_db)):
    """Get all episodes for series"""
    episodes = dashboard_service.get_episodes(db, series_id)
    return episodes


# Analytics Endpoints
@router.get("/overview", response_model=DashboardOverviewResponse)
def get_overview(
    channel_id: Optional[UUID] = Query(None),
    db: Session = Depends(get_db),
    # user_id: UUID = Depends(get_current_user)  # TODO: Add auth
):
    """Get dashboard overview"""
    # TODO: Get user_id from auth
    user_id = UUID("00000000-0000-0000-0000-000000000000")  # Mock user_id
    overview = dashboard_service.get_overview(db, user_id, channel_id)
    return overview


@router.get("/episodes/{episode_id}/performance", response_model=EpisodePerformanceResponse)
def get_episode_performance(episode_id: UUID, db: Session = Depends(get_db)):
    """Get episode performance"""
    performance = dashboard_service.get_episode_performance(db, episode_id)
    if not performance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Episode not found"
        )
    return performance


@router.get("/channels/{channel_id}/finance", response_model=FinanceResponse)
def get_channel_finance(channel_id: UUID, db: Session = Depends(get_db)):
    """Get channel finance"""
    finance = dashboard_service.get_finance(db, "channel", channel_id)
    if not finance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Channel not found"
        )
    return finance


@router.get("/series/{series_id}/finance", response_model=FinanceResponse)
def get_series_finance(series_id: UUID, db: Session = Depends(get_db)):
    """Get series finance"""
    finance = dashboard_service.get_finance(db, "series", series_id)
    if not finance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Series not found"
        )
    return finance


@router.get("/episodes/{episode_id}/finance", response_model=FinanceResponse)
def get_episode_finance(episode_id: UUID, db: Session = Depends(get_db)):
    """Get episode finance"""
    finance = dashboard_service.get_finance(db, "episode", episode_id)
    if not finance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Episode not found"
        )
    return finance

