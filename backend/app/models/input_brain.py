"""
Input Brain Module Models
Content Ideas, Idea Versions, and Workflow Drafts
"""

from sqlalchemy import Column, String, Integer, ForeignKey, Text, JSON
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from sqlalchemy.types import TIMESTAMP
from app.core.db import Base
import uuid


class ContentIdea(Base):
    """Content Idea Model"""
    __tablename__ = "content_ideas"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id", ondelete="CASCADE"), nullable=True)
    type = Column(String(50), nullable=False)  # "image" | "video" | "music" | "mixed"
    prompt = Column(Text, nullable=False)
    options = Column(JSONB, default={})
    ai_suggestions = Column(JSONB, default={})
    selected_version = Column(Integer, nullable=True)
    status = Column(String(50), nullable=False, default="draft")  # "draft" | "selected" | "converted_to_workflow"
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    project = relationship("Project", backref="content_ideas")
    versions = relationship("IdeaVersion", back_populates="idea", cascade="all, delete-orphan")
    workflow_drafts = relationship("WorkflowDraft", back_populates="idea", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<ContentIdea(id={self.id}, type={self.type}, status={self.status})>"


class IdeaVersion(Base):
    """Idea Version Model"""
    __tablename__ = "idea_versions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    idea_id = Column(UUID(as_uuid=True), ForeignKey("content_ideas.id", ondelete="CASCADE"), nullable=False)
    version_index = Column(Integer, nullable=False)
    preview_asset_id = Column(UUID(as_uuid=True), ForeignKey("assets.id", ondelete="SET NULL"), nullable=True)
    metadata = Column(JSONB, default={})
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    # Relationships
    idea = relationship("ContentIdea", back_populates="versions")
    preview_asset = relationship("Asset", foreign_keys=[preview_asset_id])

    def __repr__(self):
        return f"<IdeaVersion(id={self.id}, idea_id={self.idea_id}, version_index={self.version_index})>"


class WorkflowDraft(Base):
    """Workflow Draft Model"""
    __tablename__ = "workflow_drafts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    idea_id = Column(UUID(as_uuid=True), ForeignKey("content_ideas.id", ondelete="CASCADE"), nullable=False)
    steps = Column(JSONB, nullable=False, default=[])
    metadata = Column(JSONB, default={})
    status = Column(String(50), nullable=False, default="draft")  # "draft" | "ready" | "started"
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    idea = relationship("ContentIdea", back_populates="workflow_drafts")

    def __repr__(self):
        return f"<WorkflowDraft(id={self.id}, idea_id={self.idea_id}, status={self.status})>"

