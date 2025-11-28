"""
Image Workers
Celery tasks for image generation, editing, and template processing
"""

from celery import shared_task
from typing import Dict, Any
from uuid import UUID
from app.core.celery_app import celery_app
from app.core.db import SessionLocal
from app.models.job import Job
from app.models.asset import Asset
from app.providers.image_provider_base import ImageProviderBase
from app.providers.image_mock import MockImageProvider
from app.core.events import publish_event


@shared_task(name="image.generate", bind=True)
def generate_image_task(self, job_id: str):
    """
    Generate image from prompt
    
    Args:
        job_id: Job ID
    """
    db = SessionLocal()
    try:
        job = db.query(Job).filter(Job.id == UUID(job_id)).first()
        if not job:
            return {"status": "error", "message": "Job not found"}
        
        # Update job status
        job.status = "processing"
        db.commit()
        
        # Get input payload
        input_data = job.input_payload or {}
        prompt = input_data.get("prompt")
        width = input_data.get("width", 1024)
        height = input_data.get("height", 1024)
        style = input_data.get("style")
        provider_name = input_data.get("provider", "mock")
        
        # Get provider
        provider: ImageProviderBase = MockImageProvider()  # Default to mock
        
        # Generate image
        results = provider.generate(
            prompt=prompt,
            width=width,
            height=height,
            style=style
        )
        
        if not results:
            job.status = "failed"
            job.output_payload = {"error": "No results generated"}
            db.commit()
            return {"status": "error", "message": "No results generated"}
        
        # Create asset for first result
        result = results[0]
        asset = Asset(
            project_id=job.project_id,
            type="image",
            path=result.image_url,
            provider=provider_name,
            meta_data={
                "width": result.width,
                "height": result.height,
                "format": result.format,
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
            "url": result.image_url,
            "width": result.width,
            "height": result.height
        }
        db.commit()
        
        # Publish event
        publish_event("ASSET_CREATED", {
            "asset_id": str(asset.id),
            "type": "image",
            "job_id": job_id
        })
        
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "image.generate"
        })
        
        return {
            "status": "completed",
            "asset_id": str(asset.id),
            "url": result.image_url
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        publish_event("JOB_FAILED", {
            "job_id": job_id,
            "type": "image.generate",
            "error": str(e)
        })
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


@shared_task(name="image.edit", bind=True)
def edit_image_task(self, job_id: str):
    """
    Edit existing image
    
    Args:
        job_id: Job ID
    """
    db = SessionLocal()
    try:
        job = db.query(Job).filter(Job.id == UUID(job_id)).first()
        if not job:
            return {"status": "error", "message": "Job not found"}
        
        job.status = "processing"
        db.commit()
        
        # Get input payload
        input_data = job.input_payload or {}
        asset_id = input_data.get("asset_id")
        prompt = input_data.get("prompt")
        edit_type = input_data.get("edit_type", "inpaint")
        provider_name = input_data.get("provider", "mock")
        
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == UUID(asset_id)).first()
        if not source_asset:
            job.status = "failed"
            job.output_payload = {"error": "Source asset not found"}
            db.commit()
            return {"status": "error", "message": "Source asset not found"}
        
        # Get provider
        provider: ImageProviderBase = MockImageProvider()
        
        # Edit image
        result = provider.edit(
            image_path=source_asset.path,
            prompt=prompt,
            edit_type=edit_type
        )
        
        # Create new asset
        asset = Asset(
            project_id=job.project_id,
            type="image",
            path=result.image_url,
            provider=provider_name,
            meta_data={
                "width": result.width,
                "height": result.height,
                "format": result.format,
                "source_asset_id": asset_id,
                "edit_type": edit_type,
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
            "url": result.image_url
        }
        db.commit()
        
        # Publish events
        publish_event("ASSET_CREATED", {
            "asset_id": str(asset.id),
            "type": "image",
            "job_id": job_id
        })
        
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "image.edit"
        })
        
        return {
            "status": "completed",
            "asset_id": str(asset.id),
            "url": result.image_url
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


@shared_task(name="image.template", bind=True)
def apply_template_task(self, job_id: str):
    """
    Apply template layout
    
    Args:
        job_id: Job ID
    """
    db = SessionLocal()
    try:
        job = db.query(Job).filter(Job.id == UUID(job_id)).first()
        if not job:
            return {"status": "error", "message": "Job not found"}
        
        job.status = "processing"
        db.commit()
        
        # Get input payload
        input_data = job.input_payload or {}
        template_id = input_data.get("template_id")
        custom_data = input_data.get("custom_data", {})
        provider_name = input_data.get("provider", "mock")
        
        # Get provider
        provider: ImageProviderBase = MockImageProvider()
        
        # Generate image from template (mock)
        # In production, this would use template structure
        prompt = custom_data.get("prompt", "Template image")
        result = provider.generate(prompt=prompt, width=1024, height=1024)[0]
        
        # Create asset
        asset = Asset(
            project_id=job.project_id,
            type="image",
            path=result.image_url,
            provider=provider_name,
            meta_data={
                "width": result.width,
                "height": result.height,
                "format": result.format,
                "template_id": template_id,
                "custom_data": custom_data,
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
            "url": result.image_url
        }
        db.commit()
        
        # Publish events
        publish_event("ASSET_CREATED", {
            "asset_id": str(asset.id),
            "type": "image",
            "job_id": job_id
        })
        
        publish_event("JOB_COMPLETED", {
            "job_id": job_id,
            "type": "image.template"
        })
        
        return {
            "status": "completed",
            "asset_id": str(asset.id),
            "url": result.image_url
        }
        
    except Exception as e:
        if job:
            job.status = "failed"
            job.output_payload = {"error": str(e)}
            db.commit()
        
        return {"status": "error", "message": str(e)}
    finally:
        db.close()
