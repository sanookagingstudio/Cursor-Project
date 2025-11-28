"""
Music & Audio Module Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime


# Stem Separation Schemas
class StemSeparationRequest(BaseModel):
    asset_id: UUID = Field(..., description="Source audio asset ID")
    stems: Optional[List[str]] = Field(default=None, description="Stems to extract: vocal, drums, bass, other")
    provider: Optional[str] = Field(default="mock", description="AI provider")


class StemSeparationResponse(BaseModel):
    job_id: UUID
    status: str
    stem_group_id: Optional[UUID] = None
    estimated_time: Optional[int] = None  # seconds


# Music Analysis Schemas
class MusicAnalysisRequest(BaseModel):
    asset_id: UUID = Field(..., description="Audio asset ID to analyze")
    tasks: Optional[List[str]] = Field(default=None, description="Analysis tasks: bpm, key, chords, sections, energy")
    provider: Optional[str] = Field(default="mock", description="AI provider")


class MusicAnalysisResponse(BaseModel):
    job_id: UUID
    status: str
    analysis_id: Optional[UUID] = None
    estimated_time: Optional[int] = None


# Tab Generation Schemas
class TabGenerationRequest(BaseModel):
    asset_id: UUID = Field(..., description="Audio asset ID")
    instrument: str = Field(default="guitar", description="Instrument: guitar, bass, ukulele")
    difficulty: str = Field(default="original", description="Difficulty: easy, original, advanced")
    format: str = Field(default="text", description="Format: text, gp5, musicxml")
    provider: Optional[str] = Field(default="mock", description="AI provider")


class TabGenerationResponse(BaseModel):
    job_id: UUID
    status: str
    tab_id: Optional[UUID] = None
    estimated_time: Optional[int] = None


# Music Generation Schemas
class MusicGenerateRequest(BaseModel):
    project_id: Optional[UUID] = None
    prompt: str = Field(..., min_length=1, description="Music generation prompt")
    duration_seconds: int = Field(default=30, ge=5, le=300, description="Duration in seconds")
    tempo: Optional[int] = Field(default=None, ge=60, le=200, description="BPM")
    key: Optional[str] = Field(default=None, description="Musical key (e.g., 'C:maj', 'A:min')")
    mood: Optional[str] = Field(default=None, description="Mood/style")
    instruments: Optional[List[str]] = Field(default=None, description="List of instruments")
    provider: Optional[str] = Field(default="mock", description="AI provider")


class MusicGenerateResponse(BaseModel):
    job_id: UUID
    status: str
    result: Optional[Dict[str, Any]] = None
    estimated_time: Optional[int] = None


# Audio Remaster Schemas
class RemasterOperation(BaseModel):
    type: str = Field(..., description="Operation type: noise_reduction, eq, normalize, stereo_widen")
    params: Dict[str, Any] = Field(default={}, description="Operation parameters")


class AudioRemasterRequest(BaseModel):
    asset_id: UUID = Field(..., description="Source audio asset ID")
    operations: List[RemasterOperation] = Field(..., min_length=1, description="List of remaster operations")
    provider: Optional[str] = Field(default="mock", description="AI provider")


class AudioRemasterResponse(BaseModel):
    job_id: UUID
    status: str
    result: Optional[Dict[str, Any]] = None
    estimated_time: Optional[int] = None


# Response Schemas
class AudioAnalysisResponse(BaseModel):
    id: UUID
    asset_id: UUID
    bpm: Optional[float]
    key: Optional[str]
    time_signature: Optional[str]
    sections: List[Dict[str, Any]]
    chord_progression: List[Dict[str, Any]]
    energy_curve: Dict[str, Any]
    metadata: Dict[str, Any]
    created_at: datetime

    model_config = {"from_attributes": True}


class StemGroupResponse(BaseModel):
    id: UUID
    source_asset_id: UUID
    stem_assets: Dict[str, str]  # {"vocal": "uuid", "drums": "uuid", ...}
    provider: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}


class TabRecordResponse(BaseModel):
    id: UUID
    audio_asset_id: UUID
    instrument: str
    difficulty: str
    format: str
    content: str
    created_at: datetime

    model_config = {"from_attributes": True}


# Enhanced Music Feature Schemas
class KaraokeGeneratorRequest(BaseModel):
    project_id: Optional[UUID] = None
    source_audio_id: UUID = Field(..., description="Source audio asset ID")
    vocal_removal_strength: str = Field(default="medium", description="low, medium, high")
    lyrics_display_style: str = Field(default="classic", description="classic, modern")
    provider: Optional[str] = Field(default="mock")


class VoiceCloneRequest(BaseModel):
    project_id: Optional[UUID] = None
    source_audio_id: UUID = Field(..., description="Source audio for voice cloning")
    text: str = Field(..., min_length=1, description="Text to generate speech")
    language: str = Field(default="th", description="Language code")
    provider: Optional[str] = Field(default="mock")


class SoundEffectsRequest(BaseModel):
    project_id: Optional[UUID] = None
    effect_type: str = Field(..., description="Effect type: explosion, door, nature, etc.")
    duration: float = Field(default=2.0, ge=0.1, le=10.0, description="Duration in seconds")
    provider: Optional[str] = Field(default="mock")

