"""
Theme Customization Models
Theme configurations, settings, and user preferences
"""

from sqlalchemy import Column, String, Integer, Boolean, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from sqlalchemy.types import TIMESTAMP
from app.core.db import Base
import uuid


class Theme(Base):
    """Theme Model"""
    __tablename__ = "themes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    is_preset = Column(Boolean, default=False)
    is_active = Column(Boolean, default=False)
    created_by = Column(UUID(as_uuid=True), ForeignKey("auth.users(id)", ondelete="SET NULL"), nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    settings = relationship("ThemeSetting", backref="theme", cascade="all, delete-orphan")
    user_preferences = relationship("UserThemePreference", backref="theme")

    def __repr__(self):
        return f"<Theme(id={self.id}, name={self.name}, is_active={self.is_active})>"


class ThemeSetting(Base):
    """Theme Setting Model"""
    __tablename__ = "theme_settings"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    theme_id = Column(UUID(as_uuid=True), ForeignKey("themes(id)", ondelete="CASCADE"), nullable=False)
    settings = Column(JSONB, nullable=False)  # All theme configs
    version = Column(Integer, default=1)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    def __repr__(self):
        return f"<ThemeSetting(id={self.id}, theme_id={self.theme_id}, version={self.version})>"


class UserThemePreference(Base):
    """User Theme Preference Model"""
    __tablename__ = "user_theme_preferences"

    user_id = Column(UUID(as_uuid=True), ForeignKey("auth.users(id)", ondelete="CASCADE"), primary_key=True)
    theme_id = Column(UUID(as_uuid=True), ForeignKey("themes(id)", ondelete="SET NULL"), nullable=True)
    custom_settings = Column(JSONB, nullable=True)  # Override specific settings
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    def __repr__(self):
        return f"<UserThemePreference(user_id={self.user_id}, theme_id={self.theme_id})>"

