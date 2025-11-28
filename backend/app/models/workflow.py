"""Workflow model"""
from sqlalchemy import Column, String, DateTime, JSON, Integer, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
from app.core.db import Base


class WorkflowRun(Base):
    """WorkflowRun model - represents a pipeline execution"""
    __tablename__ = "workflow_runs"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id"), nullable=False)
    name = Column(String(255), nullable=False)
    status = Column(String(50), default="running")  # "running", "success", "failed", "partial"
    steps = Column(JSON, nullable=False)  # List of job steps
    current_step_index = Column(Integer, default=0)
    meta_data = Column("metadata", JSON, nullable=True, default=dict)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f"<WorkflowRun(id={self.id}, name={self.name}, status={self.status})>"

