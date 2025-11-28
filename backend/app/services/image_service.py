"""
Image Service
Business logic for image generation, editing, and template application
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from sqlalchemy.orm import Session
from app.models.image import TemplateLayout
from app.models.project import Project
from app.models.asset import Asset
from app.models.job import Job
from app.schemas.image import (
    ImageGenerateRequest,
    ImageEditRequest,
    ImageBatchRequest,
    ImageUpscaleRequest,
    TemplateApplyRequest,
    SpecialFeatureRequest,
    TemplateLayoutCreate
)
from app.providers.image_provider_base import ImageProviderBase
from app.providers.image_mock import MockImageProvider
from app.core.events import publish_event
from app.core.celery_app import celery_app


class ImageService:
    """Service for image operations"""
    
    def __init__(self):
        # Default to mock provider for now
        # In production, this would load from provider registry
        self.default_provider: ImageProviderBase = MockImageProvider()
    
    def get_provider(self, provider_name: Optional[str] = None) -> ImageProviderBase:
        """Get image provider by name"""
        if provider_name == "mock" or provider_name is None:
            return MockImageProvider()
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
        
        # Create new project
        project = Project(
            name="Image Generation Project",
            owner_id=str(user_id) if user_id else "system",
            meta_data={"source": "image_module"}
        )
        db.add(project)
        db.flush()
        return project
    
    def generate_image(
        self,
        db: Session,
        request: ImageGenerateRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Generate image from prompt"""
        # Create project if needed
        project = self.create_project_if_needed(db, request.project_id, user_id)
        
        # Get provider
        provider = self.get_provider(request.provider)
        
        # Create job
        job = Job(
            project_id=project.id,
            type="image.generate",
            status="pending",
            input_payload={
                "prompt": request.prompt,
                "width": request.width,
                "height": request.height,
                "style": request.style,
                "reference_image_id": str(request.reference_image_id) if request.reference_image_id else None,
                "provider": request.provider or "mock",
                "negative_prompt": request.negative_prompt
            },
            output_payload={}
        )
        db.add(job)
        db.commit()
        db.refresh(job)
        
        # Publish event
        publish_event("JOB_CREATED", {
            "job_id": str(job.id),
            "type": "image.generate",
            "project_id": str(project.id)
        })
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("image.generate", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch image.generate task: {e}")
        
        return job
    
    def edit_image(
        self,
        db: Session,
        request: ImageEditRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Edit existing image"""
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == request.asset_id).first()
        if not source_asset:
            raise ValueError("Source asset not found")
        
        # Create job
        job = Job(
            project_id=source_asset.project_id,
            type="image.edit",
            status="pending",
            input_payload={
                "asset_id": str(request.asset_id),
                "prompt": request.prompt,
                "mask_image_id": str(request.mask_image_id) if request.mask_image_id else None,
                "edit_type": request.edit_type,
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
            "type": "image.edit",
            "asset_id": str(request.asset_id)
        })
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("image.edit", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch image.edit task: {e}")
        
        return job
    
    def batch_generate(
        self,
        db: Session,
        request: ImageBatchRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Generate multiple images"""
        # Create project if needed
        project = self.create_project_if_needed(db, request.project_id, user_id)
        
        # Create job
        job = Job(
            project_id=project.id,
            type="image.batch",
            status="pending",
            input_payload={
                "prompt": request.prompt,
                "batch_count": request.batch_count,
                "width": request.width,
                "height": request.height,
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
            "type": "image.batch",
            "project_id": str(project.id),
            "batch_count": request.batch_count
        })
        
        # Dispatch to Celery worker (batch uses generate task)
        try:
            celery_app.send_task("image.generate", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch image.batch task: {e}")
        
        return job
    
    def upscale_image(
        self,
        db: Session,
        request: ImageUpscaleRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Upscale image"""
        # Get source asset
        source_asset = db.query(Asset).filter(Asset.id == request.asset_id).first()
        if not source_asset:
            raise ValueError("Source asset not found")
        
        # Create job
        job = Job(
            project_id=source_asset.project_id,
            type="image.upscale",
            status="pending",
            input_payload={
                "asset_id": str(request.asset_id),
                "scale": request.scale,
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
            "type": "image.upscale",
            "asset_id": str(request.asset_id)
        })
        
        return job
    
    def apply_template(
        self,
        db: Session,
        request: TemplateApplyRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Apply template layout"""
        # Get template
        template = db.query(TemplateLayout).filter(TemplateLayout.id == request.template_id).first()
        if not template:
            raise ValueError("Template not found")
        
        # Create project if needed
        project = self.create_project_if_needed(db, request.project_id, user_id)
        
        # Create job
        job = Job(
            project_id=project.id,
            type="image.template",
            status="pending",
            input_payload={
                "template_id": str(request.template_id),
                "template_category": template.category,
                "custom_data": request.custom_data,
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
            "type": "image.template",
            "template_id": str(request.template_id)
        })
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("image.template", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch image.template task: {e}")
        
        return job
    
    def generate_special_feature(
        self,
        db: Session,
        request: SpecialFeatureRequest,
        user_id: Optional[UUID] = None
    ) -> Job:
        """Generate special feature (coloring book, pattern, mosaic, pixel_art, line_sticker, gif, emoji, digital_card, meme, qr_code, etc.)"""
        # Create project if needed
        project = self.create_project_if_needed(db, request.project_id, user_id)
        
        # Prepare input payload
        input_payload = {
            "feature_type": request.feature_type,
            "prompt": request.prompt,
            "options": request.options,
            "provider": request.provider or "mock"
        }
        
        # Add source_image_ids if provided
        if request.source_image_ids:
            input_payload["source_image_ids"] = [str(id) for id in request.source_image_ids]
        
        # Create job
        job = Job(
            project_id=project.id,
            type="image.special",
            status="pending",
            input_payload=input_payload,
            output_payload={}
        )
        db.add(job)
        db.commit()
        db.refresh(job)
        
        # Publish event
        publish_event("JOB_CREATED", {
            "job_id": str(job.id),
            "type": "image.special",
            "feature_type": request.feature_type
        })
        
        # Dispatch to Celery worker
        try:
            celery_app.send_task("image.special", args=[str(job.id)])
        except Exception as e:
            print(f"Failed to dispatch image.special task: {e}")
        
        return job
    
    def create_template(
        self,
        db: Session,
        template_data: TemplateLayoutCreate
    ) -> TemplateLayout:
        """Create template layout"""
        template = TemplateLayout(
            name=template_data.name,
            category=template_data.category,
            structure_json=template_data.structure_json,
            preview_image_url=template_data.preview_image_url
        )
        db.add(template)
        db.commit()
        db.refresh(template)
        return template
    
    def get_template(self, db: Session, template_id: UUID) -> Optional[TemplateLayout]:
        """Get template by ID"""
        return db.query(TemplateLayout).filter(TemplateLayout.id == template_id).first()
    
    def list_templates(
        self,
        db: Session,
        category: Optional[str] = None
    ) -> List[TemplateLayout]:
        """List templates, optionally filtered by category"""
        query = db.query(TemplateLayout)
        if category:
            query = query.filter(TemplateLayout.category == category)
        return query.order_by(TemplateLayout.created_at.desc()).all()

