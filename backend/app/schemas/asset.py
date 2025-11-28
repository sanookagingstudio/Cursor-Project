"""Asset schemas"""
from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime
from uuid import UUID


class AssetResponse(BaseModel):
    """Schema for asset response"""
    id: UUID
    project_id: UUID
    type: str
    path: str
    thumbnail_path: Optional[str]
    status: str
    source: str
    provider: Optional[str]
    metadata: Optional[Dict[str, Any]]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

