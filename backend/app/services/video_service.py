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
    VideoEditOperation,
    ShortsGeneratorRequest,
    MemeVideoRequest,
    VideoToGifRequest
)
from app.providers.video_provider_base import VideoProviderBase
from app.providers.video_mock import MockVideoProvider
from app.core.events import publish_event
from app.core.celery_app import celery_app


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
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("video.generate", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch video.generate task: {e}")
        
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
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("video.edit", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch video.edit task: {e}")
        
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
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("video.multi_export", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch video.multi_export task: {e}")
        
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
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("video.subtitle", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch video.subtitle task: {e}")
        
        return job
    
    def generate_shorts(
        self,
        db: Session,
        request: ShortsGeneratorRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Generate shorts video (TikTok, YouTube Shorts, Reels)"""
        project = self.create_project_if_needed(db, request.project_id, user_id)
        
        # Create job
        job = Job(
            project_id=project.id,
            type="video.shorts",
            status="pending",
            input_payload={
                "source_video_id": str(request.source_video_id) if request.source_video_id else None,
                "platform": request.platform,
                "auto_features": request.auto_features,
                "prompt": request.prompt,
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
            "type": "video.shorts",
            "platform": request.platform
        })
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("video.shorts", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch video.shorts task: {e}")
        
        return job
    
    def generate_meme_video(
        self,
        db: Session,
        request: MemeVideoRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Generate meme video"""
        project = self.create_project_if_needed(db, request.project_id, user_id)
        
        # Create job
        job = Job(
            project_id=project.id,
            type="video.meme",
            status="pending",
            input_payload={
                "template_id": request.template_id,
                "source_video_id": str(request.source_video_id) if request.source_video_id else None,
                "top_text": request.top_text,
                "bottom_text": request.bottom_text,
                "effects": request.effects,
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
            "type": "video.meme"
        })
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("video.meme", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch video.meme task: {e}")
        
        return job
    
    def convert_video_to_gif(
        self,
        db: Session,
        request: VideoToGifRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Convert video to GIF"""
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == request.source_video_id).first()
        if not source_asset:
            raise ValueError("Source video asset not found")
        
        # Create job
        job = Job(
            project_id=request.project_id or source_asset.project_id,
            type="video.to_gif",
            status="pending",
            input_payload={
                "source_video_id": str(request.source_video_id),
                "start_time": request.start_time,
                "duration": request.duration,
                "frame_rate": request.frame_rate,
                "optimize_size": request.optimize_size,
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
            "type": "video.to_gif",
            "asset_id": str(request.source_video_id)
        })
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("video.to_gif", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch video.to_gif task: {e}")
        
        return job

