"""
Music & Audio Router
API endpoints for stem separation, music analysis, tab generation, and music generation
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.core.db import get_db
from app.schemas.music import (
    StemSeparationRequest,
    StemSeparationResponse,
    MusicAnalysisRequest,
    MusicAnalysisResponse,
    TabGenerationRequest,
    TabGenerationResponse,
    MusicGenerateRequest,
    MusicGenerateResponse,
    AudioRemasterRequest,
    AudioRemasterResponse,
    AudioAnalysisResponse,
    StemGroupResponse,
    TabRecordResponse
)
from app.services.music_service import MusicService
from app.models.asset import Asset

router = APIRouter(prefix="/music", tags=["music"])
audio_router = APIRouter(prefix="/audio", tags=["audio"])

music_service = MusicService()


# Audio Endpoints
@audio_router.post("/stems", response_model=StemSeparationResponse, status_code=status.HTTP_201_CREATED)
def separate_stems(
    request: StemSeparationRequest,
    db: Session = Depends(get_db)
):
    """Separate audio into stems"""
    try:
        job = music_service.separate_stems(db, request)
        return StemSeparationResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=180  # Mock estimate
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to separate stems: {str(e)}"
        )


@audio_router.post("/remaster", response_model=AudioRemasterResponse, status_code=status.HTTP_201_CREATED)
def remaster_audio(
    request: AudioRemasterRequest,
    db: Session = Depends(get_db)
):
    """Remaster audio"""
    try:
        job = music_service.remaster_audio(db, request)
        return AudioRemasterResponse(
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
            detail=f"Failed to remaster audio: {str(e)}"
        )


# Music Endpoints
@router.post("/analyze", response_model=MusicAnalysisResponse, status_code=status.HTTP_201_CREATED)
def analyze_music(
    request: MusicAnalysisRequest,
    db: Session = Depends(get_db)
):
    """Analyze music properties"""
    try:
        job = music_service.analyze_music(db, request)
        return MusicAnalysisResponse(
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
            detail=f"Failed to analyze music: {str(e)}"
        )


@router.post("/tab", response_model=TabGenerationResponse, status_code=status.HTTP_201_CREATED)
def generate_tab(
    request: TabGenerationRequest,
    db: Session = Depends(get_db)
):
    """Generate tab for instrument"""
    try:
        job = music_service.generate_tab(db, request)
        return TabGenerationResponse(
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
            detail=f"Failed to generate tab: {str(e)}"
        )


@router.post("/generate", response_model=MusicGenerateResponse, status_code=status.HTTP_201_CREATED)
def generate_music(
    request: MusicGenerateRequest,
    db: Session = Depends(get_db)
):
    """Generate music from prompt"""
    try:
        job = music_service.generate_music(db, request)
        return MusicGenerateResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=request.duration_seconds * 2  # Mock estimate
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate music: {str(e)}"
        )


@router.get("/analysis/{asset_id}", response_model=AudioAnalysisResponse)
def get_analysis(asset_id: UUID, db: Session = Depends(get_db)):
    """Get audio analysis by asset ID"""
    analysis = music_service.get_analysis(db, asset_id)
    if not analysis:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Audio analysis not found"
        )
    return analysis


@router.get("/tab/{asset_id}", response_model=TabRecordResponse)
def get_tab(
    asset_id: UUID,
    instrument: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get tab record by asset ID"""
    tab = music_service.get_tab(db, asset_id, instrument)
    if not tab:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Tab record not found"
        )
    return tab


@audio_router.get("/stems/{asset_id}", response_model=StemGroupResponse)
def get_stem_group(asset_id: UUID, db: Session = Depends(get_db)):
    """Get stem group by source asset ID"""
    stem_group = music_service.get_stem_group(db, asset_id)
    if not stem_group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Stem group not found"
        )
    return stem_group

