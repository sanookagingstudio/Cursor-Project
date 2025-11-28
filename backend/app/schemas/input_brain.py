"""
Input Brain Module Schemas
Pydantic schemas for request/response validation
"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime


# Content Idea Schemas
class ContentIdeaCreate(BaseModel):
    project_id: Optional[UUID] = None
    type: str = Field(..., description="Content type: image, video, music, or mixed")
    prompt: str = Field(..., min_length=1, description="User prompt/idea")
    options: Optional[Dict[str, Any]] = Field(default={}, description="Additional options")


class ContentIdeaUpdate(BaseModel):
    selected_version: Optional[int] = None
    status: Optional[str] = None


class ContentIdeaResponse(BaseModel):
    id: UUID
    project_id: Optional[UUID]
    type: str
    prompt: str
    options: Dict[str, Any]
    ai_suggestions: Dict[str, Any]
    selected_version: Optional[int]
    status: str
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


# Idea Version Schemas
class IdeaVersionCreate(BaseModel):
    idea_id: UUID
    version_index: int
    preview_asset_id: Optional[UUID] = None
    metadata: Optional[Dict[str, Any]] = Field(default={})


class IdeaVersionResponse(BaseModel):
    id: UUID
    idea_id: UUID
    version_index: int
    preview_asset_id: Optional[UUID]
    metadata: Dict[str, Any]
    created_at: datetime

    model_config = {"from_attributes": True}


# Workflow Draft Schemas
class WorkflowStep(BaseModel):
    module: str = Field(..., description="Module name: image, video, audio, music")
    action: str = Field(..., description="Action: generate, edit, etc.")
    params: Dict[str, Any] = Field(default={}, description="Action parameters")


class WorkflowDraftCreate(BaseModel):
    idea_id: UUID
    steps: List[WorkflowStep] = Field(default=[], description="Workflow steps")
    metadata: Optional[Dict[str, Any]] = Field(default={})


class WorkflowDraftUpdate(BaseModel):
    steps: Optional[List[WorkflowStep]] = None
    status: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None


class WorkflowDraftResponse(BaseModel):
    id: UUID
    idea_id: UUID
    steps: List[Dict[str, Any]]
    metadata: Dict[str, Any]
    status: str
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


# AI Suggestion Schemas
class AISuggestionRequest(BaseModel):
    idea_id: UUID
    num_versions: int = Field(default=4, ge=1, le=10, description="Number of versions to generate")


class AISuggestionResponse(BaseModel):
    idea_id: UUID
    versions: List[IdeaVersionResponse]
    recommendations: Dict[str, Any] = Field(default={}, description="AI recommendations")


# Workflow Generation Schemas
class WorkflowGenerationRequest(BaseModel):
    idea_id: UUID
    version_index: int


class WorkflowGenerationResponse(BaseModel):
    draft_id: UUID
    steps: List[Dict[str, Any]]
    estimated_cost: Optional[float] = None
    estimated_time: Optional[int] = None  # seconds

