"""
Integration Router
API endpoints for module integration and workflow execution
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Dict, Any
from uuid import UUID

from app.core.db import get_db
from app.services.integration_service import IntegrationService

router = APIRouter(prefix="/integration", tags=["integration"])

integration_service = IntegrationService()


@router.post("/workflow/{workflow_draft_id}/execute")
def execute_workflow(
    workflow_draft_id: UUID,
    project_id: UUID = None,
    db: Session = Depends(get_db),
    # user_id: UUID = Depends(get_current_user)  # TODO: Add auth
):
    """Execute workflow draft"""
    try:
        # TODO: Get user_id from auth
        user_id = UUID("00000000-0000-0000-0000-000000000000")  # Mock user_id
        result = integration_service.execute_workflow_draft(
            db, workflow_draft_id, project_id, user_id
        )
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to execute workflow: {str(e)}"
        )


@router.post("/episode/from-asset")
def create_episode_from_asset(
    asset_id: UUID,
    series_id: UUID,
    title: str,
    description: str = None,
    db: Session = Depends(get_db)
):
    """Create episode from asset"""
    try:
        episode = integration_service.create_episode_from_asset(
            db, asset_id, series_id, title, description
        )
        return {
            "episode_id": str(episode.id),
            "title": episode.title,
            "status": episode.status
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create episode: {str(e)}"
        )


@router.post("/episode/{episode_id}/auto-publish")
def auto_publish_episode(
    episode_id: UUID,
    platform_account_id: UUID,
    scheduled_time: str = None,
    db: Session = Depends(get_db)
):
    """Auto-publish episode"""
    try:
        from datetime import datetime
        scheduled = datetime.fromisoformat(scheduled_time) if scheduled_time else None
        result = integration_service.auto_publish_episode(
            db, episode_id, platform_account_id, scheduled
        )
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to auto-publish: {str(e)}"
        )


@router.get("/workflow/{workflow_draft_id}/status")
def get_workflow_status(
    workflow_draft_id: UUID,
    db: Session = Depends(get_db)
):
    """Get workflow execution status"""
    try:
        status_info = integration_service.get_workflow_status(db, workflow_draft_id)
        return status_info
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )


@router.post("/test/workflow")
def test_workflow(
    workflow_type: str = "image",  # "image", "video", "music", "full"
    db: Session = Depends(get_db)
):
    """Test workflow execution"""
    # This is a test endpoint for integration testing
    return {
        "message": f"Test workflow for {workflow_type}",
        "status": "test_mode"
    }

