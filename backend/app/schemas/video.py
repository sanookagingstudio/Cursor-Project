"""
Video Module Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime


# Video Generation Schemas
class VideoGenerateRequest(BaseModel):
    project_id: Optional[UUID] = None
    prompt: str = Field(..., min_length=1, description="Video generation prompt")
    duration_seconds: int = Field(default=15, ge=5, le=300, description="Video duration in seconds")
    aspect_ratio: str = Field(default="16:9", description="Aspect ratio: 16:9, 9:16, 4:5, 1:1")
    resolution: Optional[str] = Field(default=None, description="Resolution (e.g., '1080x1920')")
    style: Optional[str] = Field(default="cinematic", description="Video style")
    provider: Optional[str] = Field(default="mock", description="AI provider")
    source_assets: Optional[List[UUID]] = Field(default=[], description="Source image/video assets")


class VideoEditOperation(BaseModel):
    type: str = Field(..., description="Operation type: auto_cut_silence, auto_reframe, auto_transition, speed_adjust")
    params: Dict[str, Any] = Field(default={}, description="Operation parameters")


class VideoEditRequest(BaseModel):
    asset_id: UUID = Field(..., description="Source video asset ID")
    operations: List[VideoEditOperation] = Field(..., min_length=1, description="List of edit operations")
    output_config: Optional[Dict[str, Any]] = Field(default={}, description="Output configuration")
    provider: Optional[str] = Field(default="mock", description="AI provider")


class VideoMultiExportRequest(BaseModel):
    asset_id: UUID = Field(..., description="Source video asset ID")
    aspect_ratios: List[str] = Field(..., min_length=1, description="List of aspect ratios to export")
    provider: Optional[str] = Field(default="mock", description="AI provider")


class VideoSubtitleRequest(BaseModel):
    asset_id: UUID = Field(..., description="Video asset ID")
    source_language: str = Field(default="auto", description="Source language code or 'auto'")
    target_languages: Optional[List[str]] = Field(default=[], description="Target languages for translation")
    style: str = Field(default="default", description="Subtitle style: default, tiktok, youtube")
    provider: Optional[str] = Field(default="mock", description="AI provider")


# Response Schemas
class VideoResult(BaseModel):
    asset_id: UUID
    url: str
    duration: float
    width: int
    height: int
    fps: int
    format: str
    metadata: Dict[str, Any] = Field(default={})


class VideoGenerateResponse(BaseModel):
    job_id: UUID
    status: str
    result: Optional[VideoResult] = None
    estimated_time: Optional[int] = None  # seconds


class VideoMultiExportResponse(BaseModel):
    job_id: UUID
    status: str
    results: List[VideoResult] = Field(default=[])
    total_count: int
    estimated_time: Optional[int] = None


class SubtitleResult(BaseModel):
    transcript: str
    subtitle_file_url: Optional[str] = None
    subtitle_format: str
    segments: List[Dict[str, Any]] = Field(default=[])
    metadata: Dict[str, Any] = Field(default={})


class VideoSubtitleResponse(BaseModel):
    job_id: UUID
    status: str
    result: Optional[SubtitleResult] = None
    estimated_time: Optional[int] = None


class VideoDetailsResponse(BaseModel):
    asset_id: UUID
    project_id: Optional[UUID]
    url: str
    duration: float
    width: int
    height: int
    fps: int
    format: str
    has_audio: bool
    aspect_ratio: str
    file_size: int
    metadata: Dict[str, Any]
    created_at: datetime

    model_config = {"from_attributes": True}

