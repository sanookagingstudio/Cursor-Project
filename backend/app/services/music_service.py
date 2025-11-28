"""
Music & Audio Service
Business logic for stem separation, music analysis, tab generation, and music generation
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from sqlalchemy.orm import Session
from app.models.project import Project
from app.models.asset import Asset
from app.models.job import Job
from app.models.music import AudioAnalysis, StemGroup, TabRecord
from app.schemas.music import (
    StemSeparationRequest,
    MusicAnalysisRequest,
    TabGenerationRequest,
    MusicGenerateRequest,
    AudioRemasterRequest,
    RemasterOperation
)
from app.providers.audio_provider_base import AudioProviderBase
from app.providers.audio_mock import MockAudioProvider
from app.core.events import publish_event
from app.core.celery_app import celery_app


class MusicService:
    """Service for music and audio operations"""
    
    def __init__(self):
        # Default to mock provider for now
        self.default_provider: AudioProviderBase = MockAudioProvider()
    
    def get_provider(self, provider_name: Optional[str] = None) -> AudioProviderBase:
        """Get audio provider by name"""
        if provider_name == "mock" or provider_name is None:
            return MockAudioProvider()
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
            name="Music & Audio Project",
            owner_id=str(user_id) if user_id else "system",
            meta_data={"source": "music_module"}
        )
        db.add(project)
        db.flush()
        return project
    
    def separate_stems(
        self,
        db: Session,
        request: StemSeparationRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Separate audio into stems"""
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == request.asset_id).first()
        if not source_asset:
            raise ValueError("Source audio asset not found")
        
        # Create job
        job = Job(
            project_id=source_asset.project_id,
            type="audio.stems",
            status="pending",
            input_payload={
                "asset_id": str(request.asset_id),
                "stems": request.stems or ["vocal", "drums", "bass", "other"],
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
            "type": "audio.stems",
            "asset_id": str(request.asset_id)
        })
        
        return job
    
    def analyze_music(
        self,
        db: Session,
        request: MusicAnalysisRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Analyze music properties"""
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == request.asset_id).first()
        if not source_asset:
            raise ValueError("Source audio asset not found")
        
        # Create job
        job = Job(
            project_id=source_asset.project_id,
            type="music.analyze",
            status="pending",
            input_payload={
                "asset_id": str(request.asset_id),
                "tasks": request.tasks or ["bpm", "key", "chords", "sections"],
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
            "type": "music.analyze",
            "asset_id": str(request.asset_id)
        })
        
        return job
    
    def generate_tab(
        self,
        db: Session,
        request: TabGenerationRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Generate tab for instrument"""
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == request.asset_id).first()
        if not source_asset:
            raise ValueError("Source audio asset not found")
        
        # Create job
        job = Job(
            project_id=source_asset.project_id,
            type="music.tab",
            status="pending",
            input_payload={
                "asset_id": str(request.asset_id),
                "instrument": request.instrument,
                "difficulty": request.difficulty,
                "format": request.format,
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
            "type": "music.tab",
            "asset_id": str(request.asset_id)
        })
        
        return job
    
    def generate_music(
        self,
        db: Session,
        request: MusicGenerateRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Generate music from prompt"""
        project = self.create_project_if_needed(db, request.project_id, user_id)
        
        # Create job
        job = Job(
            project_id=project.id,
            type="music.generate",
            status="pending",
            input_payload={
                "prompt": request.prompt,
                "duration_seconds": request.duration_seconds,
                "tempo": request.tempo,
                "key": request.key,
                "mood": request.mood,
                "instruments": request.instruments or [],
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
            "type": "music.generate",
            "project_id": str(project.id)
        })
        
        return job
    
    def remaster_audio(
        self,
        db: Session,
        request: AudioRemasterRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Remaster audio"""
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == request.asset_id).first()
        if not source_asset:
            raise ValueError("Source audio asset not found")
        
        # Create job
        job = Job(
            project_id=source_asset.project_id,
            type="audio.remaster",
            status="pending",
            input_payload={
                "asset_id": str(request.asset_id),
                "operations": [op.model_dump() for op in request.operations],
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
            "type": "audio.remaster",
            "asset_id": str(request.asset_id)
        })
        
        return job
    
    def get_analysis(self, db: Session, asset_id: UUID) -> Optional[AudioAnalysis]:
        """Get audio analysis by asset ID"""
        return db.query(AudioAnalysis).filter(AudioAnalysis.asset_id == asset_id).order_by(AudioAnalysis.created_at.desc()).first()
    
    def get_stem_group(self, db: Session, source_asset_id: UUID) -> Optional[StemGroup]:
        """Get stem group by source asset ID"""
        return db.query(StemGroup).filter(StemGroup.source_asset_id == source_asset_id).order_by(StemGroup.created_at.desc()).first()
    
    def get_tab(self, db: Session, asset_id: UUID, instrument: Optional[str] = None) -> Optional[TabRecord]:
        """Get tab record by asset ID"""
        query = db.query(TabRecord).filter(TabRecord.audio_asset_id == asset_id)
        if instrument:
            query = query.filter(TabRecord.instrument == instrument)
        return query.order_by(TabRecord.created_at.desc()).first()

