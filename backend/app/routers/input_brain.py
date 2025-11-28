"""
Input Brain Router
API endpoints for Content Ideas, Versions, and Workflow Drafts
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.core.db import get_db
from app.schemas.input_brain import (
    ContentIdeaCreate,
    ContentIdeaUpdate,
    ContentIdeaResponse,
    IdeaVersionResponse,
    WorkflowDraftResponse,
    AISuggestionRequest,
    AISuggestionResponse,
    WorkflowGenerationRequest,
    WorkflowGenerationResponse
)
from app.services.input_brain_service import InputBrainService

router = APIRouter(prefix="/input-brain", tags=["input-brain"])


@router.post("/ideas", response_model=ContentIdeaResponse, status_code=status.HTTP_201_CREATED)
def create_idea(
    idea_data: ContentIdeaCreate,
    db: Session = Depends(get_db)
):
    """Create a new content idea"""
    try:
        idea = InputBrainService.create_idea(db, idea_data)
        return idea
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create idea: {str(e)}"
        )


@router.get("/ideas/{idea_id}", response_model=ContentIdeaResponse)
def get_idea(idea_id: UUID, db: Session = Depends(get_db)):
    """Get content idea by ID"""
    idea = InputBrainService.get_idea(db, idea_id)
    if not idea:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Idea not found"
        )
    return idea


@router.put("/ideas/{idea_id}", response_model=ContentIdeaResponse)
def update_idea(
    idea_id: UUID,
    update_data: ContentIdeaUpdate,
    db: Session = Depends(get_db)
):
    """Update content idea"""
    idea = InputBrainService.update_idea(db, idea_id, update_data)
    if not idea:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Idea not found"
        )
    return idea


@router.post("/ideas/{idea_id}/select-version", response_model=ContentIdeaResponse)
def select_version(
    idea_id: UUID,
    version_index: int,
    db: Session = Depends(get_db)
):
    """Select a version for an idea"""
    idea = InputBrainService.update_idea(
        db,
        idea_id,
        ContentIdeaUpdate(selected_version=version_index, status="selected")
    )
    if not idea:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Idea not found"
        )
    return idea


@router.post("/ideas/{idea_id}/generate-suggestions", response_model=AISuggestionResponse)
def generate_suggestions(
    idea_id: UUID,
    num_versions: int = 4,
    db: Session = Depends(get_db)
):
    """Generate AI suggestions for an idea"""
    try:
        versions = InputBrainService.generate_ai_suggestions(db, idea_id, num_versions)
        idea = InputBrainService.get_idea(db, idea_id)
        return AISuggestionResponse(
            idea_id=idea_id,
            versions=[IdeaVersionResponse.model_validate(v) for v in versions],
            recommendations={
                "best_version": 1,
                "reason": "Highest confidence score"
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate suggestions: {str(e)}"
        )


@router.get("/ideas/{idea_id}/versions", response_model=List[IdeaVersionResponse])
def get_versions(idea_id: UUID, db: Session = Depends(get_db)):
    """Get all versions for an idea"""
    versions = InputBrainService.get_versions(db, idea_id)
    return versions


@router.post("/ideas/{idea_id}/generate-workflow-draft", response_model=WorkflowDraftResponse)
def generate_workflow_draft(
    idea_id: UUID,
    version_index: int,
    db: Session = Depends(get_db)
):
    """Generate workflow draft from selected idea version"""
    try:
        draft = InputBrainService.generate_workflow_draft(db, idea_id, version_index)
        return draft
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate workflow draft: {str(e)}"
        )


@router.get("/workflow-drafts/{draft_id}", response_model=WorkflowDraftResponse)
def get_workflow_draft(draft_id: UUID, db: Session = Depends(get_db)):
    """Get workflow draft by ID"""
    draft = InputBrainService.get_workflow_draft(db, draft_id)
    if not draft:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workflow draft not found"
        )
    return draft


@router.post("/workflow-drafts/{draft_id}/start", response_model=dict)
def start_workflow(draft_id: UUID, db: Session = Depends(get_db)):
    """Start workflow from draft"""
    try:
        result = InputBrainService.start_workflow(db, draft_id)
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to start workflow: {str(e)}"
        )

