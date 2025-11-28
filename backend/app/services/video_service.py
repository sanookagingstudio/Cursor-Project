"""
Video Service
Business logic for video generation, editing, and subtitle generation
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from sqlalchemy.orm import Session
from app.models.project import Project
from app.models.asset import Asset
from app.models.job import Job
from app.schemas.video import (
    VideoGenerateRequest,
    VideoEditRequest,
    VideoMultiExportRequest,
    VideoSubtitleRequest,
    VideoEditOperation
)
from app.providers.video_provider_base import VideoProviderBase
from app.providers.video_mock import MockVideoProvider
from app.core.events import publish_event


class VideoService:
    """Service for video operations"""
    
    def __init__(self):
        # Default to mock provider for now
        self.default_provider: VideoProviderBase = MockVideoProvider()
    
    def get_provider(self, provider_name: Optional[str] = None) -> VideoProviderBase:
        """Get video provider by name"""
        if provider_name == "mock" or provider_name is None:
            return MockVideoProvider()
        # In production, load from registry
        return self.default_provider
    
    def create_project_if_needed(
        self,
        db: Session,
        project_id: Optional[UUID],
        user_id: Optional[UUID] = None
    ) -> Project:
        """Create project if not provided"""
        if project_id:
            project = db.query(Project).filter(Project.id == project_id).first()
            if project:
                return project
        
        project = Project(
            name="Video Generation Project",
            owner_id=str(user_id) if user_id else "system",
            meta_data={"source": "video_module"}
        )
        db.add(project)
        db.flush()
        return project
    
    def generate_video(
        self,
        db: Session,
        request: VideoGenerateRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Generate video from prompt"""
        project = self.create_project_if_needed(db, request.project_id, user_id)
        
        # Create job
        job = Job(
            project_id=project.id,
            type="video.generate",
            status="pending",
            input_payload={
                "prompt": request.prompt,
                "duration_seconds": request.duration_seconds,
                "aspect_ratio": request.aspect_ratio,
                "resolution": request.resolution,
                "style": request.style,
                "provider": request.provider or "mock",
                "source_assets": [str(aid) for aid in (request.source_assets or [])]
            },
            output_payload={}
        )
        db.add(job)
        db.commit()
        db.refresh(job)
        
        # Publish event
        publish_event("JOB_CREATED", {
            "job_id": str(job.id),
            "type": "video.generate",
            "project_id": str(project.id)
        })
        
        return job
    
    def edit_video(
        self,
        db: Session,
        request: VideoEditRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Edit existing video"""
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == request.asset_id).first()
        if not source_asset:
            raise ValueError("Source video asset not found")
        
        # Create job
        job = Job(
            project_id=source_asset.project_id,
            type="video.edit",
            status="pending",
            input_payload={
                "asset_id": str(request.asset_id),
                "operations": [op.model_dump() for op in request.operations],
                "output_config": request.output_config or {},
                "provider": request.provider or "mock"
            },
            output_payload={}
        )
        db.add(job)
        db.commit()
        db.refresh(job)
        
        # Publish event
        publish_event("JOB_CREATED", {
            "job_id": str(job.id),
            "type": "video.edit",
            "asset_id": str(request.asset_id)
        })
        
        return job
    
    def multi_export(
        self,
        db: Session,
        request: VideoMultiExportRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Export video in multiple aspect ratios"""
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == request.asset_id).first()
        if not source_asset:
            raise ValueError("Source video asset not found")
        
        # Create job
        job = Job(
            project_id=source_asset.project_id,
            type="video.multi_export",
            status="pending",
            input_payload={
                "asset_id": str(request.asset_id),
                "aspect_ratios": request.aspect_ratios,
                "provider": request.provider or "mock"
            },
            output_payload={}
        )
        db.add(job)
        db.commit()
        db.refresh(job)
        
        # Publish event
        publish_event("JOB_CREATED", {
            "job_id": str(job.id),
            "type": "video.multi_export",
            "asset_id": str(request.asset_id),
            "aspect_ratios": request.aspect_ratios
        })
        
        return job
    
    def generate_subtitle(
        self,
        db: Session,
        request: VideoSubtitleRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Generate subtitles for video"""
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == request.asset_id).first()
        if not source_asset:
            raise ValueError("Source video asset not found")
        
        # Create job
        job = Job(
            project_id=source_asset.project_id,
            type="video.subtitle",
            status="pending",
            input_payload={
                "asset_id": str(request.asset_id),
                "source_language": request.source_language,
                "target_languages": request.target_languages or [],
                "style": request.style,
                "provider": request.provider or "mock"
            },
            output_payload={}
        )
        db.add(job)
        db.commit()
        db.refresh(job)
        
        # Publish event
        publish_event("JOB_CREATED", {
            "job_id": str(job.id),
            "type": "video.subtitle",
            "asset_id": str(request.asset_id)
        })
        
        return job

