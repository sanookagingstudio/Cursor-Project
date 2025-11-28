"""
Music & Audio Module Models
Audio Analysis, Stem Groups, and Tab Records
"""

from sqlalchemy import Column, String, Float, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from sqlalchemy.types import TIMESTAMP
from app.core.db import Base
import uuid


class AudioAnalysis(Base):
    """Audio Analysis Model"""
    __tablename__ = "audio_analysis"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    asset_id = Column(UUID(as_uuid=True), ForeignKey("assets.id", ondelete="CASCADE"), nullable=False)
    bpm = Column(Float, nullable=True)
    key = Column(String(50), nullable=True)  # "C:maj", "A:min"
    time_signature = Column(String(10), nullable=True)  # "4/4", "6/8"
    sections = Column(JSONB, default=[])
    chord_progression = Column(JSONB, default=[])
    energy_curve = Column(JSONB, default={})
    meta_data = Column(JSONB, default={})
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    # Relationships
    asset = relationship("Asset", backref="audio_analyses")

    def __repr__(self):
        return f"<AudioAnalysis(id={self.id}, asset_id={self.asset_id}, bpm={self.bpm})>"


class StemGroup(Base):
    """Stem Group Model"""
    __tablename__ = "stem_groups"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    source_asset_id = Column(UUID(as_uuid=True), ForeignKey("assets.id", ondelete="CASCADE"), nullable=False)
    stem_assets = Column(JSONB, nullable=False, default={})  # {"vocal": "uuid", "drums": "uuid", ...}
    provider = Column(String(100), nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    # Relationships
    source_asset = relationship("Asset", foreign_keys=[source_asset_id], backref="stem_groups")

    def __repr__(self):
        return f"<StemGroup(id={self.id}, source_asset_id={self.source_asset_id})>"


class TabRecord(Base):
    """Tab Record Model"""
    __tablename__ = "tab_records"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    audio_asset_id = Column(UUID(as_uuid=True), ForeignKey("assets.id", ondelete="CASCADE"), nullable=False)
    instrument = Column(String(50), nullable=False)  # "guitar" | "bass" | "ukulele"
    difficulty = Column(String(50), nullable=False)  # "easy" | "original" | "advanced"
    format = Column(String(50), nullable=False)  # "text" | "gp5" | "musicxml"
    content = Column(Text, nullable=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    # Relationships
    audio_asset = relationship("Asset", backref="tab_records")

    def __repr__(self):
        return f"<TabRecord(id={self.id}, instrument={self.instrument}, difficulty={self.difficulty})>"

