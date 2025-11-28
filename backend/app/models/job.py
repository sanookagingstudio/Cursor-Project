"""Job model"""
from sqlalchemy import Column, String, DateTime, JSON, Integer, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
from app.core.db import Base


class Job(Base):
    """Job model - represents a single task for worker"""
    __tablename__ = "jobs"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id"), nullable=False)
    module_id = Column(String(100), nullable=False)  # "image.basic", "video.render", etc.
    type = Column(String(100), nullable=False)  # "IMAGE_GENERATE", "VIDEO_RENDER", etc.
    status = Column(String(50), default="queued")  # "queued", "running", "success", "failed", "canceled"
    priority = Column(Integer, default=5)  # 0-9, higher = more priority
    input_payload = Column(JSON, nullable=False)
    output_payload = Column(JSON, nullable=True)
    error_message = Column(Text, nullable=True)
    retry_count = Column(Integer, default=0)
    max_retries = Column(Integer, default=3)
    queued_at = Column(DateTime, default=datetime.utcnow)
    started_at = Column(DateTime, nullable=True)
    finished_at = Column(DateTime, nullable=True)
    
    def __repr__(self):
        return f"<Job(id={self.id}, type={self.type}, status={self.status})>"

