"""
Video Workers
Celery tasks for video generation, editing, and subtitle processing
"""

from celery import shared_task
from typing import Dict, Any
from uuid import UUID
from app.core.celery_app import celery_app
from app.core.db import SessionLocal
from app.models.job import Job
from app.models.asset import Asset
from app.providers.video_provider_base import VideoProviderBase
from app.providers.video_mock import MockVideoProvider
from app.core.events import publish_event


@shared_task(name="video.generate", bind=True)
def generate_video_task(self, job_id: str):
    """
    Generate video from prompt
    
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
        prompt = input_data.get("prompt")
        duration_seconds = input_data.get("duration_seconds", 15)
        aspect_ratio = input_data.get("aspect_ratio", "16:9")
        resolution = input_data.get("resolution")
        style = input_data.get("style")
        provider_name = input_data.get("provider", "mock")
        
        # Get provider
        provider: VideoProviderBase = MockVideoProvider()
        
        # Generate video
        result = provider.generate_video(
            prompt=prompt,
            duration_seconds=duration_seconds,
            aspect_ratio=aspect_ratio,
            resolution=resolution,
            style=style
        )
        
        # Create asset
        asset = Asset(
            project_id=job.project_id,
            type="video",
            path=result.video_url,
            provider=provider_name,
            meta_data={
                "duration": result.duration,
                "width": result.width,
                "height": result.height,
                "fps": result.fps,
                "format": result.format,
                "aspect_ratio": aspect_ratio,
                "has_audio": True,
                **result.metadata
            }
        )
        db.add(asset)
        db.commit()
        db.refresh(asset)
        
        # Update job
        job.status = "completed"
        job.output_payload = {
            "asset_id": str(asset.id),
            "url": result.video_url,
            "duration": result.duration,
            "width": result.width,
            "height": result.height
        }
        db.commit()
        
        # Publish events
        publish_event("ASSET_CREATED", {
            "asset_id": str(asset.id),
            "type": "video",
            "job_id": job_id
        })
        
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "video.generate"
        })
        
        return {
            "status": "completed",
            "asset_id": str(asset.id),
            "url": result.video_url
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        publish_event("JOB_FAILED", {
            "job_id": job_id,
            "type": "video.generate",
            "error": str(e)
        })
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


@shared_task(name="video.edit", bind=True)
def edit_video_task(self, job_id: str):
    """
    Edit existing video
    
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
        asset_id = input_data.get("asset_id")
        operations = input_data.get("operations", [])
        output_config = input_data.get("output_config", {})
        provider_name = input_data.get("provider", "mock")
        
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == UUID(asset_id)).first()
        if not source_asset:
            job.status = "failed"
            job.output_payload = {"error": "Source asset not found"}
            db.commit()
            return {"status": "error", "message": "Source asset not found"}
        
        # Get provider
        provider: VideoProviderBase = MockVideoProvider()
        
        # Edit video
        result = provider.edit_video(
            source_path=source_asset.path,
            operations=operations,
            output_config=output_config
        )
        
        # Create new asset
        asset = Asset(
            project_id=job.project_id,
            type="video",
            path=result.video_url,
            provider=provider_name,
            meta_data={
                "duration": result.duration,
                "width": result.width,
                "height": result.height,
                "fps": result.fps,
                "format": result.format,
                "source_asset_id": asset_id,
                "operations": operations,
                **result.metadata
            }
        )
        db.add(asset)
        db.commit()
        db.refresh(asset)
        
        # Update job
        job.status = "completed"
        job.output_payload = {
            "asset_id": str(asset.id),
            "url": result.video_url
        }
        db.commit()
        
        # Publish events
        publish_event("ASSET_CREATED", {
            "asset_id": str(asset.id),
            "type": "video",
            "job_id": job_id
        })
        
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "video.edit"
        })
        
        return {
            "status": "completed",
            "asset_id": str(asset.id),
            "url": result.video_url
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


@shared_task(name="video.subtitle", bind=True)
def subtitle_video_task(self, job_id: str):
    """
    Generate subtitles for video
    
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
        asset_id = input_data.get("asset_id")
        source_language = input_data.get("source_language", "auto")
        target_languages = input_data.get("target_languages", [])
        style = input_data.get("style", "default")
        provider_name = input_data.get("provider", "mock")
        
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == UUID(asset_id)).first()
        if not source_asset:
            job.status = "failed"
            job.output_payload = {"error": "Source asset not found"}
            db.commit()
            return {"status": "error", "message": "Source asset not found"}
        
        # Get provider
        provider: VideoProviderBase = MockVideoProvider()
        
        # Generate subtitles
        result = provider.subtitle_video(
            source_path=source_asset.path,
            source_language=source_language,
            target_languages=target_languages,
            style=style
        )
        
        # Create subtitle asset
        subtitle_asset = Asset(
            project_id=job.project_id,
            type="subtitle",
            path=result.subtitle_file_url or "",
            provider=provider_name,
            meta_data={
                "video_asset_id": asset_id,
                "transcript": result.transcript,
                "subtitle_format": result.subtitle_format,
                "segments": result.segments,
                "source_language": source_language,
                "target_languages": target_languages,
                "style": style,
                **result.metadata
            }
        )
        db.add(subtitle_asset)
        db.commit()
        db.refresh(subtitle_asset)
        
        # Update job
        job.status = "completed"
        job.output_payload = {
            "subtitle_asset_id": str(subtitle_asset.id),
            "transcript": result.transcript,
            "subtitle_file_url": result.subtitle_file_url,
            "segments": result.segments
        }
        db.commit()
        
        # Publish events
        publish_event("ASSET_CREATED", {
            "asset_id": str(subtitle_asset.id),
            "type": "subtitle",
            "job_id": job_id
        })
        
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "video.subtitle"
        })
        
        return {
            "status": "completed",
            "subtitle_asset_id": str(subtitle_asset.id),
            "transcript": result.transcript
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()
