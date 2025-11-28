"""
External Application Integration API Router
FastAPI endpoints for Phase 12
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.core.db import get_db
from app.services.external_app_service import ExternalAppService
from app.schemas.external_app import (
    ExternalApplicationCreate,
    ExternalApplicationUpdate,
    ExternalApplicationResponse,
    APIKeyCreate,
    APIKeyResponse,
    ExternalAppUserCreate,
    ExternalAppUserResponse,
    ExternalAppUsageSummary
)

router = APIRouter()


# External Applications (Admin)
@router.get("/apps", response_model=List[ExternalApplicationResponse])
def get_external_apps(
    status: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all external applications"""
    return ExternalAppService.get_external_apps(db, status)


@router.get("/apps/{app_id}", response_model=ExternalApplicationResponse)
def get_external_app(
    app_id: UUID,
    db: Session = Depends(get_db)
):
    """Get external application by ID"""
    app = ExternalAppService.get_external_app(db, app_id)
    if not app:
        raise HTTPException(status_code=404, detail="External application not found")
    return app


@router.post("/apps", response_model=ExternalApplicationResponse, status_code=status.HTTP_201_CREATED)
def create_external_app(
    app_data: ExternalApplicationCreate,
    db: Session = Depends(get_db)
):
    """Create a new external application"""
    return ExternalAppService.create_external_app(db, app_data)


@router.put("/apps/{app_id}", response_model=ExternalApplicationResponse)
def update_external_app(
    app_id: UUID,
    app_data: ExternalApplicationUpdate,
    db: Session = Depends(get_db)
):
    """Update external application"""
    app = ExternalAppService.update_external_app(db, app_id, app_data)
    if not app:
        raise HTTPException(status_code=404, detail="External application not found")
    return app


# API Keys (Admin)
@router.get("/apps/{app_id}/api-keys", response_model=List[APIKeyResponse])
def get_api_keys(
    app_id: UUID,
    db: Session = Depends(get_db)
):
    """Get API keys for an application"""
    return ExternalAppService.get_api_keys(db, app_id)


@router.post("/apps/{app_id}/api-keys", response_model=APIKeyResponse, status_code=status.HTTP_201_CREATED)
def generate_api_key(
    app_id: UUID,
    key_data: APIKeyCreate,
    db: Session = Depends(get_db)
):
    """Generate a new API key"""
    key_data.app_id = app_id
    key, api_key = ExternalAppService.generate_api_key(db, key_data)
    
    # Return key with the actual API key (only shown once)
    response = APIKeyResponse.model_validate(key)
    # Note: In production, return the API key in a separate response or store securely
    return response


@router.delete("/api-keys/{key_id}", status_code=status.HTTP_204_NO_CONTENT)
def revoke_api_key(
    key_id: UUID,
    db: Session = Depends(get_db)
):
    """Revoke an API key"""
    key = ExternalAppService.revoke_api_key(db, key_id)
    if not key:
        raise HTTPException(status_code=404, detail="API key not found")
    return None


# Usage (Admin)
@router.get("/apps/{app_id}/usage", response_model=ExternalAppUsageSummary)
def get_usage_summary(
    app_id: UUID,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get usage summary for an application"""
    summary = ExternalAppService.get_usage_summary(db, app_id, start_date, end_date)
    return ExternalAppUsageSummary(**summary)

