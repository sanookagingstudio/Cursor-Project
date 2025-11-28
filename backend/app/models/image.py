"""
Image Module Models
Template Layouts for Image Generation
"""

from sqlalchemy import Column, String, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from sqlalchemy.types import TIMESTAMP
from app.core.db import Base
import uuid


class TemplateLayout(Base):
    """Template Layout Model"""
    __tablename__ = "template_layouts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    category = Column(String(50), nullable=False)  # poster, story, infographic, coloring_book, etc.
    structure_json = Column(JSONB, nullable=False, default={})
    preview_image_url = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    def __repr__(self):
        return f"<TemplateLayout(id={self.id}, name={self.name}, category={self.category})>"

