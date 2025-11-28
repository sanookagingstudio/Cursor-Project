"""
Image Module Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime


# Image Generation Schemas
class ImageGenerateRequest(BaseModel):
    project_id: Optional[UUID] = None
    prompt: str = Field(..., min_length=1, description="Image generation prompt")
    width: int = Field(default=1024, ge=256, le=4096, description="Image width")
    height: int = Field(default=1024, ge=256, le=4096, description="Image height")
    style: Optional[str] = Field(default="cute", description="Image style")
    reference_image_id: Optional[UUID] = None
    provider: Optional[str] = Field(default="flux", description="AI provider")
    negative_prompt: Optional[str] = None


class ImageEditRequest(BaseModel):
    asset_id: UUID = Field(..., description="Source image asset ID")
    prompt: str = Field(..., min_length=1, description="Edit instruction")
    mask_image_id: Optional[UUID] = None
    edit_type: str = Field(default="inpaint", description="Edit type: inpaint, outpainting, remove, add")
    provider: Optional[str] = Field(default="flux", description="AI provider")


class ImageBatchRequest(BaseModel):
    project_id: Optional[UUID] = None
    prompt: str = Field(..., min_length=1)
    batch_count: int = Field(default=4, ge=1, le=20, description="Number of images to generate")
    width: int = Field(default=1024, ge=256, le=4096)
    height: int = Field(default=1024, ge=256, le=4096)
    style: Optional[str] = Field(default="cute")
    provider: Optional[str] = Field(default="flux")


class ImageUpscaleRequest(BaseModel):
    asset_id: UUID = Field(..., description="Image asset ID to upscale")
    scale: int = Field(default=2, ge=2, le=4, description="Upscale factor (2x, 3x, 4x)")
    provider: Optional[str] = Field(default="flux")


class TemplateApplyRequest(BaseModel):
    template_id: UUID = Field(..., description="Template layout ID")
    project_id: Optional[UUID] = None
    custom_data: Dict[str, Any] = Field(default={}, description="Custom data to fill template")
    provider: Optional[str] = Field(default="flux")


class SpecialFeatureRequest(BaseModel):
    project_id: Optional[UUID] = None
    feature_type: str = Field(..., description="Feature type: coloring_book, pattern, origami, etc.")
    prompt: str = Field(..., min_length=1)
    options: Dict[str, Any] = Field(default={})
    provider: Optional[str] = Field(default="flux")


# Response Schemas
class ImageResult(BaseModel):
    asset_id: UUID
    url: str
    width: int
    height: int
    format: str
    metadata: Dict[str, Any] = Field(default={})


class ImageGenerateResponse(BaseModel):
    job_id: UUID
    status: str
    result: Optional[ImageResult] = None
    estimated_time: Optional[int] = None  # seconds


class ImageBatchResponse(BaseModel):
    job_id: UUID
    status: str
    results: List[ImageResult] = Field(default=[])
    total_count: int
    estimated_time: Optional[int] = None


class ImageDetailsResponse(BaseModel):
    asset_id: UUID
    project_id: Optional[UUID]
    url: str
    width: int
    height: int
    format: str
    file_size: int
    metadata: Dict[str, Any]
    created_at: datetime

    model_config = {"from_attributes": True}


# Template Layout Schemas
class TemplateLayoutCreate(BaseModel):
    name: str
    category: str
    structure_json: Dict[str, Any] = Field(default={})
    preview_image_url: Optional[str] = None


class TemplateLayoutResponse(BaseModel):
    id: UUID
    name: str
    category: str
    structure_json: Dict[str, Any]
    preview_image_url: Optional[str]
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}

