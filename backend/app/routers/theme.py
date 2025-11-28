"""
Theme Router
API endpoints for theme customization
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from uuid import UUID

from app.core.db import get_db
from app.schemas.theme import (
    ThemeCreate,
    ThemeUpdate,
    ThemeResponse,
    ThemeWithSettingsResponse,
    ApplyThemeRequest
)
from app.services.theme_service import ThemeService

router = APIRouter(prefix="/themes", tags=["themes"])

theme_service = ThemeService()


@router.get("", response_model=List[ThemeResponse])
def get_themes(
    include_presets: bool = True,
    db: Session = Depends(get_db)
):
    """Get all themes"""
    themes = theme_service.get_themes(db, include_presets)
    return themes


@router.get("/presets", response_model=List[ThemeResponse])
def get_presets(db: Session = Depends(get_db)):
    """Get preset themes"""
    presets = theme_service.get_presets(db)
    return presets


@router.get("/active", response_model=ThemeWithSettingsResponse)
def get_active_theme(db: Session = Depends(get_db)):
    """Get active theme"""
    theme = theme_service.get_active_theme(db)
    if not theme:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active theme found"
        )
    
    settings = theme_service.get_theme_settings(db, theme.id)
    return ThemeWithSettingsResponse(
        id=theme.id,
        name=theme.name,
        description=theme.description,
        is_preset=theme.is_preset,
        is_active=theme.is_active,
        settings=settings or {},
        created_at=theme.created_at,
        updated_at=theme.updated_at
    )


@router.get("/{theme_id}", response_model=ThemeWithSettingsResponse)
def get_theme(theme_id: UUID, db: Session = Depends(get_db)):
    """Get theme by ID"""
    theme = theme_service.get_theme(db, theme_id)
    if not theme:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Theme not found"
        )
    
    settings = theme_service.get_theme_settings(db, theme.id)
    return ThemeWithSettingsResponse(
        id=theme.id,
        name=theme.name,
        description=theme.description,
        is_preset=theme.is_preset,
        is_active=theme.is_active,
        settings=settings or {},
        created_at=theme.created_at,
        updated_at=theme.updated_at
    )


@router.post("", response_model=ThemeResponse, status_code=status.HTTP_201_CREATED)
def create_theme(
    theme_data: ThemeCreate,
    db: Session = Depends(get_db),
    # user_id: UUID = Depends(get_current_user)  # TODO: Add auth
):
    """Create new theme"""
    try:
        # TODO: Get user_id from auth
        user_id = UUID("00000000-0000-0000-0000-000000000000")  # Mock user_id
        theme = theme_service.create_theme(db, theme_data, user_id)
        return theme
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create theme: {str(e)}"
        )


@router.put("/{theme_id}", response_model=ThemeResponse)
def update_theme(
    theme_id: UUID,
    theme_data: ThemeUpdate,
    db: Session = Depends(get_db)
):
    """Update theme"""
    try:
        theme = theme_service.update_theme(db, theme_id, theme_data)
        return theme
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update theme: {str(e)}"
        )


@router.delete("/{theme_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_theme(theme_id: UUID, db: Session = Depends(get_db)):
    """Delete theme"""
    try:
        theme_service.delete_theme(db, theme_id)
        return None
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.post("/{theme_id}/apply", response_model=ThemeResponse)
def apply_theme(
    theme_id: UUID,
    request: ApplyThemeRequest,
    db: Session = Depends(get_db)
):
    """Apply theme"""
    try:
        theme = theme_service.apply_theme(db, theme_id, request.preview)
        return theme
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )


@router.post("/{theme_id}/export")
def export_theme(theme_id: UUID, db: Session = Depends(get_db)):
    """Export theme as JSON"""
    theme = theme_service.get_theme(db, theme_id)
    if not theme:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Theme not found"
        )
    
    settings = theme_service.get_theme_settings(db, theme_id)
    
    return {
        "name": theme.name,
        "description": theme.description,
        "is_preset": theme.is_preset,
        "settings": settings
    }


@router.post("/import")
def import_theme(
    theme_data: Dict[str, Any],
    db: Session = Depends(get_db),
    # user_id: UUID = Depends(get_current_user)  # TODO: Add auth
):
    """Import theme from JSON"""
    try:
        from app.schemas.theme import ThemeSettings
        # TODO: Get user_id from auth
        user_id = UUID("00000000-0000-0000-0000-000000000000")  # Mock user_id
        
        # Create theme from imported data
        theme_create = ThemeCreate(
            name=theme_data.get("name", "Imported Theme"),
            description=theme_data.get("description"),
            is_preset=False,
            settings=ThemeSettings(**theme_data.get("settings", {}))
        )
        
        theme = theme_service.create_theme(db, theme_create, user_id)
        return theme
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to import theme: {str(e)}"
        )

