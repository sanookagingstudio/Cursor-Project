"""
Image Router
API endpoints for image generation, editing, and templates
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.core.db import get_db
from app.schemas.image import (
    ImageGenerateRequest,
    ImageGenerateResponse,
    ImageEditRequest,
    ImageBatchRequest,
    ImageBatchResponse,
    ImageUpscaleRequest,
    ImageDetailsResponse,
    TemplateApplyRequest,
    SpecialFeatureRequest,
    TemplateLayoutCreate,
    TemplateLayoutResponse
)
from app.services.image_service import ImageService
from app.models.asset import Asset

router = APIRouter(prefix="/image", tags=["image"])

image_service = ImageService()


@router.post("/generate", response_model=ImageGenerateResponse, status_code=status.HTTP_201_CREATED)
def generate_image(
    request: ImageGenerateRequest,
    db: Session = Depends(get_db)
):
    """Generate image from prompt"""
    try:
        job = image_service.generate_image(db, request)
        return ImageGenerateResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=60  # Mock estimate
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate image: {str(e)}"
        )


@router.post("/edit", response_model=ImageGenerateResponse, status_code=status.HTTP_201_CREATED)
def edit_image(
    request: ImageEditRequest,
    db: Session = Depends(get_db)
):
    """Edit existing image"""
    try:
        job = image_service.edit_image(db, request)
        return ImageGenerateResponse(
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
            detail=f"Failed to edit image: {str(e)}"
        )


@router.post("/batch", response_model=ImageBatchResponse, status_code=status.HTTP_201_CREATED)
def batch_generate(
    request: ImageBatchRequest,
    db: Session = Depends(get_db)
):
    """Generate multiple images"""
    try:
        job = image_service.batch_generate(db, request)
        return ImageBatchResponse(
            job_id=job.id,
            status=job.status,
            results=[],
            total_count=request.batch_count,
            estimated_time=request.batch_count * 60  # Mock estimate
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to batch generate: {str(e)}"
        )


@router.post("/upscale", response_model=ImageGenerateResponse, status_code=status.HTTP_201_CREATED)
def upscale_image(
    request: ImageUpscaleRequest,
    db: Session = Depends(get_db)
):
    """Upscale image"""
    try:
        job = image_service.upscale_image(db, request)
        return ImageGenerateResponse(
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
            detail=f"Failed to upscale image: {str(e)}"
        )


@router.post("/template/apply", response_model=ImageGenerateResponse, status_code=status.HTTP_201_CREATED)
def apply_template(
    request: TemplateApplyRequest,
    db: Session = Depends(get_db)
):
    """Apply template layout"""
    try:
        job = image_service.apply_template(db, request)
        return ImageGenerateResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=45  # Mock estimate
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to apply template: {str(e)}"
        )


@router.post("/special", response_model=ImageGenerateResponse, status_code=status.HTTP_201_CREATED)
def generate_special_feature(
    request: SpecialFeatureRequest,
    db: Session = Depends(get_db)
):
    """Generate special feature (coloring book, pattern, etc.)"""
    try:
        job = image_service.generate_special_feature(db, request)
        return ImageGenerateResponse(
            job_id=job.id,
            status=job.status,
            estimated_time=75  # Mock estimate
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate special feature: {str(e)}"
        )


@router.get("/{asset_id}/details", response_model=ImageDetailsResponse)
def get_image_details(asset_id: UUID, db: Session = Depends(get_db)):
    """Get image asset details"""
    asset = db.query(Asset).filter(Asset.id == asset_id).first()
    if not asset:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Image asset not found"
        )
    
    # Parse metadata
    metadata = asset.meta_data or {}
    
    return ImageDetailsResponse(
        asset_id=asset.id,
        project_id=asset.project_id,
        url=asset.path or "",
        width=metadata.get("width", 1024),
        height=metadata.get("height", 1024),
        format=metadata.get("format", "png"),
        file_size=metadata.get("file_size", 0),
        metadata=metadata,
        created_at=asset.created_at
    )


# Template Management Endpoints
@router.post("/templates", response_model=TemplateLayoutResponse, status_code=status.HTTP_201_CREATED)
def create_template(
    template_data: TemplateLayoutCreate,
    db: Session = Depends(get_db)
):
    """Create template layout"""
    try:
        template = image_service.create_template(db, template_data)
        return template
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create template: {str(e)}"
        )


@router.get("/templates", response_model=List[TemplateLayoutResponse])
def list_templates(
    category: str = None,
    db: Session = Depends(get_db)
):
    """List template layouts"""
    templates = image_service.list_templates(db, category)
    return templates


@router.get("/templates/{template_id}", response_model=TemplateLayoutResponse)
def get_template(template_id: UUID, db: Session = Depends(get_db)):
    """Get template by ID"""
    template = image_service.get_template(db, template_id)
    if not template:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Template not found"
        )
    return template

