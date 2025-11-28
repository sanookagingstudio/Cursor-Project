"""
Publishing Workers
Celery tasks for uploading content, syncing metrics, and syncing revenue
"""

from celery import shared_task
from typing import Dict, Any
from uuid import UUID
from datetime import datetime
from app.core.celery_app import celery_app
from app.core.db import SessionLocal
from app.models.job import Job
from app.models.asset import Asset
from app.models.publishing import PublicationRecord, PerformanceSnapshot, RevenueRecord
from app.providers.publisher_provider_base import PlatformPublisherBase
from app.providers.publisher_mock import MockPlatformPublisher
from app.core.events import publish_event


@shared_task(name="publishing.upload", bind=True)
def upload_publication_task(self, job_id: str):
    """
    Upload content to platform
    
    Args:
        job_id: Job ID
    """
    db = SessionLocal()
    job = None
    try:
        job = db.query(Job).filter(Job.id == UUID(job_id)).first()
        if not job:
            return {"status": "error", "message": "Job not found"}
        
        job.status = "processing"
        db.commit()
        
        # Get input payload
        input_data = job.input_payload or {}
        publication_id = input_data.get("publication_id")
        episode_id = input_data.get("episode_id")
        platform = input_data.get("platform", "youtube")
        scheduled_time_str = input_data.get("scheduled_time")
        
        # Get publication record
        publication = db.query(PublicationRecord).filter(
            PublicationRecord.id == UUID(publication_id)
        ).first()
        if not publication:
            job.status = "failed"
            job.output_payload = {"error": "Publication not found"}
            db.commit()
            return {"status": "error", "message": "Publication not found"}
        
        # Get episode and asset
        from app.models.publishing import Episode
        episode = db.query(Episode).filter(Episode.id == UUID(episode_id)).first()
        if not episode or not episode.primary_asset_id:
            job.status = "failed"
            job.output_payload = {"error": "Episode or asset not found"}
            db.commit()
            return {"status": "error", "message": "Episode or asset not found"}
        
        asset = db.query(Asset).filter(Asset.id == episode.primary_asset_id).first()
        if not asset:
            job.status = "failed"
            job.output_payload = {"error": "Asset not found"}
            db.commit()
            return {"status": "error", "message": "Asset not found"}
        
        # Get provider
        provider: PlatformPublisherBase = MockPlatformPublisher(auth_config={"platform": platform})
        
        # Upload or schedule
        if scheduled_time_str:
            scheduled_time = datetime.fromisoformat(scheduled_time_str)
            result = provider.schedule(
                asset_path=asset.path,
                title=episode.title,
                description=episode.description or "",
                scheduled_time=scheduled_time,
                metadata=episode.metadata or {}
            )
            publication.status = "scheduled"
            publication.scheduled_time = scheduled_time
        else:
            result = provider.upload(
                asset_path=asset.path,
                title=episode.title,
                description=episode.description or "",
                metadata=episode.metadata or {}
            )
            publication.status = "published"
            publication.external_post_id = result.external_post_id
            publication.published_time = result.published_time
        
        publication.metadata = {**publication.metadata, **result.metadata}
        db.commit()
        db.refresh(publication)
        
        # Update job
        job.status = "completed"
        job.output_payload = {
            "publication_id": str(publication.id),
            "external_post_id": publication.external_post_id,
            "status": publication.status
        }
        db.commit()
        
        # Publish events
        publish_event("PUBLICATION_UPLOADED", {
            "publication_id": str(publication.id),
            "platform": platform,
            "status": publication.status
        })
        
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "publishing.upload"
        })
        
        return {
            "status": "completed",
            "publication_id": str(publication.id),
            "external_post_id": publication.external_post_id
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        publish_event("JOB_FAILED", {
            "job_id": job_id,
            "type": "publishing.upload",
            "error": str(e)
        })
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


@shared_task(name="publishing.sync_metrics", bind=True)
def sync_metrics_task(self, publication_id: str):
    """
    Sync metrics from platform
    
    Args:
        publication_id: Publication ID
    """
    db = SessionLocal()
    try:
        publication = db.query(PublicationRecord).filter(
            PublicationRecord.id == UUID(publication_id)
        ).first()
        if not publication or not publication.external_post_id:
            return {"status": "error", "message": "Publication or external_post_id not found"}
        
        # Get provider
        provider: PlatformPublisherBase = MockPlatformPublisher(auth_config={"platform": publication.platform})
        
        # Fetch metrics
        metrics = provider.fetch_metrics(publication.external_post_id)
        
        # Create snapshot
        snapshot = PerformanceSnapshot(
            publication_id=publication.id,
            views=metrics.views,
            likes=metrics.likes,
            comments=metrics.comments,
            shares=metrics.shares,
            watch_time_seconds=metrics.watch_time_seconds,
            ctr=metrics.ctr,
            engagement_rate=metrics.engagement_rate,
            estimated_revenue=metrics.estimated_revenue,
            metadata=metrics.metadata
        )
        db.add(snapshot)
        db.commit()
        db.refresh(snapshot)
        
        # Publish event
        publish_event("METRICS_SYNCED", {
            "publication_id": publication_id,
            "views": metrics.views
        })
        
        return {
            "status": "completed",
            "snapshot_id": str(snapshot.id),
            "views": metrics.views
        }
        
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


@shared_task(name="publishing.sync_revenue", bind=True)
def sync_revenue_task(self, publication_id: str):
    """
    Sync revenue from platform
    
    Args:
        publication_id: Publication ID
    """
    db = SessionLocal()
    try:
        publication = db.query(PublicationRecord).filter(
            PublicationRecord.id == UUID(publication_id)
        ).first()
        if not publication or not publication.external_post_id:
            return {"status": "error", "message": "Publication or external_post_id not found"}
        
        # Get provider
        provider: PlatformPublisherBase = MockPlatformPublisher(auth_config={"platform": publication.platform})
        
        # Fetch revenue
        revenue = provider.fetch_revenue(publication.external_post_id)
        if not revenue:
            return {"status": "skipped", "message": "Revenue not available for this platform"}
        
        # Create revenue record
        revenue_record = RevenueRecord(
            publication_id=publication.id,
            source=revenue.source,
            amount=revenue.amount,
            currency=revenue.currency,
            period_start=revenue.period_start.date() if revenue.period_start else None,
            period_end=revenue.period_end.date() if revenue.period_end else None,
            metadata=revenue.metadata
        )
        db.add(revenue_record)
        db.commit()
        db.refresh(revenue_record)
        
        # Publish event
        publish_event("REVENUE_SYNCED", {
            "publication_id": publication_id,
            "amount": revenue.amount,
            "currency": revenue.currency
        })
        
        return {
            "status": "completed",
            "revenue_id": str(revenue_record.id),
            "amount": revenue.amount
        }
        
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        db.close()

