"""
Publishing Router
API endpoints for publishing content to platforms
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.core.db import get_db
from app.schemas.publishing import (
    PublishingPlanRequest,
    PublishingPlanResponse,
    PublicationRecordResponse
)
from app.services.publishing_service import PublishingService

router = APIRouter(prefix="/publishing", tags=["publishing"])

publishing_service = PublishingService()


@router.post("/plan", response_model=PublishingPlanResponse, status_code=status.HTTP_201_CREATED)
def create_publishing_plan(
    plan_data: PublishingPlanRequest,
    db: Session = Depends(get_db),
    # user_id: UUID = Depends(get_current_user)  # TODO: Add auth
):
    """Create publishing plan"""
    try:
        # TODO: Get user_id from auth
        user_id = UUID("00000000-0000-0000-0000-000000000000")  # Mock user_id
        publication = publishing_service.create_publishing_plan(db, plan_data, user_id)
        return PublishingPlanResponse(
            publication_id=publication.id,
            status=publication.status,
            scheduled_time=publication.scheduled_time,
            estimated_time=300  # Mock estimate
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create publishing plan: {str(e)}"
        )


@router.get("/episode/{episode_id}", response_model=List[PublicationRecordResponse])
def get_episode_publications(episode_id: UUID, db: Session = Depends(get_db)):
    """Get all publications for episode"""
    publications = publishing_service.get_publications(db, episode_id)
    return publications


@router.get("/publication/{publication_id}", response_model=PublicationRecordResponse)
def get_publication(publication_id: UUID, db: Session = Depends(get_db)):
    """Get publication by ID"""
    publication = publishing_service.get_publication(db, publication_id)
    if not publication:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Publication not found"
        )
    return publication


@router.post("/webhook/{platform}")
def handle_webhook(platform: str, payload: dict, db: Session = Depends(get_db)):
    """Handle platform webhooks"""
    # TODO: Implement webhook handlers
    return {"status": "received", "platform": platform}

