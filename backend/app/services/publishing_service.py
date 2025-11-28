"""
Publishing Service
Business logic for publishing content to platforms
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from datetime import datetime
from sqlalchemy.orm import Session
from app.models.publishing import (
    PlatformAccount, Episode, PublicationRecord, PerformanceSnapshot, RevenueRecord
)
from app.models.asset import Asset
from app.models.job import Job
from app.schemas.publishing import PublishingPlanRequest
from app.providers.publisher_provider_base import PlatformPublisherBase
from app.providers.publisher_mock import MockPlatformPublisher
from app.core.events import publish_event


class PublishingService:
    """Service for publishing operations"""
    
    def __init__(self):
        # Default to mock provider for now
        self.default_provider: PlatformPublisherBase = MockPlatformPublisher()
    
    def get_provider(self, platform: str, auth_config: Optional[Dict[str, Any]] = None) -> PlatformPublisherBase:
        """Get publisher provider by platform"""
        if platform == "mock" or platform is None:
            config = auth_config or {}
            config["platform"] = platform or "youtube"
            return MockPlatformPublisher(auth_config=config)
        # In production, load from registry
        return self.default_provider
    
    def create_publishing_plan(
        self,
        db: Session,
        plan_data: PublishingPlanRequest,
        user_id: UUID
    ) -> PublicationRecord:
        """Create publishing plan"""
        # Get episode
        episode = db.query(Episode).filter(Episode.id == plan_data.episode_id).first()
        if not episode:
            raise ValueError("Episode not found")
        
        # Get platform account
        platform_account = db.query(PlatformAccount).filter(
            PlatformAccount.id == plan_data.platform_account_id
        ).first()
        if not platform_account:
            raise ValueError("Platform account not found")
        
        # Create publication record
        publication = PublicationRecord(
            episode_id=plan_data.episode_id,
            platform_account_id=plan_data.platform_account_id,
            platform=platform_account.platform,
            status="scheduled" if plan_data.scheduled_time else "ready",
            scheduled_time=plan_data.scheduled_time,
            metadata=plan_data.metadata or {}
        )
        db.add(publication)
        db.commit()
        db.refresh(publication)
        
        # Create job for publishing
        job = Job(
            project_id=episode.project_id,
            type="publishing.upload",
            status="pending",
            input_payload={
                "publication_id": str(publication.id),
                "episode_id": str(plan_data.episode_id),
                "platform": platform_account.platform,
                "scheduled_time": plan_data.scheduled_time.isoformat() if plan_data.scheduled_time else None
            },
            output_payload={}
        )
        db.add(job)
        db.commit()
        db.refresh(job)
        
        # Update publication with job reference
        publication.meta_data = {**publication.meta_data, "job_id": str(job.id)}
        db.commit()
        
        # Publish event
        publish_event("PUBLICATION_CREATED", {
            "publication_id": str(publication.id),
            "episode_id": str(plan_data.episode_id),
            "platform": platform_account.platform
        })
        
        return publication
    
    def get_publications(self, db: Session, episode_id: UUID) -> List[PublicationRecord]:
        """Get all publications for episode"""
        return db.query(PublicationRecord).filter(
            PublicationRecord.episode_id == episode_id
        ).all()
    
    def get_publication(self, db: Session, publication_id: UUID) -> Optional[PublicationRecord]:
        """Get publication by ID"""
        return db.query(PublicationRecord).filter(
            PublicationRecord.id == publication_id
        ).first()
    
    def update_publication_status(
        self,
        db: Session,
        publication_id: UUID,
        status: str,
        external_post_id: Optional[str] = None,
        published_time: Optional[datetime] = None,
        fail_reason: Optional[str] = None
    ) -> PublicationRecord:
        """Update publication status"""
        publication = self.get_publication(db, publication_id)
        if not publication:
            raise ValueError("Publication not found")
        
        publication.status = status
        if external_post_id:
            publication.external_post_id = external_post_id
        if published_time:
            publication.published_time = published_time
        if fail_reason:
            publication.fail_reason = fail_reason
        
        db.commit()
        db.refresh(publication)
        
        publish_event("PUBLICATION_UPDATED", {
            "publication_id": str(publication_id),
            "status": status
        })
        
        return publication

