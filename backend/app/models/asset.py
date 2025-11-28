"""Asset model"""
from sqlalchemy import Column, String, DateTime, JSON, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
from app.core.db import Base


class Asset(Base):
    """Asset model - represents a file (image, video, audio, etc.)"""
    __tablename__ = "assets"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id"), nullable=False)
    type = Column(String(50), nullable=False)  # "image", "video", "audio", "text", "mixed"
    path = Column(String(500), nullable=False)  # Storage path
    thumbnail_path = Column(String(500), nullable=True)
    status = Column(String(50), default="ready")  # "ready", "processing", "failed"
    source = Column(String(50), nullable=False)  # "generated", "uploaded", "imported"
    provider = Column(String(100), nullable=True)  # "flux", "pika", "runway", etc.
    meta_data = Column("metadata", JSON, nullable=True, default=dict)  # resolution, duration, format, etc.
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f"<Asset(id={self.id}, type={self.type}, path={self.path})>"

