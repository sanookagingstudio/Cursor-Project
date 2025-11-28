"""
Video Router
API endpoints for video generation, editing, and subtitle generation
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.core.db import get_db
from app.schemas.video import (
    VideoGenerateRequest,
    VideoGenerateResponse,
    VideoEditRequest,
    VideoMultiExportRequest,
    VideoMultiExportResponse,
    VideoSubtitleRequest,
    VideoSubtitleResponse,
    VideoDetailsResponse,
    ShortsGeneratorRequest,
    MemeVideoRequest,
    VideoToGifRequest
)
from app.services.video_service import VideoService
from app.models.asset import Asset

router = APIRouter(prefix="/video", tags=["video"])

video_service = VideoService()


@router.post("/generate", response_model=VideoGenerateResponse, status_code=status.HTTP_201_CREATED)
def generate_video(
    request: VideoGenerateRequest,
    db: Session = Depends(get_db)
):
    """Generate video from prompt"""
    try:
        job = video_service.generate_video(db, request)
        return VideoGenerateResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=request.duration_seconds * 2  # Mock estimate
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate video: {str(e)}"
        )


@router.post("/edit", response_model=VideoGenerateResponse, status_code=status.HTTP_201_CREATED)
def edit_video(
    request: VideoEditRequest,
    db: Session = Depends(get_db)
):
    """Edit existing video"""
    try:
        job = video_service.edit_video(db, request)
        return VideoGenerateResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=120  # Mock estimate
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to edit video: {str(e)}"
        )


@router.post("/multi-export", response_model=VideoMultiExportResponse, status_code=status.HTTP_201_CREATED)
def multi_export(
    request: VideoMultiExportRequest,
    db: Session = Depends(get_db)
):
    """Export video in multiple aspect ratios"""
    try:
        job = video_service.multi_export(db, request)
        return VideoMultiExportResponse(
            job_id=job.id,
            status=job.status,
            results=[],
            total_count=len(request.aspect_ratios),
            estimated_time=len(request.aspect_ratios) * 60  # Mock estimate
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to multi-export video: {str(e)}"
        )


@router.post("/subtitle", response_model=VideoSubtitleResponse, status_code=status.HTTP_201_CREATED)
def generate_subtitle(
    request: VideoSubtitleRequest,
    db: Session = Depends(get_db)
):
    """Generate subtitles for video"""
    try:
        job = video_service.generate_subtitle(db, request)
        return VideoSubtitleResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=90  # Mock estimate
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate subtitle: {str(e)}"
        )


@router.get("/{asset_id}/details", response_model=VideoDetailsResponse)
def get_video_details(asset_id: UUID, db: Session = Depends(get_db)):
    """Get video asset details"""
    asset = db.query(Asset).filter(Asset.id == asset_id).first()
    if not asset:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Video asset not found"
        )
    
    # Parse metadata
    metadata = asset.meta_data or {}
    
    return VideoDetailsResponse(
        asset_id=asset.id,
        project_id=asset.project_id,
        url=asset.path or "",
        duration=metadata.get("duration", 15.0),
        width=metadata.get("width", 1920),
        height=metadata.get("height", 1080),
        fps=metadata.get("fps", 30),
        format=metadata.get("format", "mp4"),
        has_audio=metadata.get("has_audio", True),
        aspect_ratio=metadata.get("aspect_ratio", "16:9"),
        file_size=metadata.get("file_size", 0),
        metadata=metadata,
        created_at=asset.created_at
    )


@router.post("/shorts", response_model=VideoGenerateResponse, status_code=status.HTTP_201_CREATED)
def generate_shorts(
    request: ShortsGeneratorRequest,
    db: Session = Depends(get_db)
):
    """Generate shorts video (TikTok, YouTube Shorts, Reels)"""
    try:
        job = video_service.generate_shorts(db, request)
        return VideoGenerateResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=120  # Mock estimate
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate shorts: {str(e)}"
        )


@router.post("/meme", response_model=VideoGenerateResponse, status_code=status.HTTP_201_CREATED)
def generate_meme_video(
    request: MemeVideoRequest,
    db: Session = Depends(get_db)
):
    """Generate meme video"""
    try:
        job = video_service.generate_meme_video(db, request)
        return VideoGenerateResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=90  # Mock estimate
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate meme video: {str(e)}"
        )


@router.post("/to-gif", response_model=VideoGenerateResponse, status_code=status.HTTP_201_CREATED)
def convert_video_to_gif(
    request: VideoToGifRequest,
    db: Session = Depends(get_db)
):
    """Convert video to GIF"""
    try:
        job = video_service.convert_video_to_gif(db, request)
        return VideoGenerateResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=60  # Mock estimate
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to convert video to GIF: {str(e)}"
        )

