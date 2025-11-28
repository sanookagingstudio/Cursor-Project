"""Workflow schemas"""
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from datetime import datetime
from uuid import UUID


class WorkflowRunResponse(BaseModel):
    """Schema for workflow response"""
    id: UUID
    project_id: UUID
    name: str
    status: str
    steps: List[Dict[str, Any]]
    current_step_index: int
    metadata: Optional[Dict[str, Any]]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

