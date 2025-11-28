"""Assets router"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.db import get_db
from app.models.asset import Asset
from app.schemas.asset import AssetResponse

router = APIRouter()


@router.get("/project/{project_id}", response_model=List[AssetResponse])
async def list_project_assets(project_id: str, db: Session = Depends(get_db)):
    """List assets for a project"""
    assets = db.query(Asset).filter(Asset.project_id == project_id).all()
    return assets


@router.get("/{asset_id}", response_model=AssetResponse)
async def get_asset(asset_id: str, db: Session = Depends(get_db)):
    """Get asset by ID"""
    asset = db.query(Asset).filter(Asset.id == asset_id).first()
    if not asset:
        raise HTTPException(status_code=404, detail="Asset not found")
    return asset

