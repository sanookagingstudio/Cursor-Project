"""Job schemas"""
from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime
from uuid import UUID


class JobCreate(BaseModel):
    """Schema for creating a job"""
    project_id: UUID
    module_id: str
    type: str
    input_payload: Dict[str, Any]
    priority: int = 5
    max_retries: int = 3


class JobResponse(BaseModel):
    """Schema for job response"""
    id: UUID
    project_id: UUID
    module_id: str
    type: str
    status: str
    priority: int
    input_payload: Dict[str, Any]
    output_payload: Optional[Dict[str, Any]]
    error_message: Optional[str]
    retry_count: int
    max_retries: int
    queued_at: datetime
    started_at: Optional[datetime]
    finished_at: Optional[datetime]
    
    class Config:
        from_attributes = True

