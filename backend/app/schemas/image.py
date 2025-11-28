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
    feature_type: str = Field(..., description="Feature type: coloring_book, pattern, origami, mosaic, pixel_art, line_sticker, gif, emoji, digital_card, meme, qr_code, face_swap, style_transfer, ocr, collage, watermark, color_palette, etc.")
    prompt: str = Field(..., min_length=1)
    options: Dict[str, Any] = Field(default={})
    provider: Optional[str] = Field(default="flux")
    source_image_ids: Optional[List[UUID]] = Field(default=None, description="Source image IDs for features that need input images")


# Enhanced Feature Specific Schemas
class MosaicRequest(BaseModel):
    project_id: Optional[UUID] = None
    source_image_ids: List[UUID] = Field(..., min_items=1, description="Source images for mosaic")
    tile_size: int = Field(default=50, ge=10, le=200, description="Tile size in pixels")
    grid_size: Optional[tuple] = Field(default=None, description="Grid size (rows, cols)")
    provider: Optional[str] = Field(default="mock")


class PixelArtRequest(BaseModel):
    project_id: Optional[UUID] = None
    source_image_id: UUID = Field(..., description="Source image to convert")
    pixel_depth: str = Field(default="8bit", description="8bit or 16bit")
    color_count: int = Field(default=256, ge=2, le=256, description="Number of colors")
    pixel_size: int = Field(default=4, ge=1, le=20, description="Pixel size")
    provider: Optional[str] = Field(default="mock")


class LineStickerRequest(BaseModel):
    project_id: Optional[UUID] = None
    prompt: str = Field(..., min_length=1)
    sticker_type: str = Field(default="static", description="static or animated")
    size: str = Field(default="512x512", description="Sticker size")
    style: Optional[str] = Field(default="cute")
    provider: Optional[str] = Field(default="mock")


class GifGeneratorRequest(BaseModel):
    project_id: Optional[UUID] = None
    source_image_ids: List[UUID] = Field(..., min_items=2, description="Source images for GIF")
    frame_rate: int = Field(default=10, ge=1, le=30, description="Frames per second")
    loop: bool = Field(default=True, description="Loop GIF")
    delay: int = Field(default=100, ge=10, le=1000, description="Delay between frames (ms)")
    provider: Optional[str] = Field(default="mock")


class EmojiGeneratorRequest(BaseModel):
    project_id: Optional[UUID] = None
    prompt: str = Field(..., min_length=1)
    size: str = Field(default="128x128", description="Emoji size: 32x32, 64x64, 128x128, 256x256")
    style: Optional[str] = Field(default="cute")
    provider: Optional[str] = Field(default="mock")


class DigitalCardRequest(BaseModel):
    project_id: Optional[UUID] = None
    card_type: str = Field(..., description="birthday, wedding, invitation, etc.")
    template_id: Optional[UUID] = None
    text: Dict[str, str] = Field(default={}, description="Text fields: title, message, etc.")
    images: Dict[str, UUID] = Field(default={}, description="Image fields: background, logo, etc.")
    colors: Dict[str, str] = Field(default={}, description="Color customization")
    provider: Optional[str] = Field(default="mock")


class MemeGeneratorRequest(BaseModel):
    project_id: Optional[UUID] = None
    template_id: Optional[str] = Field(default=None, description="Meme template ID")
    source_image_id: Optional[UUID] = None
    top_text: Optional[str] = None
    bottom_text: Optional[str] = None
    text_color: str = Field(default="white")
    font_size: int = Field(default=40, ge=20, le=100)
    provider: Optional[str] = Field(default="mock")


class QrCodeRequest(BaseModel):
    project_id: Optional[UUID] = None
    data: str = Field(..., min_length=1, description="Data to encode in QR code")
    size: int = Field(default=256, ge=100, le=1000, description="QR code size")
    error_correction: str = Field(default="M", description="L, M, Q, H")
    foreground_color: str = Field(default="#000000")
    background_color: str = Field(default="#FFFFFF")
    logo_image_id: Optional[UUID] = None
    provider: Optional[str] = Field(default="mock")


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

